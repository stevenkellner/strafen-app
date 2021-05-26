//
//  SignInView.swift
//  Strafen
//
//  Created by Steven on 10.05.21.
//

import SwiftUI

/// View to select different sign in methods
struct SignInView: View {

    /// Presentation mode
    @Environment(\.presentationMode) private var presentationMode

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

    /// Error message of sign in with google
    @State var googleErrorMessage: ErrorMessages?

    /// Controller for sign in with apple
    let signInAppleController = SignInAppleController()

    /// Controller for sign in with google
    let signInGoogleController = SignInGoogleController()

    /// Connection state of going to the next page
    @State var connectionState: ConnectionState = .notStarted

    var body: some View {
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
                    VStack(spacing: 5) {
                        SingleButton("Mit Google registrieren")
                            .leftSymbol(Image(uiImage: #imageLiteral(resourceName: "google-icon")))
                            .onClick {
                                guard connectionState != .loading else { return }
                                clearErrorMessages()
                                signInGoogleController.handleGoogleSignIn { userId, personNameComponents in
                                    handleNextPage(userId: userId, name: personNameComponents, errorMessage: $googleErrorMessage)
                                } onFailure: {
                                    googleErrorMessage = .internalErrorSignIn(code: 1)
                                    connectionState.failed()
                                }

                            }
                        ErrorMessageView($googleErrorMessage)
                    }

                    // Sign in with apple button
                    VStack(spacing: 5) {
                        SingleButton("Mit Apple registrieren")
                            .leftSymbol(name: "applelogo")
                            .leftColor(.white)
                            .onClick {
                                guard connectionState != .loading else { return }
                                clearErrorMessages()
                                signInAppleController.handleAppleSignIn { userId, personNameComponents in
                                    handleNextPage(userId: userId, name: personNameComponents, errorMessage: $appleErrorMessage)
                                } onFailure: {
                                    appleErrorMessage = .internalErrorSignIn(code: 2)
                                    connectionState.failed()
                                }
                            }
                        ErrorMessageView($appleErrorMessage)
                    }

                }

                Spacer()

                // Cancel button
                SingleButton.cancel
                    .connectionState($connectionState)
                    .onClick { presentationMode.wrappedValue.dismiss() }
                    .padding(.bottom, 55)

            }

        }.maxFrame
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
            errorMessage.wrappedValue = .internalErrorSignIn(code: 3)
            connectionState.failed()
        }
    }

    /// Clears all error messages
    func clearErrorMessages() {
        appleErrorMessage = nil
        googleErrorMessage = nil
    }
}
