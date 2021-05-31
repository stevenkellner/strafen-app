//
//  FirebaseAppSetup.swift
//  Strafen
//
//  Created by Steven on 27.05.21.
//

import SwiftUI
import Hydra
import FirebaseAuth

/// Used to setup app with firebase
class FirebaseAppSetup: ObservableObject {

    /// Shared instace for singleton
    static let shared = FirebaseAppSetup()

    /// Private init for singleton
    private init() {}

    var personList: [FirebasePerson]?

    var fineList: [FirebaseFine]?

    var reasonList: [FirebaseReasonTemplate]?

    /// Connection state for list fetching
    @Published var connectionState: ConnectionState = .notStarted

    /// Person is force signed out
    @Published var forceSignedOut = false

    /// Email not verificated in last month
    @Published var emailNotVerificated = false

    /// Setup app with firebase
    func setup(handler completionHandler: @escaping ([FirebasePerson], [FirebaseFine], [FirebaseReasonTemplate]) -> Void) {
        guard self.connectionState.restart() == .passed else { return }
        guard let person = Settings.shared.person else {
            return self.connectionState.failed()
        }
        HomeTab.shared.active = .personList

            // Fetch lists from database
        self.fetchLists(clubId: person.club.id).then(in: .main) { _ in

            // Check person properties
            self.checkPersonProperties(person: person).then(in: .main) { _ in
                guard let personList = self.personList,
                      let fineList = self.fineList,
                      let reasonList = self.reasonList else {
                    return self.connectionState.failed()
                }
                completionHandler(personList, fineList, reasonList)
            }
        }
    }

    /// Fetches lists from database
    private func fetchLists(clubId: Club.ID) -> Promise<Void> {
        let personListPromise = FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId)
        let fineListPromise = FirebaseFetcher.shared.fetchList(FirebaseFine.self, clubId: clubId)
        let reasonListPromise = FirebaseFetcher.shared.fetchList(FirebaseReasonTemplate.self, clubId: clubId)
        return zip(a: personListPromise, b: fineListPromise, c: reasonListPromise).then(in: .main) { [weak self] personList, fineList, reasonList in
            self?.personList = personList
            self?.fineList = fineList
            self?.reasonList = reasonList
        }.catch(in: .main) { [weak self] _ in
            self?.connectionState.failed()
        }
    }

    /// Check if properties of logged in person is valid
    ///
    /// - Note:
    ///     - Check if person is forced sign out by the cashier
    ///     - Check if email is verificated
    ///     - Set late payment interest
    ///     - Set region code
    ///
    /// - Parameter loggedInPerson: logged in person
    private func checkPersonProperties(person loggedInPerson: Settings.Person) -> Promise<Void> {

        // Check if person is forced sign out by the cashier
        guard let person = personList?.first(where: { $0.id == loggedInPerson.id }),
              let signInData = person.signInData else {
            try? Auth.auth().signOut()
            forceSignedOut = true
            return Promise.init(resolved: ())
        }

        // Check if email is verificated
        guard let user = Auth.auth().currentUser else {
            forceSignedOut = true
            return Promise.init(resolved: ())
        }
        if user.email != nil && !user.isEmailVerified {
            let monthSinceSignIn = Calendar.current.dateComponents([.month], from: signInData.signInDate, to: Date()).month!
            if monthSinceSignIn >= 1 {
                emailNotVerificated = true
                return Promise.init(resolved: ())
            }
        }

        // Get late payment interest
        let latePaymentInterestPromise = FirebaseFetcher.shared.fetch(LatePaymentInterest.self, url: URL(string: "latePaymentInterest"), clubId: loggedInPerson.club.id).thenResult(in: .main) { result in
            Settings.shared.latePaymentInterest = try? result.get()
        }

        // Get in app payment active
        let inAppPaymentActivePromise = FirebaseFetcher.shared.fetch(Bool.self, url: URL(string: "inAppPaymentActive"), clubId: loggedInPerson.club.id).thenResult(in: .main) { result in
            Settings.shared.person?.club.inAppPaymentActive = (try? result.get()) ?? false
        }

        // Get region code
        let regionCodePromise = FirebaseFetcher.shared.fetch(String.self, url: URL(string: "regionCode"), clubId: loggedInPerson.club.id).then(in: .main) { regionCode in
            Settings.shared.person?.club.regionCode = regionCode
        }

        return zip(a: latePaymentInterestPromise, b: inAppPaymentActivePromise, c: regionCodePromise).then(in: .main) { [weak self] _, _, _ in
            self?.connectionState.passed()
        }.catch(in: .main) { [weak self] _ in
            self?.connectionState.failed()
        }
    }
}
