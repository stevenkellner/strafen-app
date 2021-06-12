//
//  SignInPersonSelectionViewTests.swift
//  StrafenTests
//
//  Created by Steven on 20.05.21.
//

import XCTest
import FirebaseFunctions
import FirebaseAuth
import SwiftUI
@testable import Strafen

class SignInPersonSelectionViewTests: XCTestCase {

    let clubId = Club.ID(rawValue: UUID(uuidString: "fb3f6718-3cc5-4d2e-aca1-398a39fc1be7")!)

    @MainActor override func setUpWithError() throws {
        continueAfterFailure = false
        FirebaseFetcher.shared.level = .testing
        FirebaseFunctionCaller.shared.level = .testing

        waitExpectation { handler in
            async {

                // Sign test user in
                try await Auth.auth().signIn(withEmail: "app.demo@web.de", password: "Demopw12")

                let callItem = FFNewTestClubCall(clubId: clubId, testClubType: .fetcherTestClub)
                try await FirebaseFunctionCaller.shared.call(callItem)

                handler()
            }
        }
        try Task.checkCancellation()
    }

    override func tearDownWithError() throws {
        waitExpectation { handler in
            async {
                let callItem = FFDeleteTestClubCall(clubId: clubId)
                try await FirebaseFunctionCaller.shared.call(callItem)
                handler()
            }
        }
        try Task.checkCancellation()
    }

    /// Tests with selected person
    func testWithPersonSelected() async throws {
        var inputProperties = SignInPersonSelectionView.InputProperties()
        inputProperties.personList = []
        let person = TestClub.fetcherTestClub.persons.first { $0.signInData == nil }!
        inputProperties.selectedPersonId = person.id
        let inputBinding = Binding<SignInPersonSelectionView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        let signInProperty = SignInProperty.UserIdNameClubId(userId: "userId", name: PersonName(firstName: "firstName"), clubId: clubId)
        await SignInPersonSelectionView.handleRegisterButtonPress(signInProperty: signInProperty, inputProperty: inputBinding)
        XCTAssertNil(inputProperties.errorMessage)

        let personList = try await FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId)
        let fetchedPerson = personList.first { $0.id == person.id }
        XCTAssertEqual(fetchedPerson?.name, PersonName(firstName: "firstName"))
        XCTAssertEqual(fetchedPerson?.signInData?.userId, "userId")
        XCTAssertEqual(fetchedPerson?.signInData?.isCashier, false)

        let personUserId = try await FirebaseFetcher.shared.fetch(String.self, url: URL(string: "personUserIds/userId")!, clubId: clubId)
        XCTAssertEqual(personUserId, person.id.uuidString)

        // Check settings
        XCTAssertEqual(Settings.shared.person?.id, person.id)
        XCTAssertEqual(Settings.shared.person?.name, signInProperty.name)
        XCTAssertEqual(Settings.shared.person?.isCashier, false)
        XCTAssertEqual(Settings.shared.person?.club, TestClub.fetcherTestClub.properties.club(with: clubId))
    }

    /// Tests without selected person
    func testWithOutPersonSelected() async throws {
        var inputProperties = SignInPersonSelectionView.InputProperties()
        inputProperties.personList = []
        let inputBinding = Binding<SignInPersonSelectionView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        let signInProperty = SignInProperty.UserIdNameClubId(userId: "userId2", name: PersonName(firstName: "firstName2"), clubId: clubId)
        await SignInPersonSelectionView.handleRegisterButtonPress(signInProperty: signInProperty, inputProperty: inputBinding)
        XCTAssertNil(inputProperties.errorMessage)

        let personId = try await FirebaseFetcher.shared.fetch(String.self, url: URL(string: "personUserIds/userId2")!, clubId: clubId)

        let personList = try await FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId)
        let fetchedPerson = personList.first { $0.id.uuidString == personId }
        XCTAssertEqual(fetchedPerson?.name, PersonName(firstName: "firstName2"))
        XCTAssertEqual(fetchedPerson?.signInData?.userId, "userId2")
        XCTAssertEqual(fetchedPerson?.signInData?.isCashier, false)

        // Check settings
        XCTAssertEqual(Settings.shared.person?.id.uuidString, personId)
        XCTAssertEqual(Settings.shared.person?.name, signInProperty.name)
        XCTAssertEqual(Settings.shared.person?.isCashier, false)
        XCTAssertEqual(Settings.shared.person?.club, TestClub.fetcherTestClub.properties.club(with: clubId))
    }
}
