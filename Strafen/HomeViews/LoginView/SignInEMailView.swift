//
//  SignInEMailView.swift
//  Strafen
//
//  Created by Steven on 30.06.20.
//

import SwiftUI

struct SignInEMailView: View {
    
    /// Error that occurs while email input
    enum EmailError: String {
        
        /// Empty String in email field
        case emptyField = "Dieses Feld darf nicht leer sein!"
        
        /// Invalid email
        case invalidEmail = "Dies ist keine gültige Email!"
    }
    
    /// Error that occurs while password input
    enum PasswordError: String {
        
        /// Empty String in password field
        case emptyField = "Dieses Feld darf nicht leer sein!"
        
        /// no lower character in Password
        case noLowerCharacter = "Muss einen Kleinbuchstaben enthalten!"
        
        /// no upper character in Password
        case noUpperCharacter = "Muss einen Großbuchstaben enthalten!"
        
        /// no digit in Password
        case noDigit = "Muss eine Zahl enthalten!"
        
        /// less than 8 characters
        case tooFewCharacters = "Passwort ist zu kurz!"
    }
    
    /// Error that occurs while repeat password input
    enum RepeatPasswordError: String {
        
        /// Empty String in repeat password field
        case emptyField = "Dieses Feld darf nicht leer sein!"
        
        /// not same password
        case notSamePassword = "Passwörter stimmen nicht überein!"
    }
    
    /// Used to indicate whether signIn sheet is displayed or not
    @Binding var showSignInSheet: Bool
    
    /// Input first Name
    @State var firstName = "Steven" // TODO
    
    /// Input last Name
    @State var lastName = "Kellner"
    
    /// Input email
    @State var email = "steven.kellner@web.de"
    
    /// Input password
    @State var password = "Aa123456"
    
    /// Input repeat password
    @State var repeatPassword = "Aa123456"
    
    /// Indicate whether confirm button is clicked or not
    @State var confirmButtonClicked = false
    
    /// True if empty String in first name field
    @State var isFirstNameError = false
    
    /// True if empty String in last name field
    @State var isLastNameError = false
    
    /// Error that occurs while email input
    @State var emailError: EmailError?
    
    /// Error that occurs while password input
    @State var passwordError: PasswordError?
    
    /// Error that occurs while repeat password input
    @State var repeatPasswordError: RepeatPasswordError?
    
    /// Inidcate whether the error alert is shown
    @State var showErrorAlert = false
    
    /// Indicate whether the error alert is for 'email already registered' or 'error in text fields'
    @State var isErrorAlertAlreadyRegistered = false
    
    /// True if keybord of password field is shown
    @State var isPasswordKeyboardShown = false
    
    /// True if keybord of repeat password field is shown
    @State var isRepeatPasswordKeyboardShown = false
    
    /// Club list data
    @ObservedObject var clubListData = ListData.club
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// State of send mail task connection
    @State var connectionState: ConnectionState = .passed
    
    /// Indicates if no connection alert is shown
    @State var noConnectionAlert = false
    
    /// Screen size
    @State var screenSize: CGSize?
    
    var body: some View {
        ZStack {
            
            // Navigation Link
            NavigationLink(destination: SignInEMailValidationView(email: $email, personName: PersonName(firstName: firstName, lastName: lastName), personLogin: PersonLoginEmail(email: email, password: password), showSignInSheet: $showSignInSheet), isActive: $confirmButtonClicked) {
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
            
            // Content
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    
                    // Bar to wipe sheet down
                    SheetBar()
                    
                    // Header
                    Header("Registrieren")
                        .padding(.top, 30)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            
                            // First Name
                            VStack(spacing: 0) {
                                
                                // Title
                                HStack(spacing: 0) {
                                    Text("Name:")
                                        .foregroundColor(Color.textColor)
                                        .font(.text(20))
                                        .padding(.leading, 10)
                                    Spacer()
                                }
                                
                                // Text Field
                                CustomTextField("Vorname", text: $firstName) {
                                    isFirstNameError = firstName == ""
                                }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                                    .padding(.top, 5)
                                
                                // Error Text
                                if isFirstNameError {
                                    Text("Dieses Feld darf nicht leer sein!")
                                        .foregroundColor(Color.custom.red)
                                        .font(.text(20))
                                        .lineLimit(1)
                                        .padding(.horizontal, 15)
                                        .padding(.top, 5)
                                }
                                
                            }
                            
                            // Last Name
                            VStack(spacing: 0) {
                                
                                // Text Field
                                CustomTextField("Nachname", text: $lastName) {
                                    isLastNameError = lastName == ""
                                }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                                    .padding(.top, 5)
                                
                                // Error Text
                                if isLastNameError {
                                    Text("Dieses Feld darf nicht leer sein!")
                                        .foregroundColor(Color.custom.red)
                                        .font(.text(20))
                                        .lineLimit(1)
                                        .padding(.horizontal, 15)
                                        .padding(.top, 5)
                                }
                                
                            }
                            
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
                                CustomTextField("Email", text: $email, keyboardType: .emailAddress) {
                                    emailError.evaluate(email)
                                }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                                    .padding(.top, 5)
                                
                                // Error Text
                                if let emailError = emailError {
                                    Text(emailError.rawValue)
                                        .foregroundColor(Color.custom.red)
                                        .font(.text(20))
                                        .lineLimit(1)
                                        .padding(.horizontal, 15)
                                        .padding(.top, 5)
                                }
                                
                            }.padding(.top, 10)
                            
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
                                CustomSecureField(text: $password, placeholder: "Passwort", keyboardOnScreen: $isPasswordKeyboardShown) {
                                    passwordError.evaluate(password)
                                }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                                    .padding(.top, 5)
                                
                                
                                // Error Text
                                if let passwordError = passwordError {
                                    Text(passwordError.rawValue)
                                        .foregroundColor(Color.custom.red)
                                        .font(.text(20))
                                        .lineLimit(1)
                                        .padding(.horizontal, 15)
                                        .padding(.top, 5)
                                }
                                
                            }.padding(.top, 10)
                            
                            // Repeat Password
                            VStack(spacing: 0) {
                            
                                // Text Field
                                CustomSecureField(text: $repeatPassword, placeholder: "Passwort Wiederholen", keyboardOnScreen: $isRepeatPasswordKeyboardShown) {
                                    repeatPasswordError.evaluate(password, repeatPassword: repeatPassword)
                                }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                                    .padding(.top, 5)
                                
                                // Error Text
                                if let repeatPasswordError = repeatPasswordError {
                                    Text(repeatPasswordError.rawValue)
                                        .foregroundColor(Color.custom.red)
                                        .font(.text(20))
                                        .lineLimit(1)
                                        .padding(.horizontal, 15)
                                        .padding(.top, 5)
                                }
                                
                            }.padding(.bottom, isPasswordKeyboardShown ? 50 : isRepeatPasswordKeyboardShown ? 150 : 0)
                        
                        }.padding(.vertical, 10)
                    }.padding(.vertical, 10)
                    
                    Spacer()
                        .alert(isPresented: $noConnectionAlert) {
                            Alert(title: Text("Kein Internet"), message: Text("Für diese Aktion benötigst du eine Internetverbindung."), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Erneut versuchen"), action: sendMail))
                        }
                    
                    ConfirmButton("Weiter", connectionState: $connectionState) {
                        isFirstNameError = firstName == ""
                        isLastNameError = lastName == ""
                        emailError.evaluate(email)
                        passwordError.evaluate(password)
                        repeatPasswordError.evaluate(password, repeatPassword: repeatPassword)
                        if isFirstNameError || isLastNameError || emailError != nil || passwordError != nil || repeatPasswordError != nil {
                            isErrorAlertAlreadyRegistered = false
                            showErrorAlert = true
                        } else if clubListData.list!.flatMap(\.allPersons).contains(where: { ($0.login.personLogin as? PersonLoginEmail)?.email == email }) {
                            isErrorAlertAlreadyRegistered = true
                            showErrorAlert = true
                        } else {
                            sendMail()
                        }
                    }.padding(.bottom, 50)
                        .alert(isPresented: $showErrorAlert) {
                            if isErrorAlertAlreadyRegistered {
                                return Alert(title: Text("Email existiert bereit"), message: Text("Es ist bereits eine Person unter diese Email registriert."), dismissButton: .default(Text("Verstanden")))
                            } else {
                                return Alert(title: Text("Eingabefehler"), message: Text("Es gab ein Fehler in der Eingabe der Profildaten."), dismissButton: .default(Text("Verstanden")))
                            }
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
    }
    
    /// Send code mail
    func sendMail() {
        connectionState = .loading
        SendCodeMail.shared.sendMail(to: email) { taskState in
            if taskState == .passed {
                connectionState = .passed
                confirmButtonClicked = true
            } else {
                connectionState = .failed
                noConnectionAlert = true
            }
        }
    }
}

// Extension of optional EmailErrorin SignInEMailView for evalute the error
extension Optional where Wrapped == SignInEMailView.EmailError {
    
    /// Evaluates the error of the given email
    mutating func evaluate(_ email: String) {
        if email == "" {
            self = .emptyField
        } else if email.isValidEmail {
            self = nil
        } else {
            self = .invalidEmail
        }
    }
}

// Extension of optional PasswordError SignInEMailView for evalute the error
extension Optional where Wrapped == SignInEMailView.PasswordError {
    
    /// Evaluates the error of the given password
    mutating func evaluate(_ password: String) {
        let capitalPredicate = NSPredicate(format:"SELF MATCHES %@", ".*[A-Z]+.*")
        let lowerPredicate = NSPredicate(format:"SELF MATCHES %@", ".*[a-z]+.*")
        let digitPredicate = NSPredicate(format:"SELF MATCHES %@", ".*[0-9]+.*")
        if password == "" {
            self = .emptyField
        } else if password.count < 8 {
            self = .tooFewCharacters
        } else if !capitalPredicate.evaluate(with: password) {
            self = .noUpperCharacter
        } else if !lowerPredicate.evaluate(with: password) {
            self = .noLowerCharacter
        } else if !digitPredicate.evaluate(with: password) {
            self = .noDigit
        } else {
            self = nil
        }
    }
}

// Extension of optional RepeatPasswordError SignInEMailView for evalute the error
extension Optional where Wrapped == SignInEMailView.RepeatPasswordError {
    
    /// Evaluates the error of the given reapat password and password
    mutating func evaluate(_ password: String, repeatPassword: String) {
        if repeatPassword == "" {
            self = .emptyField
        } else if password == repeatPassword {
            self = nil
        } else {
            self = .notSamePassword
        }
    }
}

#if DEBUG
struct SignInEMailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {

            // IPhone 11
            SignInEMailView(showSignInSheet: .constant(false))
                .previewDevice(.init(rawValue: "iPhone 8"))
                .previewDisplayName("iPhone 8")
                .edgesIgnoringSafeArea(.all)

            // IPhone 8
//            SignInEMailView()
//                .previewDevice(.init(rawValue: "iPhone 8"))
//                .previewDisplayName("iPhone 8")
//                .edgesIgnoringSafeArea(.all)
        }
    }
}
#endif
