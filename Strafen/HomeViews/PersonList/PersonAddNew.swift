//
//  PersonAddNew.swift
//  Strafen
//
//  Created by Steven on 15.07.20.
//

import SwiftUI

/// View to add a new person
struct PersonAddNew: View {
    
    /// Properties of inputed person
    struct PersonInputProperties {
        
        /// Input first Name
        var firstName = ""
        
        /// Input last Name
        var lastName = ""
        
        /// Image of the person
        var image: UIImage?
        
        /// Progess of image upload
        var imageUploadProgess: Double?
        
        /// Type of first name textfield error
        var firstNameErrorMessages: ErrorMessages? = nil
        
        /// Type of last name textfield error
        var lastNameErrorMessages: ErrorMessages? = nil
        
        /// Type of function call error
        var functionCallErrorMessages: ErrorMessages? = nil
        
        /// State of data task connection
        var connectionState: ConnectionState = .passed
        
        /// Checks if an error occurs while first name input
        @discardableResult mutating func evaluteFirstNameError() -> Bool {
            if firstName.isEmpty {
                firstNameErrorMessages = .emptyField
            } else {
                firstNameErrorMessages = nil
                return false
            }
            return true
        }
        
        /// Checks if an error occurs while last name input
        @discardableResult mutating func evaluteLastNameError() -> Bool {
            if lastName.isEmpty {
                lastNameErrorMessages = .emptyField
            } else {
                lastNameErrorMessages = nil
                return false
            }
            return true
        }
        
        /// Checks if an error occurs
        mutating func errorOccurred() -> Bool {
            evaluteFirstNameError() |!| evaluteLastNameError()
        }
    }
    
    /// Alert type
    enum AlertType: AlertTypeProtocol {
        
        /// Alert when confirm button is pressed
        case confirmButton(action: () -> Void)
        
        /// Id for Identifiable
        var id: Int {
            switch self {
            case .confirmButton(action: _):
                return 0
            }
        }
        
        /// Alert of all alert types
        var alert: Alert {
            switch self {
            case .confirmButton(action: let action):
                return Alert(title: Text("Person Hinzufügen"),
                             message: Text("Möchtest du diese Person wirklich hinzufügen?"),
                             primaryButton: .destructive(Text("Abbrechen")),
                             secondaryButton: .default(Text("Bestätigen"), action: action))
            }
        }
    }
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Properties of inputed person
    @State var personInputProperties = PersonInputProperties()
    
    /// Alert type
    @State var alertType: AlertType? = nil
    
    var body: some View {
        ZStack {
            
            // Background color
            colorScheme.backgroundColor
            
            VStack(spacing: 0) {
                
                // Bar to wipe sheet down
                SheetBar()
                
                // Header
                Header("Person Hinzufügen")
                
                // Image and Name
                VStack(spacing: 20) {
                    
                    // Image
                    VStack(spacing: 5) {
                        
                        ImageSelector(image: $personInputProperties.image, uploadProgress: $personInputProperties.imageUploadProgess)
                            .frame(width: 120, height: 120)
                            .padding(.bottom, 20)
                        
                        // Progress bar
                        if let imageUploadProgess = personInputProperties.imageUploadProgess {
                            VStack(spacing: 5) {
                                Text("Bild hochladen")
                                    .configurate(size: 15)
                                    .padding(.horizontal, 20)
                                    .lineLimit(1)
                                ProgressView(value: imageUploadProgess)
                                    .progressViewStyle(LinearProgressViewStyle())
                                    .frame(width: UIScreen.main.bounds.width * 0.95)
                            }
                        }
                        
                    }
                    
                    // Name
                    TitledContent("Name") {
                        
                        // First name
                        CustomTextField()
                            .title("Vorname")
                            .textBinding($personInputProperties.firstName)
                            .errorMessages($personInputProperties.firstNameErrorMessages)
                            .textFieldSize(width: UIScreen.main.bounds.width * 0.95, height: 50)
                            .onCompletion { personInputProperties.evaluteFirstNameError() }
                        
                        // Last name
                        CustomTextField()
                            .title("Nachname")
                            .textBinding($personInputProperties.lastName)
                            .errorMessages($personInputProperties.lastNameErrorMessages)
                            .textFieldSize(width: UIScreen.main.bounds.width * 0.95, height: 50)
                            .onCompletion { personInputProperties.evaluteLastNameError() }
                        
                    }
                    
                    Spacer()
                }.keyboardAdaptiveOffset
                    .padding(.top, 10)
                    .clipped()
                    .padding(.top, 10)
                
                VStack(spacing: 5) {
                    
                    // Cancel and confim button
                    CancelConfirmButton()
                        .connectionState($personInputProperties.connectionState)
                        .onCancelPress { presentationMode.wrappedValue.dismiss() }
                        .onConfirmPress($alertType, value: .confirmButton(action: handleSave)) {
                            !personInputProperties.errorOccurred()
                        }
                        .alert(item: $alertType)
                    
                    // Error messages
                    ErrorMessageView(errorMessages: $personInputProperties.functionCallErrorMessages)
                    
                }.padding(.bottom, personInputProperties.functionCallErrorMessages == nil ? 50 : 25)
                    
            }
            
        }.edgesIgnoringSafeArea(.all)
            .animation(.default)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .setScreenSize
    }
    
    /// Handles person and image saving
    func handleSave() {
        guard personInputProperties.connectionState != .loading,
            !personInputProperties.errorOccurred(),
            let clubId = NewSettings.shared.properties.person?.clubProperties.id else { return }
        personInputProperties.connectionState = .loading
        
        let personId = NewPerson.ID(rawValue: UUID())
        
        // Set person image
        setPersonImage(of: personId, clubId: clubId) {
            
            // Create new person in database
            createNewPerson(of: personId, clubId: clubId)
            
        }
    }
    
    /// Set person image
    func setPersonImage(of personId: NewPerson.ID, clubId: NewClub.ID, completionHandler: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        if let image = personInputProperties.image {
            personInputProperties.imageUploadProgess = .zero
            dispatchGroup.enter()
            ImageStorage.shared.store(at: .personImage(with: personId, clubId: clubId), image: image) { _ in
                
                // Success
                dispatchGroup.leave()
                personInputProperties.imageUploadProgess = nil
                
            } failedHandler: { _ in
                
                // Error
                personInputProperties.functionCallErrorMessages = .internalErrorSave
                personInputProperties.connectionState = .failed
                personInputProperties.imageUploadProgess = nil
                
            } progressChangeHandler: { progress in
                personInputProperties.imageUploadProgess = progress
            }

        }
        dispatchGroup.notify(queue: .main) {
            completionHandler()
        }
    }
    
    /// Create new person in database
    func createNewPerson(of personId: NewPerson.ID, clubId: NewClub.ID) {
        
        // New person call item
        let name = PersonName(firstName: personInputProperties.firstName, lastName: personInputProperties.lastName)
        let person = NewPerson(id: personId, name: name, signInData: nil)
        let callItem = ChangeListCall(clubId: clubId, changeType: .add, changeItem: person)
        
        // Create new person in database
        FunctionCaller.shared.call(callItem) { _ in
            personInputProperties.connectionState = .passed
            personInputProperties.imageUploadProgess = nil
            presentationMode.wrappedValue.dismiss()
        } failedHandler: { _ in
            personInputProperties.connectionState = .failed
            personInputProperties.functionCallErrorMessages = .internalErrorSave
        }
}
}
