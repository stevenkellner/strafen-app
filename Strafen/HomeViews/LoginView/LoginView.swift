//
//  LoginView.swift
//  Strafen
//
//  Created by Steven on 10/18/20.
//

import SwiftUI
import FirebaseAuth
import FirebaseFunctions

/// View  for login
struct LoginView: View {
    
    /// Credentials of email log in (Email and Password) and errors types
    struct EmailCredentials {
        
        /// Email address
        var email: String = ""
        
        /// Password
        var password: String = ""
        
        /// Type of  email textfield error
        var emailErrorMessages: ErrorMessages? = nil
        
        /// Type of password textfield error
        var passwordErrorMessages: ErrorMessages? = nil
        
        /// Checks if email and password are empty
        mutating func checkEmpty() -> Bool {
            var isEmpty = false
            
            // Check if input email is empty
            if email.isEmpty {
                isEmpty = true
                emailErrorMessages = .emptyField
                Logging.shared.log(with: .info, "Email textfield is empty.")
            }
            
            // Check if input password is empty
            if password.isEmpty {
                isEmpty = true
                passwordErrorMessages = .emptyField
                Logging.shared.log(with: .info, "Password textfield is empty.")
            }
            
            return isEmpty
        }
        
        /// Checks if email is empty
        mutating func evaluteEmailError() {
            if email.isEmpty {
                Logging.shared.log(with: .info, "Email textfield is empty.")
                emailErrorMessages = .emptyField
            } else {
                emailErrorMessages = nil
            }
        }
        
        /// Checks if password is empty
        mutating func evalutePasswordError() {
            if password.isEmpty {
                Logging.shared.log(with: .info, "Password textfield is empty.")
                passwordErrorMessages = .emptyField
            } else {
                passwordErrorMessages = nil
            }
        }
        
        /// Checks if an error occured while logging in
        mutating func evaluteErrorCode(of _error: Error) {
            
            /// Get auth error code
            guard let error = _error as NSError?, error.domain == AuthErrorDomain else {
                Logging.shared.log(with: .error, "An error occurs, that hasn't the auth error domain: \(_error.localizedDescription)")
                return emailErrorMessages = .internalErrorSignIn
            }
            let errorCode = AuthErrorCode(rawValue: error.code)
            
            switch errorCode {
            
            // Email is invalid
            case .invalidEmail:
                emailErrorMessages = .invalidEmail
                Logging.shared.log(with: .debug, "Email is invalid.")
                
            // Wrong password
            case .wrongPassword:
                passwordErrorMessages = .incorrectPassword
                Logging.shared.log(with: .debug, "Password is incorrect.")
                
            default:
                emailErrorMessages = .internalErrorLogIn
                Logging.shared.log(with: .error, "An error occurs, that isn't handled: \(error.localizedDescription)")
            }
        }
        
        /// Reset error types
        mutating func resetErrorTypes() {
            emailErrorMessages = nil
            passwordErrorMessages = nil
        }
    }
    
    /// Indicates if sign in sheet is shown
    @Binding var showSignInSheet: Bool
    
    /// Indicates if cached sign in view is shown
    @Binding var showCachedState: Bool
    
    /// Credentials of email log in (Email and Password)
    @State var emailCredentials = EmailCredentials()
    
    /// Sign in with apple error type
    @State var signInWithAppleErrorMessages: ErrorMessages? = nil
    
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
                        ErrorMessageView(errorMessages: $signInWithAppleErrorMessages)
                            
                    }
                    
                    // Sign in button
                    SignInButton(showSignInSheet: $showSignInSheet, showCachedState: $showCachedState)
                    
                }.animation(.default)
                
                Spacer()
                
                // Confirm Button
                ConfirmButton()
                    .title("Anmelden")
                    .connectionState($connectionState)
                    .onButtonPress(handleEmailLogIn)
                    .padding(.bottom, 50)
                
            }.screenSize($screenSize, geometry: geometry)
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colorScheme.backgroundColor)
    }
    
    /// Handles log in with email
    func handleEmailLogIn() {
        guard connectionState != .loading else { return }
        connectionState = .loading
        Logging.shared.log(with: .info, "Log in with email is started to handle.")
        Logging.shared.log(with: .default, "With properties: \(emailCredentials)")
        
        // Check if email and password aren't empty
        signInWithAppleErrorMessages = nil
        emailCredentials.resetErrorTypes()
        guard !emailCredentials.checkEmpty() else {
            return DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                connectionState = .failed
            }
        }
        
        // Sign in with email
        Auth.auth().signIn(withEmail: emailCredentials.email, password: emailCredentials.password) { result, error in
            
            // Error occured
            if let error = error {
                emailCredentials.evaluteErrorCode(of: error)
                connectionState = .failed
                
            // Handle sign in with apple result
            } else if let userId = result?.user.uid {
                
                // Get properties of signed in person
                let callItem = GetPersonPropertiesCall(userId: userId)
                FunctionCaller.shared.call(callItem) { (person: GetPersonPropertiesCall.CallResult) in
                    
                    // Reset cached state and set settings person
                    Logging.shared.log(with: .info, "Get person properties call succeeded.")
                    Logging.shared.log(with: .default, "With return person: \(person)")
                    connectionState = .passed
                    SignInCache.shared.setState(to: nil)
                    NewSettings.shared.properties.person = person
                    
                } failedHandler: { error in
                    handleEmailSignInGetIdsCallError(error: error)
                    connectionState = .failed
                }
            
            // Internal error occurs
            } else {
                Logging.shared.log(with: .fault, "No result and no error is given back to sign in closure.")
                emailCredentials.emailErrorMessages = .internalErrorLogIn
                connectionState = .failed
            }
        }
    }
    
    /// Handle email sign in get ids call error
    func handleEmailSignInGetIdsCallError(error: Error) {
        if let error = error as NSError? ,
           error.domain == FunctionsErrorDomain,
           let errorCode = FunctionsErrorCode(rawValue: error.code),
           errorCode == .notFound {
            
            // Person user id isn't found in database
            Logging.shared.log(with: .error, "Person user id not found in database.")
            emailCredentials.emailErrorMessages = .notSignedIn
            
        } else {
            Logging.shared.log(with: .error, "Unhandled error uccured: \(error.localizedDescription)")
            emailCredentials.emailErrorMessages = .internalErrorLogIn
        }
    }
    
    /// Handles log in with apple
    func handleAppleLogIn(result: Result<(userId: String, name: PersonNameComponents), SignInWithAppleButton.SignInWithAppleError>) {
        guard connectionState != .loading else { return }
        connectionState = .loading
        Logging.shared.log(with: .info, "Log in with apple is started to handle.")
        Logging.shared.log(with: .default, "With result: \(result)")
        
        signInWithAppleErrorMessages = nil
        emailCredentials.resetErrorTypes()
        switch result {
        
        // Log in ended with an error
        case .failure(let error):
            connectionState = .failed
            signInWithAppleErrorMessages = .internalErrorLogIn
            Logging.shared.log(with: .error, "Unhandled error uccured: \(error.localizedDescription)")
            
        case .success((userId: let userId, name: let name)):
            
            // Get person properties from database
            let callItem = GetPersonPropertiesCall(userId: userId)
            FunctionCaller.shared.call(callItem) { (person: GetPersonPropertiesCall.CallResult) in
                
                // Reset cached state and set settings person
                Logging.shared.log(with: .info, "Get person properties call succeeded.")
                Logging.shared.log(with: .default, "With return person: \(person)")
                connectionState = .passed
                SignInCache.shared.setState(to: nil)
                NewSettings.shared.properties.person = person
                
            } failedHandler: { error in
                let cacheProperty = SignInCache.PropertyUserId(userId: userId, name: name)
                handleAppleSignInGetIdsCallError(error: error, cacheProperty: cacheProperty)
                connectionState = .failed
            }
            
        }
    }
    
    /// Handle apple sign in get ids call error
    func handleAppleSignInGetIdsCallError(error: Error, cacheProperty: SignInCache.PropertyUserId) {
        if let error = error as NSError?,
           error.domain == FunctionsErrorDomain,
           let errorCode = FunctionsErrorCode(rawValue: error.code),
           errorCode == .notFound {
            
            // Person user id isn't found in database
            Logging.shared.log(with: .error, "Person user id not found in database.")
            var state: SignInCache.Status = .nameInput(property: cacheProperty)
            if let cachedStatus = SignInCache.shared.cachedStatus {
                state = cachedStatus
            }
            SignInCache.shared.setState(to: state)
            showCachedState = true
            signInWithAppleErrorMessages = .notSignedIn
            
        } else {
            Logging.shared.log(with: .error, "Unhandled error uccured: \(error.localizedDescription)")
            signInWithAppleErrorMessages = .internalErrorLogIn
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
                
                // Password
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
                        let isCached = SignInCache.shared.cachedStatus != nil
                        Logging.shared.log(with: .info, "Sign in button pressed and \(isCached ? "something" : "nothing") is cached.")
                        if isCached {
                            showCachedState = true
                        } else {
                            showSignInSheet = true
                        }
                    }
                    
            }
        }
    }
}
