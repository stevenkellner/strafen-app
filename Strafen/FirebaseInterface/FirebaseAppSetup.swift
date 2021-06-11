//
//  FirebaseAppSetup.swift
//  Strafen
//
//  Created by Steven on 27.05.21.
//

import SwiftUI
import FirebaseAuth

/// Used to setup app with firebase
class FirebaseAppSetup: ObservableObject {

    /// Error occured while setup app
    enum SetupError: Error {

        /// Connection state is loading
        case stillLoading

        /// No person is logged in
        case noPersonLoggedIn
    }

    /// Contains person, fine and reason template lists
    struct AllLists {

        /// Person list
        let personList: [FirebasePerson]

        /// Fine list
        let fineList: [FirebaseFine]

        /// Reason list
        let reasonList: [FirebaseReasonTemplate]
    }

    /// Shared instace for singleton
    static let shared = FirebaseAppSetup()

    /// Private init for singleton
    private init() {}

    /// Connection state for list fetching
    @Published var connectionState: ConnectionState = .notStarted

    /// Person is force signed out
    @Published var forceSignedOut = false

    /// Email not verificated in last month
    @Published var emailNotVerificated = false

    /// Setup app with firebase
    /// - Returns: person, fine and reason template lists
    func setup() async throws -> AllLists {
        guard connectionState.restart() == .passed else { throw SetupError.stillLoading }
        do {
            guard let person = Settings.shared.person else {
                throw SetupError.noPersonLoggedIn
            }
            HomeTab.shared.active = .personList

            // Fetch lists from database
            let allLists = try await fetchLists(clubId: person.club.id)

            // Check person properties
            try await checkPersonProperties(person: person, allLists: allLists)

            return allLists
        } catch {
            connectionState.failed()
            throw error
        }
    }

    /// Fetches lists from database
    /// - Parameter clubId: Id of club of logged in person
    private func fetchLists(clubId: Club.ID) async throws -> AllLists {
        async let personList = FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId)
        async let fineList = FirebaseFetcher.shared.fetchList(FirebaseFine.self, clubId: clubId)
        async let reasonList = FirebaseFetcher.shared.fetchList(FirebaseReasonTemplate.self, clubId: clubId)
        return try await AllLists(personList: personList, fineList: fineList, reasonList: reasonList)
    }

    /// Check if properties of logged in person is valid
    ///
    /// - Note:
    ///     - Check if person is forced sign out by the cashier
    ///     - Check if email is verificated
    ///     - Set late payment interest
    ///     - Set region code
    /// - Parameters:
    ///   - loggedInPerson: Logged in person
    ///   - allLists: person, fine and reason template lists
    private func checkPersonProperties(person loggedInPerson: Settings.Person, allLists: AllLists) async throws {

        // Check if person is forced sign out by the cashier
        guard let person = allLists.personList.first(where: { $0.id == loggedInPerson.id }),
              let signInData = person.signInData else {
                  try Auth.auth().signOut()
                  return forceSignedOut = true
              }

        // Check if email is verificated
        guard let user = Auth.auth().currentUser else {
            return forceSignedOut = true
        }
        if user.email != nil, !user.isEmailVerified {
            let monthSinceSignIn = Calendar.current.dateComponents([.month], from: signInData.signInDate, to: Date()).month!
            if monthSinceSignIn >= 1 {
                return emailNotVerificated = true
            }
        }

        await withThrowingTaskGroup(of: Void.self) { group in

            // Get late payment interest
            group.async {
                Settings.shared.latePaymentInterest = try await FirebaseFetcher.shared.fetch(LatePaymentInterest.self, url: URL(string: "latePaymentInterest"), clubId: loggedInPerson.club.id)
            }

            // Get in app payment active
            group.async {
                Settings.shared.person?.club.inAppPaymentActive = (try? await FirebaseFetcher.shared.fetch(Bool.self, url: URL(string: "inAppPaymentActive"), clubId: loggedInPerson.club.id)) ?? false
            }

            // Get region code
            group.async {
                Settings.shared.person?.club.regionCode = try await FirebaseFetcher.shared.fetch(String.self, url: URL(string: "regionCode"), clubId: loggedInPerson.club.id)
            }
        }
    }
}
