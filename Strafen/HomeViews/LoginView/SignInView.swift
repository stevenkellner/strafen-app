//
//  SignInView.swift
//  Strafen
//
//  Created by Steven on 30.06.20.
//

import SwiftUI

/// View  for signIn
struct SignInView: View {
    
    /// Used to indicate whether signIn sheet is displayed or not
    @Binding var showSignInSheet: Bool
    
    /// Used to indicate whether signIn with EMail sheet is displayed or not
    @State var showSignInEMailSheet = false
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                
                // Navigation Link
                NavigationLink(destination: SignInEMailView(showSignInSheet: $showSignInSheet), isActive: $showSignInEMailSheet) {
                        EmptyView()
                }.frame(width: 0, height: 0)
                
                // Content
                VStack(spacing: 0) {
                    
                    // Bar to wipe sheet down
                    SheetBar()
                    
                    // Header
                    Header("Registrieren")
                        .padding(.top, 30)
                    
                    Spacer()
                    
                    // Sign in with Email
                    ZStack {
                        
                        // Outline
                        Outline()
                            .fillColor(Color.custom.orange)
                        
                        // Text
                        Text("Mit E-Mail Registrieren")
                            .foregroundColor(settings.style == .default ? .textColor : Color.custom.orange)
                            .font(.text(20))
                            .lineLimit(1)
                            .padding(.horizontal, 15)
                        
                    }.frame(width: 345, height: 50)
                        .onTapGesture {
                            showSignInEMailSheet = true
                        }
                    
                    // "oder" Text
                    Text("oder")
                        .foregroundColor(.textColor)
                        .font(.text(20))
                        .padding(.top, 20)
                    
                    // TODO Sign in with Apple
                    Outline()
                        .frame(width: 345, height: 50)
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    // Cancel Button
                    CancelButton {
                        presentationMode.wrappedValue.dismiss()
                    }.padding(.bottom, 50)
                    
                }
            }.background(colorScheme.backgroundColor)
                .navigationTitle("title")
                .navigationBarHidden(true)
        }
    }
}

#if DEBUG
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            // IPhone 11
            SignInView(showSignInSheet: .constant(false))
                .previewDevice(.init(rawValue: "iPhone 11"))
                .previewDisplayName("iPhone 11")
                .edgesIgnoringSafeArea(.all)
            
//            // IPhone 8
//            SignInView()
//                .previewDevice(.init(rawValue: "iPhone 8"))
//                .previewDisplayName("iPhone 8")
//                .edgesIgnoringSafeArea(.all)
        }
    }
}
#endif
