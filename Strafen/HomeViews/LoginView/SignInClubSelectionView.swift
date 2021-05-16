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
    
    // -MARK: input properties
    
    /// Contains all properties of the textfield inputs
    struct InputProperties: InputPropertiesProtocol {
        
        /// All textfields
        enum TextFields: Int, TextFieldsProtocol {
            case clubIdentifier
        }
        
        var inputProperties = [TextFields : String]()
        
        var errorMessages = [TextFields : ErrorMessages]()
        
        var firstResponders = TextFieldFirstResponders<TextFields>()
        
        /// Validates the club identifer input and sets associated error messages
        /// - Parameter setErrorMessage: Indicates whether error message will be set
        /// - Returns: result of this validation
        private mutating func validateClubIdentifier(setErrorMessage: Bool = true) -> ValidationResult {
            var errorMessage: ErrorMessages? = nil
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
        var signInProperty: SignInProperty.UserIdNameClubId? = nil
        
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
    @State var isNavigationLinkSignInClubInputViewActive = false
    
    var body: some View {
        ZStack {
            
            // Navigation links
            if let signInProperty = inputProperties.signInProperty {
                EmptyNavigationLink {
                    Text(signInProperty.userId) // TODO
                }
            }
            EmptyNavigationLink(isActive: $isNavigationLinkSignInClubInputViewActive) {
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
                Header("Registrieren")
                    .padding(.top, 10)
                
                Spacer()
                
                VStack(spacing: 5) {
                    
                    // Club identifer input
                    TitledContent("Vereinskennung") {
                        VStack(spacing: 5) {
                            
                            HStack(spacing: 0) {
                                
                                // Textfield
                                CustomTextField(.clubIdentifier, inputProperties: $inputProperties)
                                    .placeholder("Vereinskennung")
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
                    
                    Text("Du bekommst die Kennung von deinem Trainer oder Kassier.")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .thin))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 15)
                        .lineLimit(2)
                    
                    // "or" Text
                    Text("oder")
                        .foregroundColor(.textColor)
                        .font(.system(size: 20, weight: .light))
                        .padding(15)
                        .lineLimit(2)
                    
                    SingleButton("Verein Erstellen")
                        .fontSize(24)
                        .leftSymbol(name: "plus.square")
                        .leftColor(.customBlue)
                        .onClick { isNavigationLinkSignInClubInputViewActive = true }
                    
                    Text("Wenn du der Kassier bist:\nErstelle eine neuen Verein.")
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
    func handleContinueButtonPress() {
        Self.handleContinueButtonPress(oldSignInProperty: oldSignInProperty, inputProperties: $inputProperties)
    }
    
    /// Handles the click on the continue button
    /// - Parameter oldSignInProperty: sign in property with userId and name
    /// - Parameter inputProperties: binding of the input properties
    static func handleContinueButtonPress(oldSignInProperty: SignInProperty.UserIdName, inputProperties: Binding<InputProperties>) {
        guard inputProperties.wrappedValue.connectionState.restart() == .passed else { return }
        guard inputProperties.wrappedValue.validateAllInputs() == .valid else { return }
        let callItem = FirebaseFunctionGetClubIdCall(identifier: inputProperties.wrappedValue[.clubIdentifier])
        FirebaseFunctionCaller.shared.call(callItem).then { clubId in
            inputProperties.wrappedValue.signInProperty = SignInProperty.UserIdNameClubId(oldSignInProperty, clubId: clubId)
            inputProperties.wrappedValue.connectionState.passed()
        }.catch { error in
            inputProperties.wrappedValue.evaluateErrorCode(of: error as NSError)
            inputProperties.wrappedValue.connectionState.failed()
        }
    }
}
