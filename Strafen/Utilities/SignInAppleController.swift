//
//  SignInAppleController.swift
//  Strafen
//
//  Created by Steven on 22.05.21.
//

import AuthenticationServices
import CryptoKit
import FirebaseAuth

class SignInAppleController: NSObject, ASAuthorizationControllerDelegate {

    private var currentNonce: String?

    private var completionHandler: ((String, PersonNameComponents?) -> Void)?

    private var failureHandler: (() -> Void)?

    func handleAppleSignIn(onCompletion completionHandler: @escaping (String, PersonNameComponents?) -> Void, onFailure failureHandler: @escaping () -> Void) {
        self.completionHandler = completionHandler
        self.failureHandler = failureHandler
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
        guard let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { failureHandler?(); return }
        guard let nonce = currentNonce else { fatalError("Invalid state: A login callback was received, but no login request was sent.") }
        guard let appleIDToken = appleIdCredential.identityToken else { failureHandler?(); return }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else { failureHandler?(); return }
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
        Auth.auth().signIn(with: credential) { [weak self] authResult, _ in
            guard let userId = authResult?.user.uid else { self?.failureHandler?(); return }
            self?.completionHandler?(userId, appleIdCredential.fullName)
        }
    }
}
