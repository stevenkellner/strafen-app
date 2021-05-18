//
//  SignInClubSelectionTests.swift
//  StrafenTests
//
//  Created by Steven on 18.05.21.
//

import XCTest
import SwiftUI
import FirebaseFunctions
@testable import Strafen

class SignInClubSelectionTests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
        FirebaseFetcher.shared.level = .testing
        FirebaseFunctionCaller.shared.level = .testing
    }

    /// Tests with no identifier
    func testNoIdentifier() {
        var inputProperties = SignInClubSelectionView.InputProperties()
        inputProperties.inputProperties = [:]
        let inputBinding = Binding<SignInClubSelectionView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        let oldSignInProperty = SignInProperty.UserIdName(userId: "UserId", name: PersonName(firstName: "FirstName"))
        SignInClubSelectionView.handleContinueButtonPress(oldSignInProperty: oldSignInProperty, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.clubIdentifier: .emptyField])
    }

    /// Tests with not existsing identifier
    func testNotExistingIdentifier() {
        var inputProperties = SignInClubSelectionView.InputProperties()
        inputProperties.inputProperties = [.clubIdentifier: "notExisting"]
        let inputBinding = Binding<SignInClubSelectionView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        let oldSignInProperty = SignInProperty.UserIdName(userId: "UserId", name: PersonName(firstName: "FirstName"))
        waitExpectation { handler in
            SignInClubSelectionView.handleContinueButtonPress(oldSignInProperty: oldSignInProperty, inputProperties: inputBinding, onCompletion: handler)
        }
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.clubIdentifier: .clubNotExists])
    }

    /// Tests with valid identifier
    func testValidIdentifier() throws {
        let clubId = Club.ID(rawValue: UUID(uuidString: "fb3f6718-8cc5-4d2e-aca1-398a39fc1be7")!)

        // Create club
        let createClubResult: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            let callItem = FFNewTestClubCall(clubId: clubId, testClubType: .fetcherTestClub)
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        _ = try createClubResult.get()

        // Test with valid identifier
        var inputProperties = SignInClubSelectionView.InputProperties()
        inputProperties.inputProperties = [.clubIdentifier: "demo-team"]
        let inputBinding = Binding<SignInClubSelectionView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        let oldSignInProperty = SignInProperty.UserIdName(userId: "UserId", name: PersonName(firstName: "FirstName"))
        waitExpectation { handler in
            SignInClubSelectionView.handleContinueButtonPress(oldSignInProperty: oldSignInProperty, inputProperties: inputBinding, onCompletion: handler)
        }
        XCTAssertEqual(inputProperties.connectionState, .passed)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertEqual(inputProperties.signInProperty, SignInProperty.UserIdNameClubId(oldSignInProperty, clubId: clubId))

        // Delete club again
        let deleteClubResult: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            let callItem = FFDeleteTestClubCall(clubId: clubId)
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        _ = try deleteClubResult.get()
    }
}
