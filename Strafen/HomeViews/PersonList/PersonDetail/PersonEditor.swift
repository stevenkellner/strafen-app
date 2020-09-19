//
//  PersonEditor.swift
//  Strafen
//
//  Created by Steven on 16.07.20.
//

import SwiftUI

/// View to edit person
struct PersonEditor: View {
    
    /// Alert type
    enum AlertType: Int, Identifiable {
        
        /// For already sign in
        case alreadySignIn
        
        /// For delete
        case delete
        
        /// For confirm
        case confirm
        
        /// For input error
        case inputError
        
        /// Id
        var id: Int {
            rawValue
        }
    }
    
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
    
    /// Completion handler
    let completionHandler: (UIImage?) -> ()
    
    init(person: Person, _ completionHandler: @escaping (UIImage?) -> ()) {
        self.person = person
        self.completionHandler = completionHandler
    }
    
    /// Input first Name
    @State var firstName: String = ""
    
    /// Input last Name
    @State var lastName: String = ""
    
    /// Fine List Data
    @ObservedObject var fineListData = ListData.fine
    
    /// Cliub List Data
    @ObservedObject var clubListData = ListData.club
    
    /// True if empty String in first name field
    @State var isFirstNameError = false
    
    /// True if empty String in last name field
    @State var isLastNameError = false
    
    /// True if keybord of firstName field is shown
    @State var isFirstNameKeyboardShown = false
    
    /// True if keybord of lastName field is shown
    @State var isLastNameKeyboardShown = false
    
    /// Type of alert
    @State var alertType: AlertType?
    
    /// State of data task connection
    @State var connectionStateDelete: ConnectionState = .passed
    
    /// Indicates if no connection alert is shown
    @State var noConnectionAlertDelete = false
    
    /// State of data task connection
    @State var connectionStateUpdate: ConnectionState = .passed
    
    /// Indicates if no connection alert is shown
    @State var noConnectionAlertUpdate = false
    
    /// Screen size
    @State var screenSize: CGSize?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                // Bar to wipe sheet down
                SheetBar()
                
                // Title
                Header("Person Ändern")
                    .alert(isPresented: $noConnectionAlertUpdate) {
                        Alert(title: Text("Kein Internet"), message: Text("Für diese Aktion benötigst du eine Internetverbindung."), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Erneut versuchen"), action: handlePersonUpdate))
                    }
                
                // Image and Name
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Image
                    ImageSelector(image: $image)
                        .frame(width: 120, height: 120)
                    
                    Spacer()
                    
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
                    }
                    
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
                    
                    Spacer()
                    
                }.offset(y: isFirstNameKeyboardShown ? -50 : isLastNameKeyboardShown ? -125 : 0)
                    .clipped()
                    .padding(.top, 10)
                    .alert(isPresented: $noConnectionAlertDelete) {
                        Alert(title: Text("Kein Internet"), message: Text("Für diese Aktion benötigst du eine Internetverbindung."), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Erneut versuchen"), action: handlePersonDelete))
                    }
                
                DeleteConfirmButton(connectionStateDelete: $connectionStateDelete, connectionStateConfirm: $connectionStateUpdate) {
                    if clubListData.list!.first(where: { $0.id == Settings.shared.person!.clubId })!.allPersons.contains(where: { $0.id == person.id }) {
                        alertType = .alreadySignIn
                    } else {
                        alertType = .delete
                    }
                } confirmButtonHandler: {
                    connectionStateUpdate = .loading
                    ImageFetcher.shared.fetch(of: person.id) { oldImage in
                        connectionStateUpdate = .passed
                        if person.firstName == firstName && person.lastName == lastName && oldImage?.pngData() == image?.scaledTo(PersonImageChange.maxImageResolution).pngData() {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            isFirstNameError = firstName == ""
                            isLastNameError = lastName == ""
                            if isFirstNameError || isLastNameError {
                                alertType = .inputError
                            } else {
                                alertType = .confirm
                            }
                        }
                    }
                }.padding(.bottom, 50)
                    .alert(item: $alertType) { alertType in
                        switch alertType {
                        case .alreadySignIn:
                            return Alert(title: Text("Nicht löschbar"), message: Text("Diese Person kann nicht gelöschet werden, da sie bereits registriert ist."), dismissButton: .default(Text("Verstanden")))
                        case .delete:
                            return Alert(title: Text("Person Löschen"), message: Text("Möchtest du diese Person wirklich löschen?"), primaryButton: .cancel(Text("Abbrechen")), secondaryButton: .destructive(Text("Löschen"), action: handlePersonDelete))
                        case .confirm:
                            return Alert(title: Text("Person Ändern"), message: Text("Möchtest du diese Person wirklich ändern?"), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Bestätigen"), action: handlePersonUpdate))
                        case .inputError:
                            return Alert(title: Text("Eingabefehler"), message: Text("Es gab ein Fehler in der Eingabe des Namens."), dismissButton: .default(Text("Verstanden")))
                        }
                    }
            }.frame(size: screenSize ?? geometry.size)
                .onAppear {
                    screenSize = geometry.size
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
    
    /// Handles person delete
    func handlePersonDelete() {
        connectionStateDelete = .loading
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        dispatchGroup.enter()
        let changeItem = ServerListChange(changeType: .delete, item: person)
        Changer.shared.change(changeItem) {
            dispatchGroup.leave()
        } failedHandler: {
            connectionStateDelete = .failed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                noConnectionAlertDelete = true
            }
        }
        let changeItemImage = PersonImageChange(changeType: .delete, image: nil, personId: person.id)
        Changer.shared.change(changeItemImage) {
            dispatchGroup.leave()
        } failedHandler: {
            connectionStateDelete = .failed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                noConnectionAlertDelete = true
            }
        }
        fineListData.list!.filter({ $0.personId == person.id }).forEach { fine in
            dispatchGroup.enter()
            let changeItem = ServerListChange(changeType: .delete, item: fine)
            Changer.shared.change(changeItem) {
                dispatchGroup.leave()
            } failedHandler: {
                connectionStateDelete = .failed
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    noConnectionAlertDelete = true
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            connectionStateDelete = .passed
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    /// Handles person update
    func handlePersonUpdate() {
        connectionStateUpdate = .loading
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        let editedPerson = Person(firstName: firstName, lastName: lastName, id: person.id)
        let changeItem = ServerListChange(changeType: .update, item: editedPerson)
        Changer.shared.change(changeItem) {
            dispatchGroup.leave()
        } failedHandler: {
            connectionStateUpdate = .failed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                noConnectionAlertUpdate = true
            }
        }
        if let image = image {
            dispatchGroup.enter()
            let changeItem = PersonImageChange(changeType: .update, image: image, personId: person.id)
            Changer.shared.change(changeItem) {
                dispatchGroup.leave()
            } failedHandler: {
                connectionStateUpdate = .failed
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    noConnectionAlertUpdate = true
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            connectionStateUpdate = .passed
            completionHandler(image)
            presentationMode.wrappedValue.dismiss()
        }
    }
}
