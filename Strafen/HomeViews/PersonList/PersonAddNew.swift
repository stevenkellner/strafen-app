//
//  PersonAddNew.swift
//  Strafen
//
//  Created by Steven on 15.07.20.
//

import SwiftUI

/// View to add a new person
struct PersonAddNew: View {
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Image of the person
    @State var image: UIImage?
    
    /// Input first Name
    @State var firstName = ""
    
    /// Input last Name
    @State var lastName = ""
    
    /// True if empty String in first name field
    @State var isFirstNameError = false
    
    /// True if empty String in last name field
    @State var isLastNameError = false
    
    /// True if keybord of firstName field is shown
    @State var isFirstNameKeyboardShown = false
    
    /// True if keybord of lastName field is shown
    @State var isLastNameKeyboardShown = false
    
    /// Indicates if cofirm button is pressed and the alert is shown
    @State var confirmAlertShown = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Bar to wipe sheet down
            SheetBar()
            
            // Title
            Header("Person Hinzufügen")
            
            // Image and Name
            VStack(spacing: 0) {
                
                // Image
                ImageSelector(image: $image)
                    .frame(width: 120, height: 120)
                    .padding(.top, 25)
                
                // First Name
                VStack(spacing: 0) {
                    
                    // Title
                    HStack(spacing: 0) {
                        Text("Name:")
                            .foregroundColor(.textColor)
                            .font(.text(20))
                            .padding(.leading, 10)
                        Spacer()
                    }
                    
                    // Text Field
                    CustomTextField("Vorname", text: $firstName, keyboardOnScreen: $isFirstNameKeyboardShown) {
                        isFirstNameError = firstName == ""
                    }.frame(width: 345, height: 50)
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
                }.padding(.top, 30)
                
                // Last Name
                VStack(spacing: 0) {
                    
                    // Text Field
                    CustomTextField("Nachname", text: $lastName, keyboardOnScreen: $isLastNameKeyboardShown) {
                        isLastNameError = lastName == ""
                    }.frame(width: 345, height: 50)
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
                    
                }.padding(.top, 10)
                    .padding(.bottom, 1)
                
            }.clipped()
                .padding(.top, 10)
                .offset(y: isFirstNameKeyboardShown ? -25 : isLastNameKeyboardShown ? -100 : 0)
            
            Spacer()
            
            CancelConfirmButton {
                presentationMode.wrappedValue.dismiss()
            } confirmButtonHandler: {
                isFirstNameError = firstName == ""
                isLastNameError = lastName == ""
                confirmAlertShown = true
            }.padding(.bottom, 50)
            .alert(isPresented: $confirmAlertShown) {
                if isFirstNameError || isLastNameError {
                    return Alert(title: Text("Eingabefehler"), message: Text("Es gab ein Fehler in der Eingabe des Namens."), dismissButton: .default(Text("Verstanden")))
                }
                return Alert(title: Text("Person Hinzufügen"), message: Text("Möchtest du diese Person wirklich hinzufügen?"), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Bestätigen"), action: {
                    
//                    let personId = UUID()
//                    TODO save person
//                    if let image = image {
//                        TODO save image
//                    }
                }))
            }

        }.background(colorScheme.backgroundColor)
    }
}
