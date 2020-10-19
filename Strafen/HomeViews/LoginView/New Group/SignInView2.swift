//
//  SignInView.swift
//  Strafen
//
//  Created by Steven on 30.06.20.
//

import SwiftUI

/// View  for signIn
struct SignInView2: View {
    
    /// Types of email login alert
    enum AlertType: Int, AlertTypeProtocol {
        
        /// Input error
        case inputError
        
        /// Apple id is already registriered
        case appleIdAlreadyRegistered
        
        /// Id for Identifiable
        var id: Int { rawValue }
        
        var alert: Alert {
            switch self {
            case .inputError:
                return Alert(title: Text("Eingabefehler"), message: Text("Es gab ein Fehler in der Eingabe des Namens."), dismissButton: .default(Text("Verstanden")))
            case .appleIdAlreadyRegistered:
                return Alert(title: Text("Apple-ID existiert bereit"), message: Text("Es ist bereits eine Person unter dieser Apple-ID registriert."), dismissButton: .default(Text("Verstanden")))
            }
        }
    }
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Used to indicate whether signIn sheet is displayed or not
    @Binding var showSignInSheet: Bool
    
    /// True if empty String in first name field
    @State var isFirstNameError = false
    
    /// True if empty String in last name field
    @State var isLastNameError = false
    
    /// Idetifier for sign in with apple
    @State var appleIdentifier: String?
    
    /// First name for person name input
    @State var firstName = ""
    
    /// Last name for person name input
    @State var lastName = ""
    
    /// Person name from sign in with apple
    @State var personName: PersonName?
    
    /// Indicates if an error occurs and the type of the error
    @State var alertType: AlertType? = nil
    
    /// Indicates if person name input is shown
    @State var showPersonNameInput = false
    
    /// Indicates if sign in with apple navigation link is active
    @State var isSignInWithAppleNavigationLinkActive = false

    /// Screen size of this view
    @State var screenSize: CGSize?
    
    var body: some View {
        NavigationView {
            ZStack {
                
                // Navigation Link for sign in with apple
                if let personName = personName, let appleIdentifier = appleIdentifier {
                    EmptyNavigationLink(isActive: $isSignInWithAppleNavigationLinkActive) {
                        SignInEMailValidationView(email: .constant(""), personName: personName, personLogin: PersonLoginApple(appleIdentifier: appleIdentifier), showSignInSheet: $showSignInSheet, state: .joinClub)
                    }
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
                        
                            // Sign in with Email and Apple Buttons
                            SignInSelectView(showSignInSheet: $showSignInSheet, appleIdentifier: $appleIdentifier, firstName: $firstName, lastName: $lastName, personName: $personName, alertType: $alertType, showPersonNameInput: $showPersonNameInput, isSignInWithAppleNavigationLinkActive: $isSignInWithAppleNavigationLinkActive)
                                .opacity(showPersonNameInput ? 0 : 1)
                                .offset(y: showPersonNameInput ? -100 : 0)
                                .clipShape(Rectangle())
                            
                            // First and last name imput
                            NameInput(firstName: $firstName, lastName: $lastName, isFirstNameError: $isFirstNameError, isLastNameError: $isLastNameError)
                                .opacity(showPersonNameInput ? 1 : 0)
                                .offset(y: showPersonNameInput ?  0 : 100)
                                .clipShape(Rectangle())
                                .padding(.vertical, 5)
                            
                        }.alert(item: $alertType)
                        
                        // Cancel and Confirm Button
                        Group {
                            if showPersonNameInput {
                                CancelConfirmButton(dismiss, confirmButtonHandler: handleNameInputConfirmButton)
                            } else {
                                CancelButton(dismiss)
                            }
                        }.padding(.bottom, 50)
                        
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
    
    /// Dismiss to prvious view
    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
    
    /// Handles name input confirm button click
    func handleNameInputConfirmButton() {
        isFirstNameError = firstName.isEmpty
        isLastNameError = lastName.isEmpty
        if isFirstNameError || isLastNameError {
            alertType = .inputError
        } else {
            personName = PersonName(firstName: firstName, lastName: lastName)
            isSignInWithAppleNavigationLinkActive = true
        }
    }
    
    /// Sign in with Email and Apple Buttons
    struct SignInSelectView: View {
        
        /// Color scheme to get appearance of this device
        @Environment(\.colorScheme) var colorScheme
        
        /// Used to indicate whether signIn sheet is displayed or not
        @Binding var showSignInSheet: Bool
        
        /// Idetifier for sign in with apple
        @Binding var appleIdentifier: String?
        
        /// First name for person name input
        @Binding var firstName: String
        
        /// Last name for person name input
        @Binding var lastName: String
        
        /// Person name from sign in with apple
        @Binding var personName: PersonName?
        
        /// Indicates if an error occurs and the type of the error
        @Binding var alertType: AlertType?
        
        /// Indicates if person name input is shown
        @Binding var showPersonNameInput: Bool
        
        /// Indicates if sign in with apple navigation link is active
        @Binding var isSignInWithAppleNavigationLinkActive: Bool

        /// Used to indicate whether signIn with EMail sheet is displayed or not
        @State var showSignInEMailSheet = false
        
        /// Observed Object that contains all settings of the app of this device
        @ObservedObject var settings = Settings.shared
        
        /// Contains all data for club list
        @ObservedObject var clubListData = ListData.club
        
        /// Window
        @Environment(\.window) var window
        
        var body: some View {
            ZStack {
                
                // Navigation Link for sign in with email
                EmptyNavigationLink(isActive: $showSignInEMailSheet) {
                    SignInEMailView(showSignInSheet: $showSignInSheet)
                }
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Sign in with Email Button
                    ZStack {
                        
                        // Outline
                        Outline()
                            .fillColor(Color.custom.orange)
                        
                        // Text
                        Text("Mit E-Mail Registrieren")
                            .foregroundColor(settings: settings, plain: Color.custom.orange)
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
                    
                    // Sign in with Apple Button
                    SignInWithAppleButton(type: .signIn, alsoForAutomatedLogIn: false, signInHandler: handleSignInWithApple)
                        .frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                        .padding(.top, 20)
                    
                    Spacer()
                }
            }
        }
        
        /// Handles sign in with apple button click
        func handleSignInWithApple(result: Result<(userId: String, name: PersonNameComponents), SignInWithAppleButton.SignInWithAppleError>) {
            guard case .success((let userId, let personNameComponents)) = result else { return }
            if clubListData.list!.flatMap(\.allPersons).contains(where: { ($0.login.personLogin as? PersonLoginApple)?.appleIdentifier == userId }) {
                alertType = .appleIdAlreadyRegistered
            } else {
                appleIdentifier = userId
                if let personName = personNameComponents.personName {
                    self.personName = personName
                    isSignInWithAppleNavigationLinkActive = true
                } else {
                    firstName = personNameComponents.givenName ?? ""
                    lastName = personNameComponents.familyName ?? ""
                    withAnimation {
                        showPersonNameInput = true
                    }
                }
            }
        }
    }
    
    /// First and last name input
    struct NameInput: View {
        
        /// First name for person name input
        @Binding var firstName: String
        
        /// Last name for person name input
        @Binding var lastName: String
        
        /// True if empty String in first name field
        @Binding var isFirstNameError: Bool
        
        /// True if empty String in last name field
        @Binding var isLastNameError: Bool
        
        /// Indicates if name input keyboard is on screen
        @State var nameKeyboardOnScreen = false
        
        var body: some View {
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
                    isFirstNameError = firstName.isEmpty
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
                    isLastNameError = lastName.isEmpty
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
            }.offset(y: nameKeyboardOnScreen ? -100 : 0)
        }
    }
}
