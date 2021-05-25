//
//  SignInGoogleController.swift
//  Strafen
//
//  Created by Steven on 22.05.21.
//

import GoogleSignIn
import FirebaseAuth

class SignInGoogleController: NSObject, GIDSignInDelegate {

    private var completionHandler: ((String, PersonNameComponents?) -> Void)?

    private var failureHandler: (() -> Void)?

    func handleGoogleSignIn(onCompletion completionHandler: @escaping (String, PersonNameComponents?) -> Void, onFailure failureHandler: @escaping () -> Void) {
        self.completionHandler = completionHandler
        self.failureHandler = failureHandler
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().presentingViewController = UIApplication.shared.windows.first?.rootViewController
        GIDSignIn.sharedInstance().signIn()
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard let authentication = user.authentication else { failureHandler?(); return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { [weak self] authResult, _ in
            guard let userId = authResult?.user.uid else { self?.failureHandler?(); return }
            var name = PersonNameComponents()
            name.givenName = user.profile.givenName
            name.familyName = user.profile.familyName
            self?.completionHandler?(userId, name)
        }
    }
}
