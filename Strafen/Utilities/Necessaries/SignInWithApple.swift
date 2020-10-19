//
//  SignInWithApple.swift
//  Strafen
//
//  Created by Steven on 8/29/20.
//

import AuthenticationServices
import FirebaseAuth
import CryptoKit
import SwiftUI

/// Button to sign / log in with apple
struct SignInWithAppleButton: View {
    
    /// Button types
    enum ButtonType {
        
        /// Sign in
        case signIn
        
        /// Log in
        case logIn
        
    }
    
    enum SignInWithAppleError: Error {
        case tokenError
        case nonceError
        case firebaseError
    }
    
    /// Type of the button
    let type: ButtonType
    
    /// Also for automated logIn
    let alsoForAutomatedLogIn: Bool
    
    /// Sign in handler
    let signInHandler: (Result<(userId: String, name: PersonNameComponents), SignInWithAppleError>) -> Void
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// UI Window
    @Environment(\.window) var window: UIWindow!
    
    /// Apple sign in delegates
    @State var appleSignInDelegates: SignInWithAppleDelegates!
    
    var body: some View {
        ZStack {
            if colorScheme == .dark {
                SignInWithAppleButtonView(type: type, style: .white)
            } else {
                SignInWithAppleButtonView(type: type, style: .black)
            }
        }.onTapGesture {
                performSignIn(automated: false)
            }
            .onAppear {
                if alsoForAutomatedLogIn && SignInCache.shared.cachedStatus == nil {
                    performSignIn(automated: true)
                }
            }
    }
    
    /// Perform sign in
    func performSignIn(automated: Bool) {
        appleSignInDelegates = SignInWithAppleDelegates(window: window, signInHandler: signInHandler)
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = []
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        appleSignInDelegates.currentNonce = nonce
        if type == .signIn {
            request.requestedScopes = [.fullName]
        }
        var requests: [ASAuthorizationRequest] = [request]
        if automated {
            requests.append(ASAuthorizationPasswordProvider().createRequest())
        }
        let controller = ASAuthorizationController(authorizationRequests: requests)
        controller.delegate = appleSignInDelegates
        controller.presentationContextProvider = appleSignInDelegates
        controller.performRequests()
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

/// Button to sign / log in with apple
final class SignInWithAppleButtonView: UIViewRepresentable {
    
    /// Type of the button
    let buttonType: ASAuthorizationAppleIDButton.ButtonType
    
    /// Style of the button
    let buttonStyle: ASAuthorizationAppleIDButton.Style
    
    /// Init button with type and color scheme
    init(type: SignInWithAppleButton.ButtonType, style: ASAuthorizationAppleIDButton.Style) {
        buttonType = type == .logIn ? .signIn : .signUp
        buttonStyle = style
    }
    
    /// Make UI View
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton(type: buttonType, style: buttonStyle)
    }
      
    /// Update UI View
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}
}

class SignInWithAppleDelegates: NSObject {
    
    /// Current nonce string
    var currentNonce: String?
    
    /// UI Window
    let window: UIWindow!
    
    /// Sign in handler
    let signInHandler: (Result<(userId: String, name: PersonNameComponents), SignInWithAppleButton.SignInWithAppleError>) -> Void
    
    init(window: UIWindow?, signInHandler: @escaping (Result<(userId: String, name: PersonNameComponents), SignInWithAppleButton.SignInWithAppleError>) -> Void) {
        self.window = window
        self.signInHandler = signInHandler
    }
}

extension SignInWithAppleDelegates: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                return signInHandler(.failure(.nonceError))
            }
            guard let idTokenString = String(data: appleIdCredential.identityToken, encoding: .utf8) else {
                return signInHandler(.failure(.tokenError))
            }
            
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { result, error in
                guard let user = result?.user, error == nil else {
                    return self.signInHandler(.failure(.firebaseError))
                }
                self.signInHandler(.success((user.uid, appleIdCredential.fullName ?? PersonNameComponents())))
            }
        }
    }
}

extension SignInWithAppleDelegates: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        window
    }
}

struct WindowKey: EnvironmentKey {
  struct Value {
    weak var value: UIWindow?
  }
  
  static let defaultValue: Value = .init(value: nil)
}

extension EnvironmentValues {
  var window: UIWindow? {
    get {
        self[WindowKey.self].value
    }
    set {
        self[WindowKey.self] = .init(value: newValue)
    }
  }
}
