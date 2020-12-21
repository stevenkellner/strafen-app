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
        var firstNameErrorMessages: ErrorMessages? = nil
        
        /// Type of last name textfield error
        var lastNameErrorMessages: ErrorMessages? = nil
        
        /// Type of  email textfield error
        var emailErrorMessages: ErrorMessages? = nil
        
        /// Type of password textfield error
        var passwordErrorMessages: ErrorMessages? = nil
        
        /// Type of repeat password textfield error
        var repeatPasswordErrorMessages: ErrorMessages? = nil
        
        /// Check if first name is empty
        @discardableResult mutating func evaluteFirstNameError() -> Bool {
            if firstName.isEmpty {
                Logging.shared.log(with: .debug, "First name textfield is empty.")
                firstNameErrorMessages = .emptyField
            } else {
                firstNameErrorMessages = nil
                return false
            }
            return true
        }
        
        /// Check if last name is empty
        @discardableResult mutating func evaluteLastNameError() -> Bool {
            if lastName.isEmpty {
                Logging.shared.log(with: .debug, "Last name textfield is empty.")
                lastNameErrorMessages = .emptyField
            } else {
                lastNameErrorMessages = nil
                return false
            }
            return true
        }
        
        /// Check if email is empty or no valid email
        @discardableResult mutating func evaluteEmailError() -> Bool {
            
            // Textfield is empty
            if email.isEmpty {
                Logging.shared.log(with: .debug, "Email textfield is empty.")
                emailErrorMessages = .emptyField
                
            // Email is invalid
            } else if !email.isValidEmail {
                Logging.shared.log(with: .debug, "Given email isn't valid.")
                emailErrorMessages = .invalidEmail
                
            } else {
                emailErrorMessages = nil
                return false
            }
            return true
        }
        
        /// Check if password is empty or is a valid password
        @discardableResult mutating func evalutePasswordError() -> Bool {
            let capitalPredicate = NSPredicate(format:"SELF MATCHES %@", ".*[A-Z]+.*")
            let lowerPredicate = NSPredicate(format:"SELF MATCHES %@", ".*[a-z]+.*")
            let digitPredicate = NSPredicate(format:"SELF MATCHES %@", ".*[0-9]+.*")
            
            // Textfield is empty
            if password.isEmpty {
                Logging.shared.log(with: .debug, "Password textfield is empty.")
                passwordErrorMessages = .emptyField
                
            // Password is too short
            } else if password.count < 8 {
                Logging.shared.log(with: .debug, "Password is too short.")
                passwordErrorMessages = .tooFewCharacters
                
            // Password didn't contain an uppercased character
            } else if !capitalPredicate.evaluate(with: password) {
                Logging.shared.log(with: .debug, "Password didn't contain an uppercased character.")
                passwordErrorMessages = .noUpperCharacter
                
            // Password didn't contain a lowercased character
            } else if !lowerPredicate.evaluate(with: password) {
                Logging.shared.log(with: .debug, "Password didn't contain a lowercased character.")
                passwordErrorMessages = .noLowerCharacter
                
            // Password didn't contain a number
            } else if !digitPredicate.evaluate(with: password) {
                Logging.shared.log(with: .debug, "Password didn't contain a number.")
                passwordErrorMessages = .noDigit
                
            } else {
                passwordErrorMessages = nil
                return false
            }
            return true
        }
        
        /// Check if repeat password is empty of not the same as the password
        @discardableResult mutating func evaluteRepeatPasswordError() -> Bool {
            
            // Textfield is empty
            if repeatPassword.isEmpty {
                Logging.shared.log(with: .debug, "Email textfield is empty.")
                repeatPasswordErrorMessages = .emptyField
                
            // Doesn't match with password
            } else if repeatPassword != password {
                Logging.shared.log(with: .debug, "Repeat password doesn't match with password.")
                repeatPasswordErrorMessages = .notSamePassword
                
            } else {
                repeatPasswordErrorMessages = nil
                return false
            }
            return true
        }
        
        /// Check if any errors occurs
        mutating func checkErrors() -> Bool {
            var isError = false
            isError = evaluteFirstNameError() || isError
            isError = evaluteLastNameError() || isError
            isError = evaluteEmailError() || isError
            isError = evalutePasswordError() || isError
            isError = evaluteRepeatPasswordError() || isError
            return isError
        }
        
        /// Checks if an error occured while signing in
        mutating func evaluteErrorCode(of _error: Error) {
            
            // Get auth error code
            guard let error = _error as NSError?, error.domain == AuthErrorDomain else {
                Logging.shared.log(with: .error, "Unhandled error uccured: \(_error.localizedDescription)")
                return emailErrorMessages = .internalErrorSignIn
            }
            let errorCode = AuthErrorCode(rawValue: error.code)
            
            switch errorCode {
            
            // Invalid email
            case .invalidEmail:
                Logging.shared.log(with: .debug, "Given email isn't valid.")
                emailErrorMessages = .invalidEmail
                
            // Email is already in use
            case .emailAlreadyInUse:
                Logging.shared.log(with: .debug, "Email is already in use.")
                emailErrorMessages = .alreadySignedIn
                
            // Password is too weak
            case .weakPassword:
                Logging.shared.log(with: .debug, "Password is too weak.")
                passwordErrorMessages = .weakPassword
                
            default:
                Logging.shared.log(with: .error, "Unhandled error uccured: \(error.localizedDescription)")
                emailErrorMessages = .internalErrorSignIn
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
                    SignInClubSelection()
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
                    ConfirmButton()
                        .title("Weiter")
                        .connectionState($connectionState)
                        .onButtonPress(handleConfirmButton)
                        .padding(.bottom, 50)
                    
                }
            }.screenSize($screenSize, geometry: geometry)
        }
    }
    
    /// Handles confirm button click
    func handleConfirmButton() {
        guard connectionState != .loading else { return }
        connectionState = .loading
        Logging.shared.log(with: .info, "Sign in with email is started to handle.")
        Logging.shared.log(with: .info, "With properties: \(emailCredentials)")
        
        if emailCredentials.checkErrors() {
            connectionState = .failed
            
        // Sign in with email
        } else {
            Auth.auth().createUser(withEmail: emailCredentials.email, password: emailCredentials.password) { result, error in
                
                // Error occured
                if let error = error {
                    emailCredentials.evaluteErrorCode(of: error)
                    connectionState = .failed
                    
                // Handle sign in with email result
                } else if let user = result?.user {
                    
                    // Send verification mail
                    Auth.auth().currentUser?.sendEmailVerification { error in
                        if let error = error {
                            Logging.shared.log(with: .error, "An error occurs, that isn't handled: \(error.localizedDescription)")
                        }
                    }
                    
                    // Set cached state
                    let personName = PersonName(firstName: emailCredentials.firstName, lastName: emailCredentials.lastName)
                    let cacheProperty = SignInCache.PropertyUserIdName(userId: user.uid, name: personName)
                    let state: SignInCache.Status = .clubSelection(property: cacheProperty)
                    SignInCache.shared.setState(to: state)
                    isClubSelectionNavigationLinkActive = true
                    connectionState = .passed
                    Logging.shared.log(with: .info, "Set cached to to: \(state)")
                    
                // Internal error occurs
                } else {
                    Logging.shared.log(with: .fault, "No result and no error is given back to sign in closure.")
                    emailCredentials.emailErrorMessages = .internalErrorSignIn
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
                            CustomTextField()
                                .title("Vorname")
                                .textBinding($emailCredentials.firstName)
                                .errorMessages($emailCredentials.firstNameErrorMessages)
                                .textFieldSize(width: UIScreen.main.bounds.width * 0.95, height: 50)
                                .onCompletion {
                                    emailCredentials.evaluteFirstNameError()
                                }
                            
                        }
                        
                        // Last name input
                        CustomTextField()
                            .title("Nachname")
                            .textBinding($emailCredentials.lastName)
                            .errorMessages($emailCredentials.lastNameErrorMessages)
                            .textFieldSize(width: UIScreen.main.bounds.width * 0.95, height: 50)
                            .onCompletion {
                                emailCredentials.evaluteLastNameError()
                            }
                        
                    }
                    
                    // Email input
                    VStack(spacing: 5) {
                        
                        // Title
                        Title("Email")
                        
                        // Text Field
                        CustomTextField()
                            .title("Email")
                            .textBinding($emailCredentials.email)
                            .errorMessages($emailCredentials.emailErrorMessages)
                            .keyboardType(.emailAddress)
                            .textFieldSize(width: UIScreen.main.bounds.width * 0.95, height: 50)
                            .onCompletion {
                                emailCredentials.evaluteEmailError()
                            }
                        
                    }
                    
                    // Password input
                    VStack(spacing: 10) {
                        
                        // Password input
                        VStack(spacing: 5) {
                            
                            // Title
                            Title("Passwort")
                            
                            // Text Field
                            CustomSecureField()
                                .title("Passwort")
                                .textBinding($emailCredentials.password)
                                .errorMessages($emailCredentials.passwordErrorMessages)
                                .textFieldSize(width: UIScreen.main.bounds.width * 0.95, height: 50)
                                .onCompletion {
                                    emailCredentials.evalutePasswordError()
                                }
                            
                        }
                        
                        // Repeat password input
                        CustomSecureField()
                            .title("Passwort Wiederholen")
                            .textBinding($emailCredentials.repeatPassword)
                            .errorMessages($emailCredentials.repeatPasswordErrorMessages)
                            .textFieldSize(width: UIScreen.main.bounds.width * 0.95, height: 50)
                            .onCompletion {
                                emailCredentials.evaluteRepeatPasswordError()
                            }
                        
                    }
                    
                }.padding(.vertical, 10)
                    .keyboardAdaptiveOffset
            }.padding(.vertical, 10)
        }
    }
}
