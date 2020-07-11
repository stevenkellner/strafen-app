//
//  LoginView.swift
//  Strafen
//
//  Created by Steven on 27.06.20.
//

import SwiftUI

/// View  for login
struct LoginView: View {
    
    /// Input email
    @State var email = ""
    
    /// Input password
    @State var password = ""
    
    /// Used to indicate whether signIn sheet is displayed or not
    @State var showSignInSheet = false
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Header
            Header("Anmelden")
                .padding(.top, 50)
            
            Spacer()
            
            // Email
            VStack(spacing: 0) {
                
                // Title
                HStack(spacing: 0) {
                    Text("Email:")
                        .foregroundColor(Color.textColor)
                        .font(.text(20))
                        .padding(.leading, 10)
                    Spacer()
                }
                
                // Text Field
                CustomTextField("Email", text: $email)
                    .frame(width: 345, height: 50)
                    .padding(.top, 5)
            }
            
            // Password
            VStack(spacing: 0) {
                
                // Title
                HStack(spacing: 0) {
                    Text("Passwort:")
                        .foregroundColor(Color.textColor)
                        .font(.text(20))
                        .padding(.leading, 10)
                    Spacer()
                }
                
                // Text Field
                CustomSecureField(text: $password, placeholder: "Passwort")
                    .frame(width: 345, height: 50)
                    .padding(.top, 5)
            }.padding(.top, 20)
            
            // "oder" Text
            Text("oder")
                .foregroundColor(.textColor)
                .font(.text(20))
                .padding(.top, 20)
            
            // TODO Login with Apple Button
            Outline()
                .frame(width: 345, height: 50)
                .padding(.top, 20)
            
            // SignIn Button
            HStack(spacing: 0) {
                
                // "Stattdessen" text
                Text("Stattdessen")
                    .foregroundColor(.textColor)
                    .font(.text(20))
                
                // SignIn Button
                ZStack {
                    
                    // Outline
                    RoundedCorners()
                        .radius(settings.style == .default ? 5 : 2.5)
                        .lineWidth(settings.style.lineWidth)
                        .fillColor(settings.style.fillColor(colorScheme))
                        .strokeColor(settings.style.strokeColor(colorScheme))
                    
                    // Text
                    Text("Registrieren")
                        .foregroundColor(.textColor)
                        .font(.text(20))
                    
                }.frame(width: 150, height: 30)
                    .padding(.leading, 10)
                    .onTapGesture {
                        showSignInSheet = true
                    }
                    .sheet(isPresented: $showSignInSheet) {
                        SignInView(showSignInSheet: $showSignInSheet)
                    }
                
            }.padding(.top, 20)
            
            Spacer()
            
            // Confirm Button
            ConfirmButton("Anmelden") {
                // TODO Login
            }.padding(.bottom, 50)
            
        }.background(colorScheme.backgroundColor)
        .onAppear {
            ListData.club.fetch {
                // TODO no internet connection
            }
        }
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            // IPhone 11
            LoginView()
                .previewDevice(.init(rawValue: "iPhone 11"))
                .previewDisplayName("iPhone 11")
                .edgesIgnoringSafeArea(.all)
            
//            // IPhone 8
//            LoginView()
//                .previewDevice(.init(rawValue: "iPhone 8"))
//                .previewDisplayName("iPhone 8")
//                .edgesIgnoringSafeArea(.all)
        }
    }
}
#endif
