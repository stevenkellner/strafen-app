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
    
    /// Club list data
    @ObservedObject var clubListData = ListData.club
    
    /// Idetifier for sign in with apple
    @State var appleIdentifier: String?
    
    /// Person name from sign in with apple
    @State var personName: PersonName?
    
    /// Indicates if sign in with apple navigation link is active
    @State var isSignInWithAppleNavigationLinkActive = false
    
    /// Indicates if person name input is shown
    @State var showPersonNameInput = false
    
    /// First name for person name input
    @State var firstName = ""
    
    /// Last name for person name input
    @State var lastName = ""
    
    /// True if empty String in first name field
    @State var isFirstNameError = false
    
    /// True if empty String in last name field
    @State var isLastNameError = false
    
    /// Indicate whether the error alert is for 'appleId already registered' or 'error in text fields'
    @State var isErrorAlertAlreadyRegistered = false
    
    /// Inidcate whether the error alert is shown
    @State var showErrorAlert = false
    
    /// Indicates if name input keyboard is on screen
    @State var nameKeyboardOnScreen = false
    
    /// Screen size
    @State var screenSize: CGSize?
    
    var body: some View {
        NavigationView {
            ZStack {
                
                // Navigation Link for sign in with email
                NavigationLink(destination: SignInEMailView(showSignInSheet: $showSignInSheet), isActive: $showSignInEMailSheet) {
                        EmptyView()
                }.frame(width: 0, height: 0)
                
                // Navigation Link for sign in with apple
                if let personName = personName, let appleIdentifier = appleIdentifier {
                    NavigationLink(destination: SignInEMailValidationView(email: .constant(""), personName: personName, personLogin: PersonLoginApple(appleIdentifier: appleIdentifier), showSignInSheet: $showSignInSheet, state: .joinClub), isActive: $isSignInWithAppleNavigationLinkActive) {
                        EmptyView()
                    }.frame(size: .zero)
                }
                
                // Content
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        
                        // Bar to wipe sheet down
                        SheetBar()
                        
                        // Header
                        Header("Registrieren")
                            .padding(.top, 30)
                        
                        ZStack {
                        
                            // Sign in with Email and Apple
                            VStack(spacing: 0) {
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
                                    
                                }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                                    .onTapGesture {
                                        showSignInEMailSheet = true
                                    }
                                
                                // "oder" Text
                                Text("oder")
                                    .foregroundColor(.textColor)
                                    .font(.text(20))
                                    .padding(.top, 20)
                                
                                // Sign in with Apple
                                SignInWithApple(type: .signIn, alsoForAutomatedLogIn: false) { userId, personNameComponents in
                                    if clubListData.list!.flatMap(\.allPersons).contains(where: { ($0.login.personLogin as? PersonLoginApple)?.appleIdentifier == userId }) {
                                        isErrorAlertAlreadyRegistered = true
                                        showErrorAlert = true
                                    } else {
                                        appleIdentifier = userId
                                        if let personName = personNameComponents?.personName {
                                            self.personName = personName
                                            isSignInWithAppleNavigationLinkActive = true
                                        } else {
                                            firstName = personNameComponents?.givenName ?? ""
                                            lastName = personNameComponents?.familyName ?? ""
                                            withAnimation {
                                                showPersonNameInput = true
                                            }
                                        }
                                    }
                                }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                                    .padding(.top, 20)
                                
                                Spacer()
                            }.opacity(showPersonNameInput ? 0 : 1)
                                .offset(y: showPersonNameInput ? -100 : 0)
                                .clipShape(Rectangle())
                            
                            // First and last name imput
                            VStack(spacing: 0) {
                                Spacer()
                                
                                Text("Dein Name wird für die Registrierung benötigt.")
                                    .foregroundColor(.textColor)
                                    .font(.text(20))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 15)
                                
                                Spacer()
                                
                                // Title
                                HStack(spacing: 0) {
                                    Text("Name:")
                                        .foregroundColor(Color.textColor)
                                        .font(.text(20))
                                        .padding(.leading, 10)
                                    Spacer()
                                }.padding(.top, 5)
                                
                                // First name
                                CustomTextField("Vorname", text: $firstName, keyboardOnScreen: $nameKeyboardOnScreen) {
                                    isFirstNameError = firstName == ""
                                }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                                
                                // Error Text
                                if isFirstNameError {
                                    Text("Dieses Feld darf nicht leer sein!")
                                        .foregroundColor(Color.custom.red)
                                        .font(.text(20))
                                        .lineLimit(1)
                                        .padding(.horizontal, 15)
                                        .padding(.top, 5)
                                }
                                
                                // Last name
                                CustomTextField("Nachname", text: $lastName, keyboardOnScreen: $nameKeyboardOnScreen) {
                                    isLastNameError = lastName == ""
                                }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                                    .padding(.top, 10)
                                
                                // Error Text
                                if isLastNameError {
                                    Text("Dieses Feld darf nicht leer sein!")
                                        .foregroundColor(Color.custom.red)
                                        .font(.text(20))
                                        .lineLimit(1)
                                        .padding(.horizontal, 15)
                                        .padding(.top, 5)
                                }
                                
                                Spacer()
                            }.opacity(showPersonNameInput ? 1 : 0)
                                .offset(y: showPersonNameInput ? nameKeyboardOnScreen ? -100 : 0 : 100)
                                .clipShape(Rectangle())
                                .padding(.vertical, 5)
                        }.alert(isPresented: $showErrorAlert) {
                            if isErrorAlertAlreadyRegistered {
                                return Alert(title: Text("Apple-ID existiert bereit"), message: Text("Es ist bereits eine Person unter dieser Apple-ID registriert."), dismissButton: .default(Text("Verstanden")))
                            } else {
                                return Alert(title: Text("Eingabefehler"), message: Text("Es gab ein Fehler in der Eingabe des Namens."), dismissButton: .default(Text("Verstanden")))
                            }
                        }
                        
                        // Cancel and Confirm Button
                        if showPersonNameInput {
                            
                            // Cancel and Confirm Button
                            CancelConfirmButton {
                                presentationMode.wrappedValue.dismiss()
                            } confirmButtonHandler: {
                                isFirstNameError = firstName == ""
                                isLastNameError = lastName == ""
                                if isFirstNameError || isLastNameError {
                                    isErrorAlertAlreadyRegistered = false
                                    showErrorAlert = true
                                } else {
                                    personName = PersonName(firstName: firstName, lastName: lastName)
                                    isSignInWithAppleNavigationLinkActive = true
                                }
                            }.padding(.bottom, 50)
                            
                        } else {
                            
                            // Cancel Button
                            CancelButton {
                                presentationMode.wrappedValue.dismiss()
                            }.padding(.bottom, 50)
                        }
                        
                    }.frame(size: screenSize ?? geometry.size)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                screenSize = geometry.size
                            }
                        }
                }
            }.background(colorScheme.backgroundColor)
                .navigationTitle("title")
                .navigationBarHidden(true)
                .onAppear {
                    firstName = ""
                    lastName = ""
                    showPersonNameInput = false
                }
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
