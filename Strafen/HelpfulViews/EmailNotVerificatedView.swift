//
//  EmailNotVerificatedView.swift
//  Strafen
//
//  Created by Steven on 12/19/20.
//

import SwiftUI
import FirebaseAuth

/// View if email isn't verificated
struct EmailNotVerificatedView: View {
    var body: some View {
        VStack(spacing: 0) {
            
            // Header
            Header("Nicht verifiziert")
                .padding(.top, 35)
            
            Spacer()
            
            VStack(spacing: 20) {
            
                // Text
                Text("Du hast deine Email noch nicht verifiziert. Dies ist innerhalb 30 Tage notwendig.")
                    .configurate(size: 20)
                    .padding(.horizontal, 15)
                    .lineLimit(3)
                
                // Send verification mail
                TitledContent("Email erneut senden") {
                    ZStack {
                        
                        // Outline
                        Outline()
                            .fillColor(Color.custom.orange)
                        
                        // Text
                        Text("Email senden")
                            .foregroundColor(plain: Color.custom.orange)
                            .font(.text(20))
                            .padding(.horizontal, 10)
                            .lineLimit(1)
                        
                    }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                        .onTapGesture {
                            Auth.auth().currentUser?.sendEmailVerification(completion: nil)
                        }
                }
                
            }
            
            Spacer()
            
            ConfirmButton()
                .title("Erneut versuchen")
                .onButtonPress {
                    ListData.shared.emailNotVerificated = false
                    ListData.shared.setup()
                }
                .padding(.bottom, 50)
        }
    }
}
