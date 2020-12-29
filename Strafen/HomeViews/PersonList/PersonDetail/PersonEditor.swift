//
//  PersonEditor.swift
//  Strafen
//
//  Created by Steven on 16.07.20.
//

import SwiftUI
import FirebaseFunctions

/// View to edit person
struct PersonEditor: View {
    
    /// Properties of inputed person
    struct PersonInputProperties {
        
        /// Input first Name
        var firstName = ""
        
        /// Input last Name
        var lastName = ""
        
        /// Image of the person
        var image: UIImage?
        
        /// Idicates if selected image is new
        var isNewImage = false
        
        /// Progess of image upload
        var imageUploadProgess: Double?
        
        /// Type of first name textfield error
        var firstNameErrorMessages: ErrorMessages? = nil
        
        /// Type of last name textfield error
        var lastNameErrorMessages: ErrorMessages? = nil
        
        /// Type of function call error
        var functionCallErrorMessages: ErrorMessages? = nil
        
        /// State of data task connection
        var connectionStateDelete: ConnectionState = .passed
        
        /// State of data task connection
        var connectionStateConfirm: ConnectionState = .passed
        
        /// Sets properties with person
        mutating func setProperties(with person: Person) {
            firstName = person.name.firstName
            lastName = person.name.lastName // TODO set image
        }
        
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
        
        /// Reset all error messages
        mutating func resetErrorMessages() {
            firstNameErrorMessages = nil
            lastNameErrorMessages = nil
            functionCallErrorMessages = nil
        }
        
        /// Checks if an error occurs
        mutating func errorOccurred() -> Bool {
            evaluteFirstNameError() |!| evaluteLastNameError()
        }
    }
    
    /// Alert type
    enum AlertType: AlertTypeProtocol {
        
        /// Alert when delete button is pressed
        case deleteButton(action: () -> Void)
        
        
        /// Alert when confirm button is pressed
        case confirmButton(action: () -> Void)
        
        /// Id for Identifiable
        var id: Int {
            switch self {
            case .deleteButton(action: _):
                return 0
            case .confirmButton(action: _):
                return 1
            }
        }
        
        /// Alert of all alert types
        var alert: Alert {
            switch self {
            case .deleteButton(action: let action):
                return Alert(title: Text("Person Löschen"),
                             message: Text("Möchtest du diese Person wirklich löschen?"),
                             primaryButton: .cancel(Text("Abbrechen")),
                             secondaryButton: .destructive(Text("Löschen"), action: action))
            case .confirmButton(action: let action):
                return Alert(title: Text("Person Ändern"),
                             message: Text("Möchtest du diese Person wirklich ändern?"),
                             primaryButton: .destructive(Text("Abbrechen")),
                             secondaryButton: .default(Text("Bestätigen"), action: action))
            }
        }
    }
    
    /// Person to edit
    let person: Person
    
    /// Completion handler
    let completionHandler: (UIImage?) -> Void
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Fine List Data
    @ObservedObject var fineListData = ListData.fine
    
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
                Header("Person Ändern")
                
                // Image and Name
                VStack(spacing: 20) {
                    
                    // Image
                    VStack(spacing: 5) {
                        
                        ImageSelector(image: $personInputProperties.image, uploadProgress: $personInputProperties.imageUploadProgess) {
                            personInputProperties.isNewImage = true
                        }.frame(width: 120, height: 120)
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
                    
                    // Delete and confirm button
                    DeleteConfirmButton()
                        .deleteConnectionState($personInputProperties.connectionStateDelete)
                        .confirmConnectionState($personInputProperties.connectionStateConfirm)
                        .onDeletePress($alertType, value: .deleteButton(action: handlePersonDelete))
                        .onConfirmPress($alertType, value: .confirmButton(action: handlePersonUpdate)) {
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
            .onAppear {
                personInputProperties.setProperties(with: person)
//                ImageData.shared.fetch(of: person.id) { image in TODO
//                    self.image = image
//                }
            }
    }
    
    /// Handles person delete
    func handlePersonDelete() {
        guard personInputProperties.connectionStateDelete != .loading,
              personInputProperties.connectionStateConfirm != .loading,
              let clubId = Settings.shared.person?.clubProperties.id else { return }
        personInputProperties.connectionStateDelete = .loading
        personInputProperties.resetErrorMessages()
        
        // Delete person
        deletePerson(clubId: clubId) {
            
            let dispatchGroup = DispatchGroup()
            
            // Delete person image
            dispatchGroup.enter()
            deleteImage(clubId: clubId) {
                dispatchGroup.leave()
            }
            
            // Delete fines of person
            dispatchGroup.enter()
            deleteFines(clubId: clubId) {
                dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {
                personInputProperties.connectionStateDelete = .passed
                presentationMode.wrappedValue.dismiss()
            }
            
        }
    }
    
    /// Delete person, execute completion handler only at success
    func deletePerson(clubId: Club.ID, completionHandler: @escaping () -> Void) {
        let callItem = ChangeListCall(clubId: clubId, changeType: .delete, changeItem: person)
        FunctionCaller.shared.call(callItem) { _ in
            completionHandler()
        } failedHandler: { error in
            personInputProperties.connectionStateDelete = .failed
            guard let error = error as NSError?, error.domain == FunctionsErrorDomain else {
                return personInputProperties.functionCallErrorMessages = .internalErrorDelete
            }
            let errorCode = FunctionsErrorCode(rawValue: error.code)
            switch errorCode {
            case .unavailable:
                personInputProperties.functionCallErrorMessages = .personUndeletable
            default:
                personInputProperties.functionCallErrorMessages = .internalErrorDelete
            }
        }

    }
    
    /// Delete person image, execute completion handler at success and failure
    func deleteImage(clubId: Club.ID, completionHandler: @escaping () -> Void) {
        ImageStorage.shared.delete(at: .personImage(with: person.id, clubId: clubId)) { _ in
            completionHandler()
        }
    }
    
    /// Delete fines of person, execute completion handler at success and failure
    func deleteFines(clubId: Club.ID, completionHandler: @escaping () -> Void) {
        fineListData.list?.filter { fine in
            fine.assoiatedPersonId == person.id
        }.forEach { fine in
            let callItem = ChangeListCall(clubId: clubId, changeType: .delete, changeItem: fine)
            FunctionCaller.shared.call(callItem) { _ in
                completionHandler()
            }
        }
    }
    
    /// Handles person update
    func handlePersonUpdate() {
        guard personInputProperties.connectionStateDelete != .loading,
              personInputProperties.connectionStateConfirm != .loading,
              !personInputProperties.errorOccurred(),
              let clubId = Settings.shared.person?.clubProperties.id else { return }
        personInputProperties.connectionStateConfirm = .loading
        
        let dispatchGroup = DispatchGroup()
        
        // Update person in database
        dispatchGroup.enter()
        updatePerson(clubId: clubId) {
            dispatchGroup.leave()
        }
        
        // Set person image
        if personInputProperties.isNewImage, let image = personInputProperties.image {
            dispatchGroup.enter()
            setPersonImage(image: image, clubId: clubId) {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            personInputProperties.connectionStateConfirm = .passed
            completionHandler(personInputProperties.image)
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    /// Update person in database
    func updatePerson(clubId: Club.ID, completionHandler: @escaping () -> Void) {
        let personName = PersonName(firstName: personInputProperties.firstName, lastName: personInputProperties.lastName)
        let updatedPerson = Person(id: person.id, name: personName, signInData: person.signInData)
        let callItem = ChangeListCall(clubId: clubId, changeType: .update, changeItem: updatedPerson)
        FunctionCaller.shared.call(callItem) { _ in
            completionHandler()
        } failedHandler: { _ in
            personInputProperties.connectionStateConfirm = .failed
            personInputProperties.functionCallErrorMessages = .internalErrorSave
        }

    }
    
    /// Set person image in database
    func setPersonImage(image: UIImage, clubId: Club.ID, completionHandler: @escaping () -> Void) {
        personInputProperties.imageUploadProgess = .zero
        ImageStorage.shared.store(at: .personImage(with: person.id, clubId: clubId), image: image) { _ in
            
            // Success
            completionHandler()
            personInputProperties.imageUploadProgess = nil
            
        } failedHandler: { _ in
            
            // Error
            personInputProperties.functionCallErrorMessages = .internalErrorSave
            personInputProperties.connectionStateConfirm = .failed
            personInputProperties.imageUploadProgess = nil
            
        } progressChangeHandler: { progress in
            personInputProperties.imageUploadProgess = progress
        }
    }
}
