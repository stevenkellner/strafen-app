//
//  LoginView.swift
//  Strafen
//
//  Created by Steven on 10/18/20.
//

import SwiftUI
import FirebaseAuth

/// View  for login
struct LoginView: View {
    
    /// Credentials of email log in (Email and Password) and errors types
    struct EmailCredentials {
        
        /// Email error type
        enum EmailErrorType: ErrorMessageType {
            
            /// Email is empty
            case emptyField
            
            /// Invalid email
            case invalidEmail
            
            /// Internal error
            case internalError
            
            /// Message of the error
            var message: String {
                switch self {
                case .emptyField:
                    return "Dieses Feld darf nicht leer sein!"
                case .invalidEmail:
                    return "Diese Email-Adresse ist nicht registriert."
                case .internalError:
                    return "Es gab ein Problem beim Anmelden."
                }
            }
        }
        
        /// Password error type
        enum PasswordErrorType: ErrorMessageType {
            
            /// Password is empty
            case emptyField
            
            /// Password is incorrect
            case incorrectPassword
            
            /// Message of the error
            var message: String {
                switch self {
                case .emptyField:
                    return "Dieses Feld darf nicht leer sein!"
                case .incorrectPassword:
                    return "Das eingegebene Passwort ist falsch."
                }
            }
        }
        
        /// Email address
        var email: String = ""
        
        /// Password
        var password: String = ""
        
        /// Type of  email textfield error
        var emailErrorType: EmailErrorType? = nil
        
        /// Type of password textfield error
        var passwordErrorType: PasswordErrorType? = nil
        
        /// Checks if email and password are empty
        mutating func checkEmpty() -> Bool {
            var isEmpty = false
            if email.isEmpty {
                isEmpty = true
                emailErrorType = .emptyField
            }
            if password.isEmpty {
                isEmpty = true
                passwordErrorType = .emptyField
            }
            return isEmpty
        }
        
        /// Checks if email is empty
        mutating func evaluteEmailError() {
            if email.isEmpty {
                emailErrorType = .emptyField
            } else {
                emailErrorType = nil
            }
        }
        
        /// Checks if password is empty
        mutating func evalutePasswordError() {
            if password.isEmpty {
                passwordErrorType = .emptyField
            } else {
                passwordErrorType = nil
            }
        }
        
        /// Checks if an error occured while logging in
        mutating func evaluteErrorCode(of error: Error) {
            let errorCode = AuthErrorCode(rawValue: error._code)
            switch errorCode {
            case .invalidEmail:
                emailErrorType = .invalidEmail
            case .wrongPassword:
                passwordErrorType = .incorrectPassword
            default:
                emailErrorType = .internalError
            }
        }
        
        /// Reset error types
        mutating func resetErrorTypes() {
            emailErrorType = nil
            passwordErrorType = nil
        }
    }
    
    /// Sign in with apple error type
    enum SignInWithAppleErrorType: ErrorMessageType {
        
        /// Not signed in
        case notSignedIn
        
        /// Internal error
        case internalError
        
        /// Message of the error
        var message: String {
            switch self {
            case .notSignedIn:
                return "Du bist noch nicht registriert."
            case .internalError:
                return "Es gab ein Problem beim Anmelden."
            }
        }
    }
    
    /// Indicates if sign in sheet is shown
    @Binding var showSignInSheet: Bool
    
    /// Indicates if cached sign in view is shown
    @Binding var showCachedState: Bool
    
    /// Credentials of email log in (Email and Password)
    @State var emailCredentials = EmailCredentials()
    
    /// Sign in with apple error type
    @State var signInWithAppleErrorType: SignInWithAppleErrorType? = nil
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// UIWindow
    @Environment(\.window) var window

    /// State of internet connection
    @State var connectionState: ConnectionState = .passed
    
    /// Size of log in view
    @State var screenSize: CGSize?

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                // Header
                Header("Anmelden")
                    .padding(.top, 50)
                    
                Spacer()
                
                // Email and password input, Sign in with apple button and sign in button
                VStack(spacing: 15) {
                    
                    // Email and password input
                    EmailPasswordInput(emailCredentials: $emailCredentials)
                    
                    // "or" Text
                    Text("oder").configurate(size: 20)
                    
                    // Sign in with apple button
                    VStack(spacing: 5) {
                            
                        // Sign in with Apple button
                        SignInWithAppleButton(type: .logIn, alsoForAutomatedLogIn: true, signInHandler: handleAppleLogIn)
                            .frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                        
                        // Error Message
                        ErrorMessages(errorType: $signInWithAppleErrorType)
                            
                    }
                    
                    // Sign in button
                    SignInButton(showSignInSheet: $showSignInSheet, showCachedState: $showCachedState)
                    
                }.animation(.default)
                
                Spacer()
                
                // Confirm Button
                ConfirmButton("Anmelden", connectionState: $connectionState, buttonHandler: handleEmailLogIn)
                    .padding(.bottom, 50)
                
            }.screenSize(screenSize, geometry: geometry) {
                screenSize = geometry.size
            }
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colorScheme.backgroundColor)
    }
    
    /// Handles log in with email
    func handleEmailLogIn() {
        guard connectionState != .loading else { return }
        connectionState = .loading
        
        // Check if email and password aren't empty
        signInWithAppleErrorType = nil
        emailCredentials.resetErrorTypes()
        guard !emailCredentials.checkEmpty() else {
            return DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                connectionState = .failed
            }
        }
        
        // Sign in with email
        Auth.auth().signIn(withEmail: emailCredentials.email, password: emailCredentials.password) { _, error in
            if let error = error {
                emailCredentials.evaluteErrorCode(of: error)
                connectionState = .failed
            } else {
                connectionState = .passed
            }
        }
    }
    
    /// Handles log in with apple
    func handleAppleLogIn(result: Result<(userId: String, name: PersonNameComponents), SignInWithAppleButton.SignInWithAppleError>) {
        signInWithAppleErrorType = nil
        emailCredentials.resetErrorTypes()
        switch result {
        case .failure(_):
            signInWithAppleErrorType = .internalError
        case .success((userId: let userId, name: let name)):
            // TODO check if user is already sign in
            let notSignedIn = true
            if notSignedIn {
                let cacheProperty = SignInCache.PropertyUserId(userId: userId, name: name)
                var state: SignInCache.Status = .nameInput(property: cacheProperty)
                if let cachedStatus = SignInCache.shared.cachedStatus {
                    state = cachedStatus
                }
                SignInCache.shared.setState(to: state)
                showCachedState = true
                signInWithAppleErrorType = .notSignedIn
            } else {
                // TODO Log in
            }
        }
    }
    
    /// View to input email and password
    struct EmailPasswordInput: View {
        
        /// Credentials of email log in (Email and Password)
        @Binding var emailCredentials: EmailCredentials
        
        var body: some View {
            VStack(spacing: 15) {
                
                // Email
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
                
                // Password
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
                
            }
        }
    }
    
    /// Sign in button
    struct SignInButton: View {
        
        /// Indicates if sign in sheet is shown
        @Binding var showSignInSheet: Bool
        
        /// Indicates if cached sign in view is shown
        @Binding var showCachedState: Bool
        
        var body: some View {
            HStack(spacing: 0) {
                
                // "instead" text
                Text("Stattdessen")
                    .foregroundColor(.textColor)
                    .font(.text(20))
                
                // SignIn Button
                ZStack {
                    
                    // Outline
                    Outline()
                    
                    // Text
                    Text("Registrieren")
                        .foregroundColor(.textColor)
                        .font(.text(20))
                    
                }.frame(width: 150, height: 30)
                    .padding(.leading, 10)
                    .onTapGesture {
                        return showSignInSheet = true
                        if SignInCache.shared.cachedStatus != nil {
                            showCachedState = true
                        } else {
                            showSignInSheet = true
                        }
                    }
                    
            }
        }
    }
}
