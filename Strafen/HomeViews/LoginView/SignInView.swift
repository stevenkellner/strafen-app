//
//  SignInView.swift
//  Strafen
//
//  Created by Steven on 10.05.21.
//

import SwiftUI
import AuthenticationServices
import CryptoKit
import FirebaseAuth

/// View to select different sign in methods
struct SignInView: View {

    /// Sign in properties if not signed in with email
    @State var signInProperties: (name: PersonNameComponents, userId: String)?
    
    /// Sign in properties if given name is valid
    @State var signInPropertyValidName: SignInProperty.UserIdName?

    /// Indicates whether navigation link is active
    @State var isNavigationLinkActive = false
    
    /// Indicates whether navigation link to club selection is active
    @State var isSelectClubNavigationLinkActive = false
    
    /// Error message of sign in with apple
    @State var appleErrorMessage: ErrorMessages?
    
    /// Controller for sign in with apple
    let signInAppleController = SignInAppleController()
    
    /// Connection state of going to the next page
    @State var connectionState: ConnectionState = .notStarted

    var body: some View {
        NavigationView {
            ZStack {

                // Navigation View
                EmptyNavigationLink(isActive: $isNavigationLinkActive) {
                    SignInEmailView(signInProperties)
                }
                EmptyNavigationLink(isActive: $isSelectClubNavigationLinkActive) {
                    SignInClubSelectionView(signInProperty: signInPropertyValidName ?? SignInProperty.UserIdName(userId: "", name: PersonName(firstName: "")))
                }

                // Background color
                Color.backgroundGray

                // Content
                VStack(spacing: 0) {

                    // Header
                    Header("Registrieren")
                        .padding(.top, 50)

                    Spacer()

                    VStack(spacing: 15) {

                        // Sign in with email button
                        SingleButton("Mit E-Mail registrieren")
                            .leftSymbol(name: "envelope")
                            .leftColor(.textColor)
                            .leftSymbolHeight(24)
                            .onClick {
                                guard connectionState != .loading else { return }
                                clearErrorMessages()
                                signInProperties = nil
                                signInPropertyValidName = nil
                                isSelectClubNavigationLinkActive = false
                                isNavigationLinkActive = true
                            }

                        // Sign in with google button
                        SingleButton("Mit Google registrieren")
                            .leftSymbol(Image(uiImage: #imageLiteral(resourceName: "google-icon"))) // TODO

                        // Sign in with email button
                        VStack(spacing: 5) {
                            SingleButton("Mit Apple registrieren")
                                .leftSymbol(name: "applelogo")
                                .leftColor(.white)
                                .onClick {
                                    guard connectionState != .loading else { return }
                                    clearErrorMessages()
                                    signInAppleController.handleAppleSignIn { userId, personNameComponents in
                                        handleNextPage(userId: userId, name: personNameComponents, errorMessage: $appleErrorMessage)
                                    }
                                }
                            ErrorMessageView($appleErrorMessage)
                        }

                        // Sign in with facebook button
                        SingleButton("Mit Facebook registrieren")
                            .leftSymbol(Image(uiImage: #imageLiteral(resourceName: "facebook-icon"))) // TODO

                    }

                    Spacer()

                    // Cancel button
                    SingleButton.cancel
                        .connectionState($connectionState)
                        .padding(.bottom, 55)

                }

            }.maxFrame
        }
    }

    /// Handles to go to the next page
    func handleNextPage(userId: String, name: PersonNameComponents?, errorMessage: Binding<ErrorMessages?>) {
        signInProperties = nil
        signInPropertyValidName = nil
        isNavigationLinkActive = false
        isSelectClubNavigationLinkActive = false

        guard connectionState.restart() == .passed else { return }
        let callItem = FFExistsPersonWithUserIdCall(userId: userId)
        FirebaseFunctionCaller.shared.call(callItem).then { existsPerson in
            guard !existsPerson else {
                connectionState.failed()
                return errorMessage.wrappedValue = .alreadySignedIn
            }
            if let personName = name?.personName {
                signInPropertyValidName = SignInProperty.UserIdName(userId: userId, name: personName)
                isSelectClubNavigationLinkActive = true
            } else {
                signInProperties = (name: name ?? PersonNameComponents(), userId: userId)
                isNavigationLinkActive = true
            }
            connectionState.passed()
        }.catch { _ in
            errorMessage.wrappedValue = .internalErrorSignIn
            connectionState.failed()
        }
    }
    
    /// Clears all error messages
    func clearErrorMessages() {
        appleErrorMessage = nil
    }
}

class SignInAppleController: NSObject, ASAuthorizationControllerDelegate {

    private var currentNonce: String?

    private var completionHandler: ((String, PersonNameComponents?) -> Void)?

    func handleAppleSignIn(onCompletion completionHandler: @escaping (String, PersonNameComponents?) -> Void) {
        self.completionHandler = completionHandler
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIdProvider = ASAuthorizationAppleIDProvider()
        let request = appleIdProvider.createRequest()
        request.requestedScopes = [.fullName]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }

    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: [Character] =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
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
      let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        guard let nonce = currentNonce else { fatalError("Invalid state: A login callback was received, but no login request was sent.") }
        guard let appleIDToken = appleIdCredential.identityToken else { return }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else { return }
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
        Auth.auth().signIn(with: credential) { [weak self] authResult, _ in
            guard let userId = authResult?.user.uid else { return }
            self?.completionHandler?(userId, appleIdCredential.fullName)
        }
    }
}
