//
//  SignInView.swift
//  Strafen
//
//  Created by Steven on 10.05.21.
//

import SwiftUI

/// View to select different sign in methods
struct SignInView: View {
    var body: some View {
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
    }
}
