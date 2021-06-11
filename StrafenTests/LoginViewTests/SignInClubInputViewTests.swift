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

    override func setUpWithError() throws {
        continueAfterFailure = false
        FirebaseFetcher.shared.level = .testing
        FirebaseFunctionCaller.shared.level = .testing

        // Sign test user in
        let signInError: Error? = try waitExpectation { handler in
            Auth.auth().signIn(withEmail: "app.demo@web.de", password: "Demopw12") { _, error in
                handler(error)
            }
        }
        XCTAssertNil(signInError)
    }

    /// Tests with no club name
    func testNoClubName() {
        var inputProperties = SignInClubInputView.InputProperties()
        inputProperties.inputProperties = [.clubIdentifier: "ClubIdentifier"]
        inputProperties.regionCode = "DE"
        inputProperties.inAppPayment = false
        let inputBinding = Binding<SignInClubInputView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        let oldSignInProperty = SignInProperty.UserIdName(userId: "UserId", name: PersonName(firstName: "FirstName"))
        SignInClubInputView.handleConfirmButtonPress(oldSignInProperty: oldSignInProperty, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.clubName: .emptyField])
        XCTAssertNil(inputProperties.regionCodeErrorMessage)
        XCTAssertNil(inputProperties.inAppPaymentErrorMessage)
    }

    /// Tests with no club identifer
    func testNoClubIdentifier() {
        var inputProperties = SignInClubInputView.InputProperties()
        inputProperties.inputProperties = [.clubName: "clubName"]
        inputProperties.regionCode = "DE"
        inputProperties.inAppPayment = false
        let inputBinding = Binding<SignInClubInputView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        let oldSignInProperty = SignInProperty.UserIdName(userId: "UserId", name: PersonName(firstName: "FirstName"))
        SignInClubInputView.handleConfirmButtonPress(oldSignInProperty: oldSignInProperty, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.clubIdentifier: .emptyField])
        XCTAssertNil(inputProperties.regionCodeErrorMessage)
        XCTAssertNil(inputProperties.inAppPaymentErrorMessage)
    }

    /// Tests with no region code
    func testNoRegionCode() {
        var inputProperties = SignInClubInputView.InputProperties()
        inputProperties.inputProperties = [.clubName: "clubName", .clubIdentifier: "ClubIdentifier"]
        inputProperties.regionCode = nil
        inputProperties.inAppPayment = true
        let inputBinding = Binding<SignInClubInputView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        let oldSignInProperty = SignInProperty.UserIdName(userId: "UserId", name: PersonName(firstName: "FirstName"))
        SignInClubInputView.handleConfirmButtonPress(oldSignInProperty: oldSignInProperty, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertEqual(inputProperties.regionCodeErrorMessage, .noRegionGiven)
        XCTAssertNil(inputProperties.inAppPaymentErrorMessage)
    }

    /// Tests with not euro
    func testNotEuro() {
        var inputProperties = SignInClubInputView.InputProperties()
        inputProperties.inputProperties = [.clubName: "clubName", .clubIdentifier: "ClubIdentifier"]
        inputProperties.regionCode = "US"
        inputProperties.inAppPayment = true
        let inputBinding = Binding<SignInClubInputView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        let oldSignInProperty = SignInProperty.UserIdName(userId: "UserId", name: PersonName(firstName: "FirstName"))
        SignInClubInputView.handleConfirmButtonPress(oldSignInProperty: oldSignInProperty, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertNil(inputProperties.regionCodeErrorMessage)
        XCTAssertEqual(inputProperties.inAppPaymentErrorMessage, .notEuro)
    }

    /// Tests with already existing identifier
    func testIdentiferExists() throws {
        let clubId = Club.ID(rawValue: UUID(uuidString: "fb3f6718-8cc5-4d2e-aca1-398a39fc1be7")!)

        // Create club
        let createClubResult: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            let callItem = FFNewTestClubCall(clubId: clubId, testClubType: .fetcherTestClub)
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        _ = try createClubResult.get()

        // Test with already existing identifier
        var inputProperties = SignInClubInputView.InputProperties()
        inputProperties.inputProperties = [.clubName: "clubName", .clubIdentifier: "demo-team"]
        inputProperties.regionCode = "DE"
        inputProperties.inAppPayment = false
        let inputBinding = Binding<SignInClubInputView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        let oldSignInProperty = SignInProperty.UserIdName(userId: "UserId", name: PersonName(firstName: "FirstName"))
        let fetchedClubId: Club.ID? = try waitExpectation { handler in
            SignInClubInputView.handleConfirmButtonPress(oldSignInProperty: oldSignInProperty, inputProperties: inputBinding, onCompletion: handler)
        }
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.clubIdentifier: .identifierAlreadyExists])
        XCTAssertNil(inputProperties.regionCodeErrorMessage)
        XCTAssertNil(inputProperties.inAppPaymentErrorMessage)
        XCTAssertNil(fetchedClubId)

        // Delete club again
        let deleteClubResult: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            let callItem = FFDeleteTestClubCall(clubId: clubId)
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        _ = try deleteClubResult.get()
    }

    /// Tests creation of new club
    func testCreateClub() throws {
        var inputProperties = SignInClubInputView.InputProperties()
        inputProperties.inputProperties = [.clubName: "clubName", .clubIdentifier: "ClubIdentifier"]
        inputProperties.regionCode = "DE"
        inputProperties.inAppPayment = false
        let inputBinding = Binding<SignInClubInputView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        let oldSignInProperty = SignInProperty.UserIdName(userId: "UserId", name: PersonName(firstName: "FirstName"))
        let clubId: Club.ID? = try waitExpectation { handler in
            SignInClubInputView.handleConfirmButtonPress(oldSignInProperty: oldSignInProperty, inputProperties: inputBinding, onCompletion: handler)
        }
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
        let deleteClubResult: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            let callItem = FFDeleteTestClubCall(clubId: clubId!)
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        _ = try deleteClubResult.get()
    }
}
