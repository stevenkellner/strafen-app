//
//  PersonEditor.swift
//  Strafen
//
//  Created by Steven on 16.07.20.
//

import SwiftUI

/// View to edit person
struct PersonEditor: View {
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Image of the person
    @State var image: UIImage?
    
    /// Edited person
    let person: Person
    
    /// Input first Name
    @State var firstName: String = ""
    
    /// Input last Name
    @State var lastName: String = ""
    
    /// True if empty String in first name field
    @State var isFirstNameError = false
    
    /// True if empty String in last name field
    @State var isLastNameError = false
    
    /// True if keybord of firstName field is shown
    @State var isFirstNameKeyboardShown = false
    
    /// True if keybord of lastName field is shown
    @State var isLastNameKeyboardShown = false
    
    /// Indicates if delete button is pressed and the alert is shown
    @State var deleteAlertShown = false
    
    /// Indicates if cofirm button is pressed and the alert is shown
    @State var confirmAlertShown = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Bar to wipe sheet down
            SheetBar()
            
            // Title
            Header("Person Ändern")
            
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
                .alert(isPresented: $deleteAlertShown) {
                    Alert(title: Text("Person Löschen"), message: Text("Möchtest du diese Person wirklich löschen?"), primaryButton: .cancel(Text("Abbrechen")), secondaryButton: .destructive(Text("Löschen"), action: {
                        // TODO delete person
                        presentationMode.wrappedValue.dismiss()
                    }))
                }
            
            DeleteConfirmButton {
                // check if person is sign in
                // TODO delete person
                // delete all fines of this person
                deleteAlertShown = true
                presentationMode.wrappedValue.dismiss()
            } confirmButtonHandler: {
                // TODO check if something changed
                isFirstNameError = firstName == ""
                isLastNameError = lastName == ""
                confirmAlertShown = true
            }.padding(.bottom, 50)
                .alert(isPresented: $confirmAlertShown) {
                    if isFirstNameError || isLastNameError {
                        return Alert(title: Text("Eingabefehler"), message: Text("Es gab ein Fehler in der Eingabe des Namens."), dismissButton: .default(Text("Verstanden")))
                    }
                    return Alert(title: Text("Person Ändern"), message: Text("Möchtest du diese Person wirklich ändern?"), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Bestätigen"), action: {
                        
    //                    TODO update person
    //                    if let image = image {
    //                        TODO update image
    //                    }
                    }))
                }

        }.background(colorScheme.backgroundColor)
            .onAppear {
                firstName = person.firstName
                lastName = person.lastName
                ImageData.shared.fetch(of: person.id) { image in
                    self.image = image
                }
            }
    }
}
