//
//  LoginView.swift
//  Strafen
//
//  Created by Steven on 10.05.21.
//

import SwiftUI
import FirebaseAuth
import FirebaseFunctions

/// Used to log in and navigate to sign in views
struct LoginView: View {

    /// Email input properties
    struct InputProperties: InputPropertiesProtocol {

        /// All input textfields
        enum TextFields: Int, TextFieldsProtocol {
            case email, password
        }

        var inputProperties = [TextFields: String]()

        var errorMessages = [TextFields: ErrorMessages]()

        var firstResponders = TextFieldFirstResponders<TextFields>()

        /// Validates the email input and sets associated error messages
        /// - Parameter setErrorMessage: Indicates whether error message will be set
        /// - Returns: result of this validation
        private mutating func validateEmail(setErrorMessage: Bool = true) -> ValidationResult {
            var errorMessage: ErrorMessages?
            if self[.email].isEmpty {
                errorMessage = .emptyField
            } else if !self[.email].isValidEmail {
                errorMessage = .invalidEmail
            } else {
                if setErrorMessage { self[error: .email] = nil }
                return .valid
            }
            if setErrorMessage { self[error: .email] = errorMessage }
            return .invalid
        }

        /// Validates the password input and sets associated error messages
        /// - Parameter setErrorMessage: Indicates whether error message will be set
        /// - Returns: result of this validation
        private mutating func validatePassword(setErrorMessage: Bool = true) -> ValidationResult {
            var errorMessage: ErrorMessages?
            if self[.password, trimm: nil].isEmpty {
                errorMessage = .emptyField
            } else {
                if setErrorMessage { self[error: .password] = nil }
                return .valid
            }
            if setErrorMessage { self[error: .password] = errorMessage }
            return .invalid
        }

        mutating func validateTextField(_ textfield: TextFields, setErrorMessage: Bool) -> ValidationResult {
            switch textfield {
            case .email: return validateEmail(setErrorMessage: setErrorMessage)
            case .password: return validatePassword(setErrorMessage: setErrorMessage)
            }
        }
    }

    enum ResetPassordMessages: Int, Identifiable {
        case invalidEmail, confirm

        var id: Int { rawValue } // swiftlint:disable:this identifier_name
    }

    /// Indicates whether email input is active
    @State var emailInputActive = false

    /// Email input properties
    @State var inputProperties = InputProperties()

    @State var resetPasswordMessage: ResetPassordMessages?

    @State var connectionState: ConnectionState = .notStarted

    /// Error message of sign in with apple
    @State var appleErrorMessage: ErrorMessages?

    /// Error message of sign in with google
    @State var googleErrorMessage: ErrorMessages?

    /// Controller for sign in with apple
    let signInAppleController = SignInAppleController()

    /// Controller for sign in with google
    let signInGoogleController = SignInGoogleController()

    var body: some View {
        NavigationView {
            ZStack {

                // Background color
                Color.backgroundGray

                // Content
                VStack(spacing: 0) {

                    // Back Button
                    HStack(spacing: 0) {
                        Text("back-button-text", comment: "Text of button to get to last page.")
                            .font(.system(size: 24, weight: .light))
                            .foregroundColor(.textColor)
                            .lineLimit(1)
                            .padding(.leading, 10)
                            .onTapGesture { emailInputActive = false }

                        Spacer()
                    }.padding(.top, emailInputActive ? 50 : -50)
                        .animation(.default, value: emailInputActive)

                    // Header
                    Header(String(localized: "log-in-header", comment: "Header of log in view."))
                        .padding(.top, emailInputActive ? 10 : 50)
                        .animation(.default, value: emailInputActive)

                    Spacer()

                    if emailInputActive {
                        ScrollView(showsIndicators: false) {
                            ScrollViewReader { proxy in
                                VStack(spacing: 15) {

                                    // Email
                                    TitledContent(String(localized: "log-in-email-title", comment: "Plain text of email for text field title.")) {
                                        CustomTextField(.email, inputProperties: $inputProperties)
                                            .placeholder(String(localized: "log-in-email-placeholder", comment: "Plain text of email for text field placeholder."))
                                            .defaultTextFieldSize
                                            .scrollViewProxy(proxy)
                                    }

                                    // Password
                                    TitledContent(String(localized: "log-in-password-title", comment: "Plain text of passwort for text field title.")) {
                                        CustomTextField(.password, inputProperties: $inputProperties)
                                            .placeholder(String(localized: "log-in-password-placeholder", comment: "Plain text of passwort for text field placeholder."))
                                            .defaultTextFieldSize
                                            .scrollViewProxy(proxy)
                                            .secure
                                    }

                                    // Forgot password button
                                    SingleOutlinedContent {
                                        Text("log-in-forget-password-button-text", comment: "Text of forgot passwort button.")
                                            .foregroundColor(.textColor)
                                            .lineLimit(1)
                                            .font(.system(size: 15, weight: .thin))
                                    }.frame(width: 200, height: 35)
                                        .padding(.top, 15)
                                        .onTapGesture(perform: handleForgotPasswordButtonPress)
                                        .alert(item: $resetPasswordMessage) { message in
                                            switch message {
                                            case .invalidEmail: return Alert(title: Text("log-in-forget-password-alert-invalid-email-title", comment: "Title of forget passwort invalid email alert."),
                                                                             message: Text("log-in-forget-password-alert-invalid-email-message", comment: "Message of forget passwort invalid email alert."),
                                                                             dismissButton: .default(Text("log-in-understood-button-text", comment: "Text of understood alert button.")) { resetPasswordMessage = nil })
                                            case .confirm: return Alert(title: Text("log-in-forget-password-alert-confirm-title", comment: "Title of forget passwort confirm alert."),
                                                                        message: Text("log-in-forget-password-alert-confirm-message-\(inputProperties[.email])", comment: "Message of forget passwort confirm alert with inputed email."),
                                                                        dismissButton: .default(Text("log-in-understood-button-text", comment: "Text of understood alert button.")) { resetPasswordMessage = nil })
                                            }
                                        }

                                }.padding(.vertical, 10)
                            }

                        }
                    } else {
                        VStack(spacing: 15) {

                            // Log in with email button
                            SingleButton(String(localized: "log-in-with-email-button-text", comment: "Text of log in with email button."))
                                .leftSymbol(name: "envelope")
                                .leftColor(.textColor)
                                .leftSymbolHeight(24)
                                .onClick { emailInputActive = true }

                            // Log in with google button
                            VStack(spacing: 5) {
                                SingleButton(String(localized: "log-in-with-google-button-text", comment: "Text of log in with google button."))
                                    .leftSymbol(Image(uiImage: #imageLiteral(resourceName: "google-icon")))
                                    .onClick(perform: handleLogInGoogleButtonPress)
                                ErrorMessageView($googleErrorMessage)
                            }

                            // Log in with apple button
                            VStack(spacing: 5) {
                                SingleButton(String(localized: "log-in-with-apple-button-text", comment: "Text of log in with apple button."))
                                    .leftSymbol(name: "applelogo")
                                    .leftColor(.white)
                                    .onClick(perform: handleLogInAppleButtonPress)
                                ErrorMessageView($appleErrorMessage)
                            }

                            // Sign in button
                            HStack(spacing: 10) {

                                Text("log-in-instead-button-text", comment: "Text of instead button, to sign in instead of log in.")
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .font(.system(size: 20, weight: .thin))

                                NavigationLink(destination: SignInView()) {
                                    SingleOutlinedContent {
                                        Text("log-in-sign-in-button-text", comment: "Text of sign in instead of log in button.")
                                            .foregroundColor(.textColor)
                                            .lineLimit(1)
                                            .font(.system(size: 20, weight: .thin))
                                    }.frame(width: 150, height: 30)
                                }

                            }.padding(.top, 15)
                        }
                    }

                    Spacer()

                    // Log in button
                    SingleButton(String(localized: "log-in-button-text", comment: "Text of log in button."))
                        .fontSize(27)
                        .rightSymbol(name: "arrow.uturn.right")
                        .rightColor(.customGreen)
                        .connectionState($connectionState)
                        .onClick(perform: handleLogInButtonPress)
                        .padding(.bottom, 55)

                }

            }.maxFrame
        }
    }

    /// Clears all error messages
    func clearErrorMessages() {
        appleErrorMessage = nil
        googleErrorMessage = nil
        inputProperties.errorMessages = [:]
    }

    /// Handles forgot password button press
    func handleForgotPasswordButtonPress() {
        guard inputProperties.validateTextField(.email) == .valid else { return resetPasswordMessage = .invalidEmail }
        Auth.auth().sendPasswordReset(withEmail: inputProperties[.email], completion: nil)
        resetPasswordMessage = .confirm
    }

    /// Handles log in with google button press
    func handleLogInGoogleButtonPress() {
        guard connectionState.restart() == .passed else { return }
        clearErrorMessages()
        signInGoogleController.handleGoogleSignIn { userId, _ in
            async {
                await getPersonProperties(userId: userId, errorMessage: $googleErrorMessage)
            }
            connectionState.passed()
        } onFailure: {
            googleErrorMessage = .internalErrorLogIn
            connectionState.failed()
        }
    }

    /// Handles log in with apple button press
    func handleLogInAppleButtonPress() {
        guard connectionState.restart() == .passed else { return }
        clearErrorMessages()
        signInAppleController.handleAppleSignIn { userId, _ in
            async {
                await getPersonProperties(userId: userId, errorMessage: $appleErrorMessage)
            }
            connectionState.passed()
        } onFailure: {
            appleErrorMessage = .internalErrorLogIn
            connectionState.failed()
        }
    }

    /// Handles log in button press tp log in with email
    func handleLogInButtonPress() async {
        guard connectionState.restart() == .passed else { return }
        clearErrorMessages()
        guard inputProperties.validateAllInputs() == .valid else {
            emailInputActive = true
            return connectionState.failed()
        }
        do {
            let result = try await Auth.auth().signIn(withEmail: inputProperties[.email], password: inputProperties[.password, trimm: nil])
            async {
                await getPersonProperties(userId: result.user.uid, errorMessage: $inputProperties[error: .email], isEmail: true)
            }
            connectionState.passed()
        } catch {
            emailInputActive = true
            connectionState.failed()
            guard (error as NSError).domain == AuthErrorDomain else { return inputProperties[error: .email] = .internalErrorLogIn }
            let errorCode = AuthErrorCode(rawValue: (error as NSError).code)
            switch errorCode {
            case .invalidEmail: inputProperties[error: .email] = .invalidEmail
            case .wrongPassword: inputProperties[error: .email] = .incorrectPassword
            default: inputProperties[error: .email] = .internalErrorLogIn
            }
        }
    }

    /// Get person properties and sets it to the settings
    /// - Parameters:
    ///   - userId: id of signed in user
    ///   - errorMessage: error message of log in method
    ///   - isEmail: true if log in with email
    func getPersonProperties(userId: String, errorMessage: Binding<ErrorMessages?>, isEmail: Bool = false) async {
        do {
            let callItem = FFGetPersonPropertiesCall(userId: userId)
            let personProperties = try await FirebaseFunctionCaller.shared.call(callItem)
            Settings.shared.person = personProperties.settingsPerson
            connectionState.passed()
        } catch {
            if isEmail { emailInputActive = true }
            connectionState.failed()
            guard (error as NSError).domain == FunctionsErrorDomain else { return errorMessage.wrappedValue = .internalErrorLogIn }
            let errorCode = FunctionsErrorCode(rawValue: (error as NSError).code)
            switch errorCode {
            case .notFound: errorMessage.wrappedValue = .notSignedIn
            default: errorMessage.wrappedValue = .internalErrorLogIn
            }
        }
    }
}
