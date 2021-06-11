//
//  SignInEmailViewTests.swift
//  StrafenTests
//
//  Created by Steven on 18.05.21.
//

import XCTest
import SwiftUI
import FirebaseAuth
@testable import Strafen

class SignInEmailViewTests: XCTestCase {

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

    /// Tests with user id and no name given
    func testWithUserIdOnlyNoName() async {
        var inputProperties = SignInEmailView.InputProperties()
        inputProperties.inputProperties = [.email: "Email"]
        let inputBinding = Binding<SignInEmailView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        await SignInEmailView.handleContinueButtonPress(userId: "UserId", inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.firstName: .emptyField])
    }

    /// Tests with user id and only first name
    func testWithUserIdOnlyFirstName() async {
        var inputProperties = SignInEmailView.InputProperties()
        inputProperties.inputProperties = [.firstName: "FirstName"]
        let inputBinding = Binding<SignInEmailView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        await SignInEmailView.handleContinueButtonPress(userId: "UserId", inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .passed)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertEqual(inputProperties.signInProperty, SignInProperty.UserIdName(userId: "UserId", name: PersonName(firstName: "FirstName")))
    }

    /// Tests with user id and full name
    func testWithUserIdOnlyFullName() async {
        var inputProperties = SignInEmailView.InputProperties()
        inputProperties.inputProperties = [.firstName: "FirstName", .lastName: "LastName"]
        let inputBinding = Binding<SignInEmailView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        await SignInEmailView.handleContinueButtonPress(userId: "UserId", inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .passed)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertEqual(inputProperties.signInProperty, SignInProperty.UserIdName(userId: "UserId", name: PersonName(firstName: "FirstName", lastName: "LastName")))
    }

    /// Tests without user id and no first name
    func testWithoutUserIdNoFirstName() async {
        var inputProperties = SignInEmailView.InputProperties()
        inputProperties.inputProperties = [.email: "test.email@mail.de", .password: "Aa123456", .repeatPassword: "Aa123456"]
        let inputBinding = Binding<SignInEmailView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        await SignInEmailView.handleContinueButtonPress(userId: nil, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.firstName: .emptyField])
    }

    /// Tests without user id and no email
    func testWithoutUserIdNoEmail() async {
        var inputProperties = SignInEmailView.InputProperties()
        inputProperties.inputProperties = [.firstName: "FirstName", .password: "Aa123456", .repeatPassword: "Aa123456"]
        let inputBinding = Binding<SignInEmailView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        await SignInEmailView.handleContinueButtonPress(userId: nil, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.email: .emptyField])
    }

    /// Tests without user id and invalid email
    func testWithoutUserIdNotAValidEmail() async {
        var inputProperties = SignInEmailView.InputProperties()
        inputProperties.inputProperties = [.firstName: "FirstName", .email: "invalid", .password: "Aa123456", .repeatPassword: "Aa123456"]
        let inputBinding = Binding<SignInEmailView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        await SignInEmailView.handleContinueButtonPress(userId: nil, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.email: .invalidEmail])
    }

    /// Tests without user id and no password
    func testWithoutUserIdNoPassword() async {
        var inputProperties = SignInEmailView.InputProperties()
        inputProperties.inputProperties = [.firstName: "FirstName", .email: "test.email@mail.de", .repeatPassword: "Aa123456"]
        let inputBinding = Binding<SignInEmailView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        await SignInEmailView.handleContinueButtonPress(userId: nil, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.password: .emptyField, .repeatPassword: .notSamePassword])
    }

    /// Tests without user id and too short password
    func testWithoutUserIdTooShortPassword() async {
        var inputProperties = SignInEmailView.InputProperties()
        inputProperties.inputProperties = [.firstName: "FirstName", .email: "test.email@mail.de", .password: "Aa1234", .repeatPassword: "Aa123456"]
        let inputBinding = Binding<SignInEmailView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        await SignInEmailView.handleContinueButtonPress(userId: nil, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.password: .tooFewCharacters, .repeatPassword: .notSamePassword])
    }

    /// Tests without user id and no uppercase password
    func testWithoutUserIdNoUppercasePassword() async {
        var inputProperties = SignInEmailView.InputProperties()
        inputProperties.inputProperties = [.firstName: "FirstName", .email: "test.email@mail.de", .password: "aa123456", .repeatPassword: "Aa123456"]
        let inputBinding = Binding<SignInEmailView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        await SignInEmailView.handleContinueButtonPress(userId: nil, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.password: .noUpperCharacter, .repeatPassword: .notSamePassword])
    }

    /// Tests without user id and no lowercase password
    func testWithoutUserIdNoLowercasePassword() async {
        var inputProperties = SignInEmailView.InputProperties()
        inputProperties.inputProperties = [.firstName: "FirstName", .email: "test.email@mail.de", .password: "AA123456", .repeatPassword: "Aa123456"]
        let inputBinding = Binding<SignInEmailView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        await SignInEmailView.handleContinueButtonPress(userId: nil, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.password: .noLowerCharacter, .repeatPassword: .notSamePassword])
    }

    /// Tests without user id and no number password
    func testWithoutUserIdNoNumberPassword() async {
        var inputProperties = SignInEmailView.InputProperties()
        inputProperties.inputProperties = [.firstName: "FirstName", .email: "test.email@mail.de", .password: "AaAaAaAa", .repeatPassword: "Aa123456"]
        let inputBinding = Binding<SignInEmailView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        await SignInEmailView.handleContinueButtonPress(userId: nil, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.password: .noDigit, .repeatPassword: .notSamePassword])
    }

    /// Tests without user id and no reapeat password
    func testWithoutUserIdNoRepeatPassword() async {
        var inputProperties = SignInEmailView.InputProperties()
        inputProperties.inputProperties = [.firstName: "FirstName", .email: "test.email@mail.de", .password: "Aa123456"]
        let inputBinding = Binding<SignInEmailView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        await SignInEmailView.handleContinueButtonPress(userId: nil, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.repeatPassword: .emptyField])
    }

    /// Tests without user id and invalid repeat password
    func testWithoutUserIdInvalidRepeatPassword() async {
        var inputProperties = SignInEmailView.InputProperties()
        inputProperties.inputProperties = [.firstName: "FirstName", .email: "test.email@mail.de", .password: "Aa123456", .repeatPassword: "Aa12345"]
        let inputBinding = Binding<SignInEmailView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        await SignInEmailView.handleContinueButtonPress(userId: nil, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.repeatPassword: .notSamePassword])
    }

    /// Test without user id and already signed in email
    func testWithoutUserIdSameEmail() async {
        var inputProperties = SignInEmailView.InputProperties()
        inputProperties.inputProperties = [.firstName: "FirstName", .email: "app.demo@web.de", .password: "Aa123456", .repeatPassword: "Aa123456"]
        let inputBinding = Binding<SignInEmailView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        await SignInEmailView.handleContinueButtonPress(userId: nil, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.email: .alreadySignedInEmail])
    }

    /// Test without user id
    func testWithoutUserId() async throws {
        var inputProperties = SignInEmailView.InputProperties()
        inputProperties.inputProperties = [.firstName: "FirstName", .email: "test.email@asdf.com", .password: "Aa123456", .repeatPassword: "Aa123456"]
        let inputBinding = Binding<SignInEmailView.InputProperties> { inputProperties } set: { inputProperties = $0 }
        await SignInEmailView.handleContinueButtonPress(userId: nil, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .passed)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertEqual(inputProperties.signInProperty?.name.firstName, "FirstName")

        // Sign user out again
        XCTAssertEqual(Auth.auth().currentUser?.uid, inputProperties.signInProperty?.userId)
        guard let user = Auth.auth().currentUser,
              user.uid == inputProperties.signInProperty?.userId else { return }
        let error: Error? = try waitExpectation { handler in
            user.delete(completion: handler)
        }
        XCTAssertNil(error)
    }
}
