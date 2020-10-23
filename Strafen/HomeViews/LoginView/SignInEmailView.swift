//
//  SignInEmailView.swift
//  Strafen
//
//  Created by Steven on 10/22/20.
//

import SwiftUI
import Combine
import FirebaseAuth

/// View for signing in with email
struct SignInEMailView: View {
    
    /// Credentials of email log in (Name, Email and Password) and errors types
    struct EmailCredentials {
        
        /// First name error type
        enum FirstNameErrorType: ErrorMessageType {
            
            /// Textfield is empty
            case emptyField
            
            /// Message of the error
            var message: String {
                switch self {
                case .emptyField:
                    return "Dieses Feld darf nicht leer sein!"
                }
            }
        }
        
        /// Last name error type
        enum LastNameErrorType: ErrorMessageType {
            
            /// Textfield is empty
            case emptyField
            
            /// Message of the error
            var message: String {
                switch self {
                case .emptyField:
                    return "Dieses Feld darf nicht leer sein!"
                }
            }
        }
        
        /// Email error type
        enum EmailErrorType: ErrorMessageType {
            
            /// Textfield is empty
            case emptyField
            
            /// Invalid email
            case invalidEmail
            
            /// Email is already signed in
            case alreadySignedIn
            
            /// Internal error
            case internalError
            
            /// Message of the error
            var message: String {
                switch self {
                case .emptyField:
                    return "Dieses Feld darf nicht leer sein!"
                case .invalidEmail:
                    return "Dies ist keine gültige Email!"
                case .alreadySignedIn:
                    return "Diese Email ist bereits registriert!"
                case .internalError:
                    return "Es gab ein Problem beim Registrieren."
                }
            }
        }
        
        /// Password error type
        enum PasswordErrorType: ErrorMessageType {
            
            /// Textfield is empty
            case emptyField
            
            /// Less than 8 characters
            case tooFewCharacters
            
            /// No upper character in Password
            case noUpperCharacter
            
            /// No lower character in Password
            case noLowerCharacter
            
            /// No digit in Password
            case noDigit
            
            /// Passwword is too weak
            case weakPassword
            
            /// Message of the error
            var message: String {
                switch self {
                case .emptyField:
                    return "Dieses Feld darf nicht leer sein!"
                case .tooFewCharacters:
                    return "Passwort ist zu kurz!"
                case .noUpperCharacter:
                    return "Muss einen Großbuchstaben enthalten!"
                case .noLowerCharacter:
                    return "Muss einen Kleinbuchstaben enthalten!"
                case .noDigit:
                    return "Muss eine Zahl enthalten!"
                case .weakPassword:
                    return "Das Passwort ist zu schwach!"
                }
            }
        }
        
        /// Repeat password error type
        enum RepeatPasswordErrorType: ErrorMessageType {
            
            /// Textfield is empty
            case emptyField
            
            /// not same password
            case notSamePassword
            
            /// Message of the error
            var message: String {
                switch self {
                case .emptyField:
                    return "Dieses Feld darf nicht leer sein!"
                case .notSamePassword:
                    return "Passwörter stimmen nicht überein!"
                }
            }
        }
        
        /// First name
        var firstName: String = ""
        
        /// Last name
        var lastName: String = ""
        
        /// Email address
        var email: String = ""
        
        /// Password
        var password: String = ""
        
        /// Repeat password
        var repeatPassword: String = ""
        
        /// Type of first name textfield error
        var firstNameErrorType: FirstNameErrorType? = nil
        
        /// Type of last name textfield error
        var lastNameErrorType: LastNameErrorType? = nil
        
        /// Type of  email textfield error
        var emailErrorType: EmailErrorType? = nil
        
        /// Type of password textfield error
        var passwordErrorType: PasswordErrorType? = nil
        
        /// Type of repeat password textfield error
        var repeatPasswordErrorType: RepeatPasswordErrorType? = nil
        
        /// Check if first name is empty
        @discardableResult mutating func evaluteFirstNameError() -> Bool {
            if firstName.isEmpty {
                firstNameErrorType = .emptyField
            } else {
                firstNameErrorType = nil
                return false
            }
            return true
        }
        
        /// Check if last name is empty
        @discardableResult mutating func evaluteLastNameError() -> Bool {
            if lastName.isEmpty {
                lastNameErrorType = .emptyField
            } else {
                lastNameErrorType = nil
                return false
            }
            return true
        }
        
        /// Check if email is empty or no valid email
        @discardableResult mutating func evaluteEmailError() -> Bool {
            if email.isEmpty {
                emailErrorType = .emptyField
            } else if !email.isValidEmail {
                emailErrorType = .invalidEmail
            } else {
                emailErrorType = nil
                return false
            }
            return true
        }
        
        /// Check if password is empty or is a valid password
        @discardableResult mutating func evalutePasswordError() -> Bool {
            let capitalPredicate = NSPredicate(format:"SELF MATCHES %@", ".*[A-Z]+.*")
            let lowerPredicate = NSPredicate(format:"SELF MATCHES %@", ".*[a-z]+.*")
            let digitPredicate = NSPredicate(format:"SELF MATCHES %@", ".*[0-9]+.*")
            if password.isEmpty {
                passwordErrorType = .emptyField
            } else if password.count < 8 {
                passwordErrorType = .tooFewCharacters
            } else if !capitalPredicate.evaluate(with: password) {
                passwordErrorType = .noUpperCharacter
            } else if !lowerPredicate.evaluate(with: password) {
                passwordErrorType = .noLowerCharacter
            } else if !digitPredicate.evaluate(with: password) {
                passwordErrorType = .noDigit
            } else {
                passwordErrorType = nil
                return false
            }
            return true
        }
        
        /// Check if repeat password is empty of not the same as the password
        @discardableResult mutating func evaluteRepeatPasswordError() -> Bool {
            if repeatPassword.isEmpty {
                repeatPasswordErrorType = .emptyField
            } else if repeatPassword != password {
                repeatPasswordErrorType = .notSamePassword
            } else {
                repeatPasswordErrorType = nil
                return false
            }
            return true
        }
        
        /// Check if any errors occurs
        mutating func checkErrors() -> Bool {
            evaluteFirstNameError()
                || evaluteLastNameError()
                || evaluteEmailError()
                || evalutePasswordError()
                || evaluteRepeatPasswordError()
        }
        
        /// Checks if an error occured while signing in
        mutating func evaluteErrorCode(of error: Error) {
            let errorCode = AuthErrorCode(rawValue: error._code)
            switch errorCode {
            case .invalidEmail:
                emailErrorType = .invalidEmail
            case .emailAlreadyInUse:
                emailErrorType = .alreadySignedIn
            case .weakPassword:
                passwordErrorType = .weakPassword
            default:
                emailErrorType = .internalError
            }
        }
    }
    
    /// Credentials of email log in (Name, Email and Password)
    @State var emailCredentials = EmailCredentials()
    
    /// State of connection
    @State var connectionState: ConnectionState = .passed
    
    /// Indicates if club selection navigation link is active
    @State var isClubSelectionNavigationLinkActive = false
    
    /// Size of sign in email view
    @State var screenSize: CGSize?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                // Navigation link to club selection
                EmptyNavigationLink(swipeBack: false, isActive: $isClubSelectionNavigationLinkActive) {
                    Text("Club Selection") // TODO
                }
                
                // Back button
                BackButton()
                
                VStack(spacing: 0) {
                    
                    // Bar to wipe sheet down
                    SheetBar()
                                    
                    // Header
                    Header("Registrieren")
                        .padding(.top, 30)
                    
                    // Textfields for form input
                    FormInputs(emailCredentials: $emailCredentials)
                    
                    Spacer()
                    
                    // Confirm button
                    ConfirmButton("Weiter", connectionState: $connectionState, buttonHandler: handleConfirmButton)
                        .padding(.bottom, 50)
                    
                }
            }.screenSize(screenSize, geometry: geometry) {
                screenSize = geometry.size
            }
        }.onAppear(perform: changeAppereanceStyle)
    }
    
    /// Handles confirm button click
    func handleConfirmButton() {
        return isClubSelectionNavigationLinkActive = true
        guard connectionState != .loading else { return }
        connectionState = .loading
        
        if emailCredentials.checkErrors() {
            connectionState = .failed
        } else {
            Auth.auth().createUser(withEmail: emailCredentials.email, password: emailCredentials.password) { result, error in
                if let error = error {
                    emailCredentials.evaluteErrorCode(of: error)
                    connectionState = .failed
                } else if let user = result?.user {
                    let personName = PersonName(firstName: emailCredentials.firstName, lastName: emailCredentials.lastName  )
                    let cacheProperty = SignInCache.PropertyUserIdName(userId: user.uid, name: personName)
                    let state: SignInCache.Status = .clubSelection(property: cacheProperty)
                    SignInCache.shared.setState(to: state)
                    isClubSelectionNavigationLinkActive = true
                    connectionState = .passed
                } else {
                    emailCredentials.emailErrorType = .internalError
                    connectionState = .failed
                }
            }
        }
    }
    
    /// Textfields for name, email and password input
    struct FormInputs: View {
        
        /// Credentials of email log in (Name, Email and Password)
        @Binding var emailCredentials: EmailCredentials
        
        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Name input
                    VStack(spacing: 10) {
                        
                        // First name input
                        VStack(spacing: 5) {
                            
                            // Title
                            Title("Name")
                            
                            // Text Field
                            CustomTextField("Vorname", text: $emailCredentials.firstName, errorType: $emailCredentials.firstNameErrorType) {
                                emailCredentials.evaluteFirstNameError()
                            }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                            
                            // Error Message
                            ErrorMessages(errorType: $emailCredentials.firstNameErrorType)
                            
                        }
                        
                        // Last name input
                        VStack(spacing: 5) {
                            
                            // Text Field
                            CustomTextField("Nachname", text: $emailCredentials.lastName, errorType: $emailCredentials.lastNameErrorType) {
                                emailCredentials.evaluteLastNameError()
                            }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                            
                            // Error Message
                            ErrorMessages(errorType: $emailCredentials.lastNameErrorType)
                            
                        }
                        
                    }
                    
                    // Email input
                    VStack(spacing: 5) {
                        
                        // Title
                        Title("Email")
                        
                        // Text Field
                        CustomTextField("Email", text: $emailCredentials.email, keyboardType: .emailAddress, errorType: $emailCredentials.emailErrorType) {
                            emailCredentials.evaluteEmailError()
                        }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                        
                        // Error Message
                        ErrorMessages(errorType: $emailCredentials.emailErrorType)
                        
                    }
                    
                    // Password input
                    VStack(spacing: 10) {
                        
                        // Password input
                        VStack(spacing: 5) {
                            
                            // Title
                            Title("Passwort")
                            
                            // Text Field
                            CustomSecureField(text: $emailCredentials.password, placeholder: "Passwort", errorType: $emailCredentials.passwordErrorType) {
                                emailCredentials.evalutePasswordError()
                            }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                            
                            // Error Message
                            ErrorMessages(errorType: $emailCredentials.passwordErrorType)
                            
                        }
                        
                        // Repeat password input
                        VStack(spacing: 5) {
                            
                            // Text Field
                            CustomSecureField(text: $emailCredentials.repeatPassword, placeholder: "Passwort Wiederholen", errorType: $emailCredentials.repeatPasswordErrorType) {
                                emailCredentials.evaluteRepeatPasswordError()
                            }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                            
                            // Error Message
                            ErrorMessages(errorType: $emailCredentials.repeatPasswordErrorType)
                            
                        }
                        
                    }
                    
                }.padding(.vertical, 10)
                    .keyboardAdaptiveOffset
            }.padding(.vertical, 10)
        }
    }
}
