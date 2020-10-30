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
            if email.isEmpty {
                isEmpty = true
                emailErrorMessages = .emptyField
            }
            if password.isEmpty {
                isEmpty = true
                passwordErrorMessages = .emptyField
            }
            return isEmpty
        }
        
        /// Checks if email is empty
        mutating func evaluteEmailError() {
            if email.isEmpty {
                emailErrorMessages = .emptyField
            } else {
                emailErrorMessages = nil
            }
        }
        
        /// Checks if password is empty
        mutating func evalutePasswordError() {
            if password.isEmpty {
                passwordErrorMessages = .emptyField
            } else {
                passwordErrorMessages = nil
            }
        }
        
        /// Checks if an error occured while logging in
        mutating func evaluteErrorCode(of error: Error) {
            guard let error = error as NSError?, error.domain == AuthErrorDomain else {
                return emailErrorMessages = .internalErrorSignIn
            }
            let errorCode = AuthErrorCode(rawValue: error.code)
            switch errorCode {
            case .invalidEmail:
                emailErrorMessages = .emailNotRegistered
            case .wrongPassword:
                passwordErrorMessages = .incorrectPassword
            default:
                emailErrorMessages = .internalErrorLogIn
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
        
        // Check if email and password aren't empty
        signInWithAppleErrorMessages = nil
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
        guard connectionState != .loading else { return }
        connectionState = .loading
        
        signInWithAppleErrorMessages = nil
        emailCredentials.resetErrorTypes()
        switch result {
        case .failure(_):
            connectionState = .failed
            signInWithAppleErrorMessages = .internalErrorLogIn
        case .success((userId: let userId, name: let name)):
            let callItem = GetClubPersonIdCall(userId: userId)
            FunctionCaller.shared.call(callItem) { (result: GetClubPersonIdCall.CallResult) in
                connectionState = .passed
                // TODO Log in
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
            var state: SignInCache.Status = .nameInput(property: cacheProperty)
            if let cachedStatus = SignInCache.shared.cachedStatus {
                state = cachedStatus
            }
            SignInCache.shared.setState(to: state)
            showCachedState = true
            signInWithAppleErrorMessages = .notSignedIn
        } else {
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
