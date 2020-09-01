//
//  SignInWithApple.swift
//  Strafen
//
//  Created by Steven on 8/29/20.
//

import SwiftUI
import AuthenticationServices

/// Button to sign / log in with apple
struct SignInWithApple: View {
    
    enum ButtonType {
        case signIn
        case logIn
    }
    
    /// Type of the button
    let type: ButtonType
    
    /// Also for automated logIn
    let alsoForAutomatedLogIn: Bool
    
    /// Sign in handler
    let signInHandler: (String, PersonNameComponents?) -> ()
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// UI Window
    @Environment(\.window) var window: UIWindow?
    
    @State var appleSignInDelegates: SignInWithAppleDelegates!
    
    var body: some View {
        Group {
            if colorScheme == .dark {
                SignInWithAppleView(type: type, style: .white)
            } else {
                SignInWithAppleView(type: type, style: .black)
            }
        }.onTapGesture {
                performSignIn(automated: false)
            }
            .onAppear {
                if alsoForAutomatedLogIn {
                    performSignIn(automated: true)
                }
            }
    }
    
    /// Perform sign in
    func performSignIn(automated: Bool) {
        appleSignInDelegates = SignInWithAppleDelegates(window: window, signInHandler: signInHandler)
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = []
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
}

/// Button to sign / log in with apple
final class SignInWithAppleView: UIViewRepresentable {
    
    /// Type of the button
    let buttonType: ASAuthorizationAppleIDButton.ButtonType
    
    /// Style of the button
    let buttonStyle: ASAuthorizationAppleIDButton.Style
    
    /// Init button with type and color scheme
    init(type: SignInWithApple.ButtonType, style: ASAuthorizationAppleIDButton.Style) {
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

/// Delegate for Sign in with apple
class SignInWithAppleDelegates: NSObject {
    
    /// Sign in handler
    private let signInHandler: (String, PersonNameComponents?) -> ()
    
    /// Window
    private weak var window: UIWindow!
  
    init(window: UIWindow?, signInHandler: @escaping (String, PersonNameComponents?) -> ()) {
        self.window = window
        self.signInHandler = signInHandler
    }
}

extension SignInWithAppleDelegates: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            signInHandler(appleIdCredential.user, appleIdCredential.fullName)
        case let passwordCredential as ASPasswordCredential:
            signInHandler(passwordCredential.user, nil)
        default:
            break
        }
    }
      
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
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
