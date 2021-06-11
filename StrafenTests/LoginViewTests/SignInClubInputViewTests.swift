//
//  SignInClubInputViewTests.swift
//  StrafenTests
//
//  Created by Steven on 18.05.21.
//

import XCTest
import SwiftUI
import FirebaseFunctions
import FirebaseAuth
@testable import Strafen

class SignInClubInputViewTests: XCTestCase {

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

    /// Tests with no club name
    func testNoClubName() async {
        var inputProperties = SignInClubInputView.InputProperties()
        inputProperties.inputProperties = [.clubIdentifier: "ClubIdentifier"]
        inputProperties.regionCode = "DE"
        inputProperties.inAppPayment = false
        let inputBinding = Binding<SignInClubInputView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        let oldSignInProperty = SignInProperty.UserIdName(userId: "UserId", name: PersonName(firstName: "FirstName"))
        await SignInClubInputView.handleConfirmButtonPress(oldSignInProperty: oldSignInProperty, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.clubName: .emptyField])
        XCTAssertNil(inputProperties.regionCodeErrorMessage)
        XCTAssertNil(inputProperties.inAppPaymentErrorMessage)
    }

    /// Tests with no club identifer
    func testNoClubIdentifier() async {
        var inputProperties = SignInClubInputView.InputProperties()
        inputProperties.inputProperties = [.clubName: "clubName"]
        inputProperties.regionCode = "DE"
        inputProperties.inAppPayment = false
        let inputBinding = Binding<SignInClubInputView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        let oldSignInProperty = SignInProperty.UserIdName(userId: "UserId", name: PersonName(firstName: "FirstName"))
        await SignInClubInputView.handleConfirmButtonPress(oldSignInProperty: oldSignInProperty, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.clubIdentifier: .emptyField])
        XCTAssertNil(inputProperties.regionCodeErrorMessage)
        XCTAssertNil(inputProperties.inAppPaymentErrorMessage)
    }

    /// Tests with no region code
    func testNoRegionCode() async {
        var inputProperties = SignInClubInputView.InputProperties()
        inputProperties.inputProperties = [.clubName: "clubName", .clubIdentifier: "ClubIdentifier"]
        inputProperties.regionCode = nil
        inputProperties.inAppPayment = true
        let inputBinding = Binding<SignInClubInputView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        let oldSignInProperty = SignInProperty.UserIdName(userId: "UserId", name: PersonName(firstName: "FirstName"))
        await SignInClubInputView.handleConfirmButtonPress(oldSignInProperty: oldSignInProperty, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertEqual(inputProperties.regionCodeErrorMessage, .noRegionGiven)
        XCTAssertNil(inputProperties.inAppPaymentErrorMessage)
    }

    /// Tests with not euro
    func testNotEuro() async {
        var inputProperties = SignInClubInputView.InputProperties()
        inputProperties.inputProperties = [.clubName: "clubName", .clubIdentifier: "ClubIdentifier"]
        inputProperties.regionCode = "US"
        inputProperties.inAppPayment = true
        let inputBinding = Binding<SignInClubInputView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        let oldSignInProperty = SignInProperty.UserIdName(userId: "UserId", name: PersonName(firstName: "FirstName"))
        await SignInClubInputView.handleConfirmButtonPress(oldSignInProperty: oldSignInProperty, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertNil(inputProperties.regionCodeErrorMessage)
        XCTAssertEqual(inputProperties.inAppPaymentErrorMessage, .notEuro)
    }

    /// Tests with already existing identifier
    func testIdentiferExists() async throws {
        let clubId = Club.ID(rawValue: UUID(uuidString: "fb3f6718-8cc5-4d2e-aca1-398a39fc1be7")!)

        // Create club
        let callItem1 = FFNewTestClubCall(clubId: clubId, testClubType: .fetcherTestClub)
        try await FirebaseFunctionCaller.shared.call(callItem1)

        // Test with already existing identifier
        var inputProperties = SignInClubInputView.InputProperties()
        inputProperties.inputProperties = [.clubName: "clubName", .clubIdentifier: "demo-team"]
        inputProperties.regionCode = "DE"
        inputProperties.inAppPayment = false
        let inputBinding = Binding<SignInClubInputView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        let oldSignInProperty = SignInProperty.UserIdName(userId: "UserId", name: PersonName(firstName: "FirstName"))
        let fetchedClubId = await SignInClubInputView.handleConfirmButtonPress(oldSignInProperty: oldSignInProperty, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.clubIdentifier: .identifierAlreadyExists])
        XCTAssertNil(inputProperties.regionCodeErrorMessage)
        XCTAssertNil(inputProperties.inAppPaymentErrorMessage)
        XCTAssertNil(fetchedClubId)

        // Delete club again
        let callItem2 = FFDeleteTestClubCall(clubId: clubId)
        try await FirebaseFunctionCaller.shared.call(callItem2)
    }

    /// Tests creation of new club
    func testCreateClub() async throws {
        var inputProperties = SignInClubInputView.InputProperties()
        inputProperties.inputProperties = [.clubName: "clubName", .clubIdentifier: "ClubIdentifier"]
        inputProperties.regionCode = "DE"
        inputProperties.inAppPayment = false
        let inputBinding = Binding<SignInClubInputView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        let oldSignInProperty = SignInProperty.UserIdName(userId: "UserId", name: PersonName(firstName: "FirstName"))
        let clubId = await SignInClubInputView.handleConfirmButtonPress(oldSignInProperty: oldSignInProperty, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .passed)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertNil(inputProperties.regionCodeErrorMessage)
        XCTAssertNil(inputProperties.inAppPaymentErrorMessage)
        XCTAssertNotNil(clubId)

        // Check settings
        XCTAssertEqual(Settings.shared.person?.name, oldSignInProperty.name)
        XCTAssertEqual(Settings.shared.person?.isCashier, true)
        XCTAssertEqual(Settings.shared.person?.club, Club(id: clubId!, name: "clubName", identifier: "ClubIdentifier", regionCode: "DE", inAppPaymentActive: false))

        // Delete club again
        let callItem = FFDeleteTestClubCall(clubId: clubId!)
        try await FirebaseFunctionCaller.shared.call(callItem)
    }
}
