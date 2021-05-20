//
//  SignInPersonSelectionViewTests.swift
//  StrafenTests
//
//  Created by Steven on 20.05.21.
//

import XCTest
import FirebaseFunctions
import SwiftUI
@testable import Strafen

class SignInPersonSelectionViewTests: XCTestCase {

    let clubId = Club.ID(rawValue: UUID(uuidString: "fb3f6718-3cc5-4d2e-aca1-398a39fc1be7")!)

    override func setUpWithError() throws {
        continueAfterFailure = false
        FirebaseFetcher.shared.level = .testing
        FirebaseObserver.shared.level = .testing
        FirebaseFunctionCaller.shared.level = .testing

        let createClubResult: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            let callItem = FFNewTestClubCall(clubId: clubId, testClubType: .fetcherTestClub)
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        _ = try createClubResult.get()
    }

    override func tearDownWithError() throws {
        let deleteClubResult: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            let callItem = FFDeleteTestClubCall(clubId: clubId)
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        _ = try deleteClubResult.get()
    }

    /// Tests with selected person
    func testWithPersonSelected() throws {
        var inputProperties = SignInPersonSelectionView.InputProperties()
        inputProperties.personList = []
        let person = TestClub.fetcherTestClub.persons.first { $0.signInData == nil }!
        inputProperties.selectedPersonId = person.id
        let inputBinding = Binding<SignInPersonSelectionView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        let signInProperty = SignInProperty.UserIdNameClubId(userId: "userId", name: PersonName(firstName: "firstName"), clubId: clubId)
        waitExpectation { handler in
            SignInPersonSelectionView.handleRegisterButtonPress(signInProperty: signInProperty, inputProperty: inputBinding, onCompletion: handler)
        }
        XCTAssertNil(inputProperties.errorMessage)

        // TODO check settings

        let personListResult: Result<[FirebasePerson], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId).thenResult(handler)
        }
        let fetchedPerson = try personListResult.get().first { $0.id == person.id }
        XCTAssertEqual(fetchedPerson?.name, PersonName(firstName: "firstName"))
        XCTAssertEqual(fetchedPerson?.signInData?.userId, "userId")
        XCTAssertEqual(fetchedPerson?.signInData?.isCashier, false)

        let personUserIdResult: Result<String, Error> = try waitExpectation { handler in
            let url = URL(string: "personUserIds/userId")!
            FirebaseFetcher.shared.fetch(String.self, url: url, clubId: clubId).thenResult(handler)
        }
        XCTAssertEqual(try personUserIdResult.get(), person.id.uuidString)
    }

    /// Tests without selected person
    func testWithOutPersonSelected() throws {
        var inputProperties = SignInPersonSelectionView.InputProperties()
        inputProperties.personList = []
        let inputBinding = Binding<SignInPersonSelectionView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        let signInProperty = SignInProperty.UserIdNameClubId(userId: "userId2", name: PersonName(firstName: "firstName2"), clubId: clubId)
        waitExpectation { handler in
            SignInPersonSelectionView.handleRegisterButtonPress(signInProperty: signInProperty, inputProperty: inputBinding, onCompletion: handler)
        }
        XCTAssertNil(inputProperties.errorMessage)

        // TODO check settings

        let personUserIdResult: Result<String, Error> = try waitExpectation { handler in
            let url = URL(string: "personUserIds/userId2")!
            FirebaseFetcher.shared.fetch(String.self, url: url, clubId: clubId).thenResult(handler)
        }
        let personId = try personUserIdResult.get()

        let personListResult: Result<[FirebasePerson], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId).thenResult(handler)
        }
        let fetchedPerson = try personListResult.get().first { $0.id.uuidString == personId }
        XCTAssertEqual(fetchedPerson?.name, PersonName(firstName: "firstName2"))
        XCTAssertEqual(fetchedPerson?.signInData?.userId, "userId2")
        XCTAssertEqual(fetchedPerson?.signInData?.isCashier, false)
    }
}
