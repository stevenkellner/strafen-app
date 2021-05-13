//
//  SignInView.swift
//  Strafen
//
//  Created by Steven on 10.05.21.
//

import SwiftUI

/// View to select different sign in methods
struct SignInView: View {
    
    /// Sign in properties if not signed in with email
    @State var signInProperties: (name: PersonNameComponents, userId: String)? = nil
    
    /// Indicates whether navigation link is active
    @State var isNavigationLinkActive = true
    
    var body: some View {
        NavigationView {
            ZStack {
                
                // Navigation View
                EmptyNavigationLink(isActive: $isNavigationLinkActive) {
                    SignInEmailView(signInProperties)
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
                            .onTapGesture {
                                signInProperties = nil
                                isNavigationLinkActive = true
                            }

                        // Sign in with google button
                        SingleButton("Mit Google registrieren")
                            .leftSymbol(Image(uiImage: #imageLiteral(resourceName: "google-icon")))

                        // Sign in with email button
                        SingleButton("Mit Apple registrieren")
                            .leftSymbol(name: "applelogo")
                            .leftColor(.white)

                        // Sign in with facebook button
                        SingleButton("Mit Facebook registrieren")
                            .leftSymbol(Image(uiImage: #imageLiteral(resourceName: "facebook-icon")))

                    }

                    Spacer()

                    // Cancel button
                    SingleButton.cancel
                        .padding(.bottom, 55)

                }
                
            }.maxFrame
        }
    }
}
