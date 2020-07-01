//
//  SignInEMailValidationView.swift
//  Strafen
//
//  Created by Steven on 30.06.20.
//

import SwiftUI

struct SignInEMailValidationView: View {
    
    /// States of SignInEMailValidationView
    enum PageState {
        
        /// Used in email code input page
        case codeInput
        
        /// Used in club join page
        case joinClub
    }
    
    /// Input email
    @Binding var email: String
    
    /// Input Email Code
    @State var inputEmailCode = ""
    
    /// Input club code
    @State var inputClubCode = ""
    
    /// States of SignInEMailValidationView
    @State var state: PageState = .codeInput
    
    /// Indicate whether confirm button is clicked or not
    @State var confirmButtonClicked = false
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    var body: some View {
        ZStack {
            
            // Navigation Link
            NavigationLink(destination: Text("asdf"), isActive: $confirmButtonClicked) {
                    EmptyView()
            }.frame(width: 0, height: 0)
            
            // Back Button
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("Zurück")
                        .font(.text(25))
                        .foregroundColor(.textColor)
                        .padding(.leading, 15)
                        .onTapGesture {
                            presentationMode.wrappedValue.dismiss()
                        }
                    Spacer()
                }.padding(.top, 30)
                Spacer()
            }
            
            VStack(spacing: 0) {
                
                // Bar to wipe sheet down
                SheetBar()
                
                // Header
                Header("Registrieren")
                    .padding(.top, 30)
                
                // Content
                ZStack {
                    
                    // Code input page
                    VStack(spacing: 0) {
                        
                        Spacer()
                        
                        // Text
                        Text("Es wurde ein Bestätigungscode an deine E-Mail Adresse \(email) gesendet.")
                            .font(.text(25))
                            .foregroundColor(.textColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 25)
                        
                        // Codel Text Field
                        CustomTextField("Bestätigungscode", text: $inputEmailCode)
                            .frame(width: 345, height: 50)
                            .padding(.top, 50)
                        
                        Spacer()
                        
                    }.opacity(state == .codeInput ? 1 : 0)
                        .offset(y: state == .codeInput ? 0 : -100)
                    
                    // Club join page
                    VStack(spacing: 0) {
                        
                        Spacer()
                        
                        // Text
                        Text("Vereinscode eingeben.\nDu bekommst den Code von deinem Trainer oder Kassier.")
                            .font(.text(20))
                            .foregroundColor(.textColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 25)
                        
                        // Club code text field
                        CustomTextField("Vereinscode", text: $inputClubCode)
                            .frame(width: 345, height: 50)
                            .padding(.top, 30)
                        
                        Spacer()
                        
                        // Text
                        Text("Wenn du der Kassier bist:\nErstelle eine neue Strafen Liste.")
                            .font(.text(20))
                            .foregroundColor(.textColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 25)
                        
                        // Button
                        NavigationLink(destination: SignInNewClubView()) {
                            ZStack {
                                
                                // Outline
                                Outline()
                                    .fillColor(settings.style.fillColor(colorScheme, defaultStyle: Color.custom.orange))
                                
                                // Text
                                Text("Erstellen")
                                    .foregroundColor(settings.style == .default ? Color.custom.gray : Color.custom.orange)
                                    .font(.text(20))
                                    .lineLimit(1)
                                
                            }.frame(width: 345, height: 50)
                        }.padding(.top, 30)
                        
                        Spacer()
                        
                    }.opacity(state == .joinClub ? 1 : 0)
                        .offset(y: state == .joinClub ? 0 : 100)
                    
                }
                
                // Confirm Button
                ConfirmButton("Weiter") {
                    switch state {
                    case .codeInput: // TODO check code
                        withAnimation {
                            state = .joinClub
                        }
                    case .joinClub:
                        confirmButtonClicked = true
                    }
                }.padding(.bottom, 50)

            }
        }.background(colorScheme.backgroundColor)
            .navigationTitle("title")
            .navigationBarHidden(true)
    }
}

#if DEBUG
struct SignInEMailValidationView_Previews: PreviewProvider {
    static var previews: some View {
        SignInEMailValidationView(email: .constant("steven.kellner@web.de"))
            .edgesIgnoringSafeArea(.all)
    }
}
#endif
