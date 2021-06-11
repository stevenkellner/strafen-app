//
//  SignInClubSelectionTests.swift
//  StrafenTests
//
//  Created by Steven on 18.05.21.
//

import XCTest
import SwiftUI
import FirebaseFunctions
import FirebaseAuth
@testable import Strafen

class SignInClubSelectionTests: XCTestCase {

    @MainActor override func setUpWithError() throws {
        continueAfterFailure = false
        FirebaseFetcher.shared.level = .testing
        FirebaseFunctionCaller.shared.level = .testing

        // Sign test user in
        waitExpectation { handler in
            async {
                try await Auth.auth().signIn(withEmail: "app.demo@web.de", password: "Demopw12")
                handler()
            }
        }
        try Task.checkCancellation()
    }

    /// Tests with no identifier
    func testNoIdentifier() async {
        var inputProperties = SignInClubSelectionView.InputProperties()
        inputProperties.inputProperties = [:]
        let inputBinding = Binding<SignInClubSelectionView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        let oldSignInProperty = SignInProperty.UserIdName(userId: "UserId", name: PersonName(firstName: "FirstName"))
        await SignInClubSelectionView.handleContinueButtonPress(oldSignInProperty: oldSignInProperty, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.clubIdentifier: .emptyField])
    }

    /// Tests with not existsing identifier
    func testNotExistingIdentifier() async {
        var inputProperties = SignInClubSelectionView.InputProperties()
        inputProperties.inputProperties = [.clubIdentifier: "notExisting"]
        let inputBinding = Binding<SignInClubSelectionView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        let oldSignInProperty = SignInProperty.UserIdName(userId: "UserId", name: PersonName(firstName: "FirstName"))
        await SignInClubSelectionView.handleContinueButtonPress(oldSignInProperty: oldSignInProperty, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.clubIdentifier: .clubNotExists])
    }

    /// Tests with valid identifier
    func testValidIdentifier() async throws {
        let clubId = Club.ID(rawValue: UUID(uuidString: "fb3f6718-8cc5-4d2e-aca1-398a39fc1be7")!)

        // Create club
        let callItem1 = FFNewTestClubCall(clubId: clubId, testClubType: .fetcherTestClub)
        try await FirebaseFunctionCaller.shared.call(callItem1)

        // Test with valid identifier
        var inputProperties = SignInClubSelectionView.InputProperties()
        inputProperties.inputProperties = [.clubIdentifier: "demo-team"]
        let inputBinding = Binding<SignInClubSelectionView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        let oldSignInProperty = SignInProperty.UserIdName(userId: "UserId", name: PersonName(firstName: "FirstName"))
        await SignInClubSelectionView.handleContinueButtonPress(oldSignInProperty: oldSignInProperty, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .passed)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertEqual(inputProperties.signInProperty, SignInProperty.UserIdNameClubId(oldSignInProperty, clubId: clubId))

        // Delete club again
        let callItem2 = FFDeleteTestClubCall(clubId: clubId)
        try await FirebaseFunctionCaller.shared.call(callItem2)
    }
}
