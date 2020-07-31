//
//  LoginView.swift
//  Strafen
//
//  Created by Steven on 27.06.20.
//

import SwiftUI

/// First View in login
struct LoginEntryView: View {
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// State of internet connection
    @State var connectionState: ConnectionState = .loading
    
    var body: some View {
        VStack(spacing: 0) {
            switch connectionState {
            case .loading:
                
                // Loading
                ZStack {
                    colorScheme.backgroundColor
                    ProgressView("Laden")
                }.edgesIgnoringSafeArea(.all)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failed:
                
                // No internet connection
                ZStack {
                    colorScheme.backgroundColor
                    VStack(spacing: 30) {
                        Spacer()
                        Text("Keine Internetverbindung")
                            .font(.text(25))
                            .foregroundColor(.textColor)
                            .padding(.horizontal, 15)
                            .multilineTextAlignment(.center)
                        Text("Erneut versuchen")
                            .font(.text(25))
                            .foregroundColor(Color.custom.red)
                            .padding(.horizontal, 15)
                            .multilineTextAlignment(.center)
                            .onTapGesture(perform: fetchLists)
                        Spacer()
                    }
                }.edgesIgnoringSafeArea(.all)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .passed:
                LoginView()
            }
        }.onAppear {
            fetchLists()
        }
    }
    
    /// Fetch all list data
    func fetchLists() {
        connectionState = .loading
        ListData.club.list = nil
        ListData.club.fetch {
            connectionState = .passed
        } failedHandler: {
            connectionState = .failed
        }
    }
}

/// View  for login
struct LoginView: View {
    
    /// Types of email login error
    enum EmailLoginErrorType {
        
        /// Wrong password
        case wrongPassword
        
        /// Person not registriered
        case notRegistriered
    }
    
    /// Input email
    @State var email = ""
    
    /// Input password
    @State var password = ""
    
    /// Used to indicate whether signIn sheet is displayed or not
    @State var showSignInSheet = false
    
    /// Alert if email login fails
    @State var emailLoginAlert = false
    
    /// Type of email login error
    @State var emailLoginErrorType: EmailLoginErrorType = .wrongPassword
    
    /// Club list data
    @ObservedObject var clubListData = ListData.club
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Active home tab
    @ObservedObject var homeTabs = HomeTabs.shared
    
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
                CustomTextField("Email", text: $email, keyboardType: .emailAddress)
                    .frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
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
                    .frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                    .padding(.top, 5)
            }.padding(.top, 20)
            
            // "oder" Text
            Text("oder")
                .foregroundColor(.textColor)
                .font(.text(20))
                .padding(.top, 20)
            
            // TODO Login with Apple Button
            Outline()
                .frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
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
                if let club = clubListData.list!.first(where: { $0.allPersons.contains(where: { ($0.login.personLogin as? PersonLoginEmail)?.email == email }) }) {
                    let person = club.allPersons.first(where: { ($0.login.personLogin as? PersonLoginEmail)?.email == email })!
                    if (person.login.personLogin as! PersonLoginEmail).password == password.encrypted {
                        Settings.shared.person = .init(id: person.id, name: person.personName, clubId: club.id, clubName: club.name, isCashier: person.isCashier)
                        homeTabs.active = .profileDetail
                    } else {
                        emailLoginErrorType = .wrongPassword
                        emailLoginAlert = true
                    }
                } else {
                    emailLoginErrorType = .notRegistriered
                    emailLoginAlert = true
                }
            }.padding(.bottom, 50)
                .alert(isPresented: $emailLoginAlert) {
                    switch emailLoginErrorType {
                    case .wrongPassword:
                        return
                            Alert(title: Text("Falsches Passwort"), message: Text("Das Passwort ist falsch."), dismissButton: .default(Text("Verstanden")))
                    case .notRegistriered:
                        return Alert(title: Text("Email Nicht Registriert"), message: Text("Diese Email ist nicht registriert."), dismissButton: .default(Text("Verstanden")))
                    }
                }
            
        }.background(colorScheme.backgroundColor)
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
