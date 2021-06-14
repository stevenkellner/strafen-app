//
//  SignInClubSelectionView.swift
//  Strafen
//
//  Created by Steven on 13.05.21.
//

import SwiftUI
import FirebaseFunctions

/// View to select or create a new club
struct SignInClubSelectionView: View {

    // MARK: input properties

    /// Contains all properties of the textfield inputs
    struct InputProperties: InputPropertiesProtocol {

        /// All textfields
        enum TextFields: Int, TextFieldsProtocol {
            case clubIdentifier
        }

        var inputProperties = [TextFields: String]()

        var errorMessages = [TextFields: ErrorMessages]()

        var firstResponders = TextFieldFirstResponders<TextFields>()

        /// Validates the club identifer input and sets associated error messages
        /// - Parameter setErrorMessage: Indicates whether error message will be set
        /// - Returns: result of this validation
        private mutating func validateClubIdentifier(setErrorMessage: Bool = true) -> ValidationResult {
            var errorMessage: ErrorMessages?
            if self[.clubIdentifier].isEmpty {
                errorMessage = .emptyField
            } else {
                if setErrorMessage { self[error: .clubIdentifier] = nil }
                return .valid
            }
            if setErrorMessage { self[error: .clubIdentifier] = errorMessage }
            return .invalid
        }

        mutating func validateTextField(_ textfield: TextFields, setErrorMessage: Bool) -> ValidationResult {
            switch textfield {
            case .clubIdentifier: return validateClubIdentifier(setErrorMessage: setErrorMessage)
            }
        }

        /// State of continue button press
        var connectionState: ConnectionState = .notStarted

        /// Sign in property with userId and name
        var signInProperty: SignInProperty.UserIdNameClubId?

        /// Evaluates auth error and sets associated error messages
        /// - Parameter error: auth error
        mutating func evaluateErrorCode(of error: NSError) {
            guard error.domain == FunctionsErrorDomain else { return self[error: .clubIdentifier] = .internalErrorSignIn }
            let errorCode = FunctionsErrorCode(rawValue: error.code)
            switch errorCode {
            case .notFound:
                self[error: .clubIdentifier] = .clubNotExists
            default:
                self[error: .clubIdentifier] = .internalErrorSignIn
            }
        }
    }

    /// Sign in property with userId and name
    let oldSignInProperty: SignInProperty.UserIdName

    /// Init with sign in property
    /// - Parameter signInProperty: Sign in property with userId and name
    init(signInProperty: SignInProperty.UserIdName) {
        self.oldSignInProperty = signInProperty
    }

    /// All properties of the textfield inputs
    @State private var inputProperties = InputProperties()

    /// Indicates if navigation link to SignInClubInputView  is active
    @State var navigationLinkSignInClubInputViewActive = false

    var body: some View {
        ZStack {

            // Navigation links
            if let signInProperty = inputProperties.signInProperty {
                EmptyNavigationLink {
                    SignInPersonSelectionView(signInProperty: signInProperty)
                }
            }
            EmptyNavigationLink(isActive: $navigationLinkSignInClubInputViewActive) {
                SignInClubInputView(signInProperty: oldSignInProperty)
            }

            // Background color
            Color.backgroundGray

            // Content
            VStack(spacing: 0) {

                // Back button
                BackButton()
                    .padding(.top, 50)

                // Header
                Header(String(localized: "sign-in-club-selection-header", comment: "Header of sign in club selection view."))
                    .padding(.top, 10)

                Spacer()

                VStack(spacing: 5) {

                    // Club identifer input
                    TitledContent(String(localized: "sign-in-club-selection-club-identifier-title", comment: "Plain text of club identifier for text field title.")) {
                        VStack(spacing: 5) {

                            HStack(spacing: 0) {

                                // Textfield
                                CustomTextField(.clubIdentifier, inputProperties: $inputProperties)
                                    .placeholder(String(localized: "sign-in-club-selection-club-identifier-placeholder", comment: "Plain text of club identifier for text field placeholder."))
                                    .textFieldSize(width: UIScreen.main.bounds.width * 0.75, height: 50)
                                    .hideErrorMessage

                                Spacer()

                                // Paste Button
                                Button {
                                    if let pasteString = UIPasteboard.general.string {
                                        inputProperties[.clubIdentifier] = pasteString
                                        _ = inputProperties.validateTextField(.clubIdentifier)
                                    }
                                } label: {
                                    Image(systemName: "doc.on.clipboard")
                                        .font(.system(size: 30, weight: .light))
                                        .foregroundColor(.textColor)
                                }

                                Spacer()
                            }.frame(width: UIScreen.main.bounds.width * 0.95)

                            // Error message
                            ErrorMessageView($inputProperties[error: .clubIdentifier])

                        }
                    }

                    Text("sign-in-club-selection-club-identifier-from-cashier-message", comment: "Message that you get the club identifier from your cashier.")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .thin))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 15)
                        .lineLimit(2)

                    // "or" Text
                    Text("sign-in-club-selection-or-button-text", comment: "Plain text of 'or' button.")
                        .foregroundColor(.textColor)
                        .font(.system(size: 20, weight: .light))
                        .padding(15)
                        .lineLimit(2)

                    SingleButton(String(localized: "sign-in-club-selection-create-club-button-text", comment: "Text of create club button."))
                        .fontSize(24)
                        .leftSymbol(name: "plus.square")
                        .leftColor(.customBlue)
                        .onClick { navigationLinkSignInClubInputViewActive = true }

                    Text("sign-in-club-selection-you-cashier-create-club-message", comment: "Message that you as cashier can create a new club.")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .thin))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 15)
                        .lineLimit(2)

                }.padding(.vertical, 10)

                Spacer()

                // Continue button
                SingleButton.continue
                    .connectionState($inputProperties.connectionState)
                    .onClick(perform: handleContinueButtonPress)
                    .padding(.bottom, 55)

            }

        }.maxFrame
            .onAppear { inputProperties.signInProperty = nil }
    }

    /// Handles the click on the continue button
    func handleContinueButtonPress() async {
        await Self.handleContinueButtonPress(oldSignInProperty: oldSignInProperty, inputProperties: $inputProperties)
    }

    /// Handles the click on the continue button
    /// - Parameter oldSignInProperty: sign in property with userId and name
    /// - Parameter inputProperties: binding of the input properties
    /// - Parameter completionHandler: handler executed after function call was made
    static func handleContinueButtonPress(oldSignInProperty: SignInProperty.UserIdName, inputProperties: Binding<InputProperties>) async {
        guard inputProperties.wrappedValue.connectionState.restart() == .passed else { return }
        guard inputProperties.wrappedValue.validateAllInputs() == .valid else {
            return inputProperties.wrappedValue.connectionState.failed()
        }
        do {
            let callItem = FFGetClubIdCall(identifier: inputProperties.wrappedValue[.clubIdentifier])
            let clubId = try await FirebaseFunctionCaller.shared.call(callItem)
            inputProperties.wrappedValue.signInProperty = SignInProperty.UserIdNameClubId(oldSignInProperty, clubId: clubId)
            inputProperties.wrappedValue.connectionState.passed()
        } catch {
            inputProperties.wrappedValue.evaluateErrorCode(of: error as NSError)
            inputProperties.wrappedValue.connectionState.failed()
        }
    }
}
