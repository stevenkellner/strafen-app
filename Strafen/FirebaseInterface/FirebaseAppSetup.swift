//
//  FirebaseAppSetup.swift
//  Strafen
//
//  Created by Steven on 27.05.21.
//

import SwiftUI
import FirebaseAuth

/// Used to setup app with firebase
@MainActor class FirebaseAppSetup: ObservableObject {

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

            connectionState.passed()
            return allLists
        } catch {
            connectionState.failed()
            throw error
        }
    }

    /// Fetches lists from database
    /// - Parameter clubId: Id of club of logged in person
    private func fetchLists(clubId: Club.ID) async throws -> AllLists {
        async let personList: [FirebasePerson] = FirebaseFetcher.shared.fetchList(clubId: clubId)
        async let fineList: [FirebaseFine] = FirebaseFetcher.shared.fetchList(clubId: clubId)
        async let reasonList: [FirebaseReasonTemplate] = FirebaseFetcher.shared.fetchList(clubId: clubId)
        return try await AllLists(personList: personList, fineList: fineList, reasonList: reasonList)
    }

    /// Check if properties of logged in person is valid
    ///
    /// 1. Check if person is forced sign out by the cashier
    /// 2. Check if email is verificated
    /// 3. Set late payment interest
    /// 4. Set region code
    /// - Parameters:
    ///   - loggedInPerson: Logged in person
    ///   - allLists: person, fine and reason template lists
    private func checkPersonProperties(person loggedInPerson: Settings.Person, allLists: AllLists) async throws {

        // Check if person is forced sign out by the cashier
        guard let signInData = allLists.personList.first(where: { $0.id == loggedInPerson.id })?.signInData else {
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

        // Get late payment interest, in app payment active and region code
        let clubId = loggedInPerson.club.id
        async let latePaymentInterest: LatePaymentInterest = FirebaseFetcher.shared.fetch(path: "latePaymentInterest", clubId: clubId)
        async let inAppPaymentActive: Bool = FirebaseFetcher.shared.fetch(path: "inAppPaymentActive", clubId: clubId)
        async let regionCode: String = FirebaseFetcher.shared.fetch(path: "regionCode", clubId: clubId)

        // Set late payment interest, in app payment active and region code
        Settings.shared.latePaymentInterest = try? await latePaymentInterest
        Settings.shared.person?.club.inAppPaymentActive = (try? await inAppPaymentActive) ?? false
        Settings.shared.person?.club.regionCode = try await regionCode
    }
}
