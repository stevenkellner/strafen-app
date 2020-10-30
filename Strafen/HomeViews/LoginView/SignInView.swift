//
//  SignInView.swift
//  Strafen
//
//  Created by Steven on 10/19/20.
//

import SwiftUI

/// View  for signing in
struct SignInView: View {
    
    /// Indicates if sign in sheet is shown
    @Binding var showSignInSheet: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // Bar to wipe sheet down
                SheetBar()
                            
                // Header
                Header("Registrieren")
                
                Spacer()
                
                // Sign in buttons
                SignInButtonsView()
                
                Spacer()
                
                // Cancel Button
                CancelButton()
                    .onButtonPress {
                        showSignInSheet = false
                    }
                    .padding(.bottom, 50)
                
            }.navigationTitle("Title")
                .navigationBarHidden(true)
        }
    }

    /// Sign in with Email and Apple Buttons
    struct SignInButtonsView: View {
        
        /// Active navigation links
        struct ActiveNavigationLinks {
            
            /// For sign in with email
            var emailCredentialInput = false
            
            /// For name input
            var nameInput = false
            
            /// For club selection
            var clubSelction = false
            
        }
        
        /// Active navigation links
        @State var activeNavigationLinks = ActiveNavigationLinks()
        
        /// Sign in with apple error type
        @State var signInWithAppleErrorMessages: ErrorMessages? = nil
        
        var body: some View {
            ZStack {
                
                // Navigation link for sign in with email
                EmptyNavigationLink(isActive: $activeNavigationLinks.emailCredentialInput) {
                    SignInEMailView()
                }
                
                // Navigation link for name input
                EmptyNavigationLink(swipeBack: false, isActive: $activeNavigationLinks.nameInput) {
                    SignInNameInput()
                }
                
                // Navigation link for club selection
                EmptyNavigationLink(swipeBack: false, isActive: $activeNavigationLinks.clubSelction) {
                    SignInClubSelection()
                }
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    // Sign in with Email Button
                    ZStack {
                        
                        // Outline
                        Outline()
                            .fillColor(Color.custom.orange)
                        
                        // Text
                        Text("Mit E-Mail Registrieren")
                            .foregroundColor(plain: Color.custom.orange)
                            .font(.text(20))
                            .lineLimit(1)
                            .padding(.horizontal, 15)
                        
                    }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                        .onTapGesture {
                            activeNavigationLinks.emailCredentialInput = true
                        }
                    
                    // "or" Text
                    Text("oder").configurate(size: 20)
                    
                    // Sign in with Apple Button
                    SignInWithAppleButton(type: .signIn, alsoForAutomatedLogIn: false, signInHandler: handleSignInWithApple)
                        .frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                    
                    // Error Message
                    ErrorMessageView(errorMessages: $signInWithAppleErrorMessages)
                    
                    Spacer()
                }
            }
        }
        
        /// Handles sign in with apple button click
        func handleSignInWithApple(result: Result<(userId: String, name: PersonNameComponents), SignInWithAppleButton.SignInWithAppleError>) {
            signInWithAppleErrorMessages = nil
            switch result {
            case .failure(_):
                signInWithAppleErrorMessages = .internalErrorSignIn
            case .success((userId: let userId, name: let name)):
                let state: SignInCache.Status
                if let personName = name.personName {
                    let cacheProperty = SignInCache.PropertyUserIdName(userId: userId, name: personName)
                    state = .clubSelection(property: cacheProperty)
                    activeNavigationLinks.clubSelction = true
                } else {
                    let cacheProperty = SignInCache.PropertyUserId(userId: userId, name: name)
                    state = .nameInput(property: cacheProperty)
                    activeNavigationLinks.nameInput = true
                }
                SignInCache.shared.setState(to: state)
            }
        }
    }
}
