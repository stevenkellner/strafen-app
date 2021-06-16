//
//  PersonEditor.swift
//  Strafen
//
//  Created by Steven on 16.06.21.
//

import SwiftUI
import FirebaseFunctions

/// View to edit a person
struct PersonEditor: View {

    /// Properties of inputed person
    struct InputProperties: InputPropertiesProtocol {

        /// All textfields
        enum TextFields: Int, TextFieldsProtocol {
            case firstName, lastName
        }

        var inputProperties = [TextFields: String]()

        var errorMessages = [TextFields: ErrorMessages]()

        var firstResponders = TextFieldFirstResponders<TextFields>()

        /// Person image
        var image: UIImage?

        /// Indicates if selected image is new
        var isNewImage = false

        /// Progess of image upload
        var imageUploadProgess: Double?

        /// Error message of function call
        var functionCallErrorMessage: ErrorMessages?

        /// State of data task connection
        var connectionStateDelete: ConnectionState = .notStarted

        /// State of data task connection
        var connectionStateUpdate: ConnectionState = .notStarted

        /// Validates the first name input and sets associated error messages
        /// - Parameter setErrorMessage: Indicates whether error message will be set
        /// - Returns: result of this validation
        private mutating func validateFirstName(setErrorMessage: Bool = true) -> ValidationResult {
            var errorMessage: ErrorMessages?
            if self[.firstName].isEmpty {
                errorMessage = .emptyField
            } else {
                if setErrorMessage { self[error: .firstName] = nil }
                return .valid
            }
            if setErrorMessage { self[error: .firstName] = errorMessage }
            return .invalid
        }

        /// Validates the last name input and sets associated error messages
        /// - Parameter setErrorMessage: Indicates whether error message will be set
        /// - Returns: result of this validation
        private mutating func validateLastName(setErrorMessage: Bool = true) -> ValidationResult {
            if setErrorMessage { self[error: .lastName] = nil }
            return .valid
        }

        mutating func validateTextField(_ textfield: TextFields, setErrorMessage: Bool) -> ValidationResult {
            switch textfield {
            case .firstName: return validateFirstName(setErrorMessage: setErrorMessage)
            case .lastName: return validateLastName(setErrorMessage: setErrorMessage)
            }
        }

        /// Set person properties of given person
        /// - Parameter person: person
        mutating func setProperties(of person: FirebasePerson) {
            self[.firstName] = person.name.firstName
            self[.lastName] = person.name.lastName ?? ""
        }
    }

    /// Currently logged in person
    @EnvironmentObject var loggedInPerson: Settings.Person

    /// Environment of the fine list
    @EnvironmentObject var fineListEnvironment: ListEnvironment<FirebaseFine>

    /// Presentation mode
    @Environment(\.presentationMode) private var presentationMode

    /// Person to edit
    let oldPerson: FirebasePerson

    init(_ person: FirebasePerson) {
        self.oldPerson = person
    }

    /// Input properties
    @State var inputProperties = InputProperties()

    /// Indicates whether delete alert is currently shown
    @State var showDeleteAlert = false

    var body: some View {
        ZStack {

            // Background color
            Color.backgroundGray

            VStack(spacing: 0) {

                // Bar to ipe sheet down
                SheetBar()

                // Title
                Header(String(localized: "person-editor-header-text", comment: "Header of person editor view."))

                ScrollView(showsIndicators: false) {
                    ScrollViewReader { proxy in
                        VStack(spacing: 20) {

                            // Image
                            VStack(spacing: 5) {
                                ImageSelector(image: $inputProperties.image, uploadProgress: $inputProperties.imageUploadProgess) {
                                    inputProperties.isNewImage = true
                                }.frame(width: 120, height: 120)
                                    .padding(.bottom, 20)

                                // Progress bar
                                if let imageUploadProgess = inputProperties.imageUploadProgess {
                                    VStack(spacing: 5) {
                                        Text("person-editor-upload-image-text", comment: "Text that image is uploading.")
                                            .foregroundColor(.textColor)
                                            .font(.system(size: 15, weight: .thin))
                                            .padding(.horizontal, 20)
                                            .lineLimit(1)
                                        ProgressView(value: imageUploadProgess)
                                            .progressViewStyle(LinearProgressViewStyle())
                                            .frame(width: UIScreen.main.bounds.width * 0.95)
                                    }
                                }
                            }

                            // Name
                            TitledContent(String(localized: "person-editor-name-title", comment: "Plain text of name for text field title.")) {
                                VStack(spacing: 5) {

                                    // First name
                                    CustomTextField(.firstName, inputProperties: $inputProperties)
                                        .placeholder(String(localized: "person-editor-first-name-placeholder", comment: "Plain text of first name for text field placeholder."))
                                        .defaultTextFieldSize
                                        .scrollViewProxy(proxy)

                                    // Last name
                                    CustomTextField(.lastName, inputProperties: $inputProperties)
                                        .placeholder(String(localized: "person-editor-optional-last-name-placeholder", comment: "Plain text of last name that can be optional for text field placeholder."))
                                        .defaultTextFieldSize
                                        .scrollViewProxy(proxy)

                                }
                            }

                        }.padding(.vertical, 10)
                    }
                }.padding(.vertical, 10)
                    .animation(.default)

                Spacer()

                VStack(spacing: 5) {

                    // Error message
                    ErrorMessageView($inputProperties.functionCallErrorMessage)

                    // Delete and confirm button
                    SplittedButton.deleteConfirm
                        .leftConnectionState($inputProperties.connectionStateDelete)
                        .rightConnectionState($inputProperties.connectionStateUpdate)
                        .onLeftClick { showDeleteAlert = true }
                        .onRightClick(perform: handlePersonUpdate)

                }.padding(.bottom, 35)
                    .animation(.default)
                    .toast(isPresented: $showDeleteAlert) {
                        DeleteAlert(deleteText: String(localized: "person-editor-delete-message", comment: "Message of delete person alert."),
                                    showDeleteAlert: $showDeleteAlert,
                                    deleteHandler: handlePersonDelete)
                    }

            }
        }.maxFrame
            .task {
                do {
                    let imageType = FirebaseImageStorage.ImageType(id: oldPerson.id, clubId: loggedInPerson.club.id)
                    let image = try await FirebaseImageStorage.shared.getImage(imageType, size: .thumbBig)
                    if !inputProperties.isNewImage { inputProperties.image = image }
                } catch {}
            }
            .onAppear {
                inputProperties.setProperties(of: oldPerson)
            }
    }

    /// Handles person delete
    func handlePersonDelete() {
        async {
            await Self.handlePersonDelete(id: oldPerson.id,
                                          loggedInPerson: loggedInPerson,
                                          fineList: fineListEnvironment.list,
                                          inputProperties: $inputProperties,
                                          presentationMode: presentationMode)
        }
    }

    /// Handles person update
    func handlePersonUpdate() async {
        await Self.handlePersonUpdate(id: oldPerson.id,
                                      loggedInPerson: loggedInPerson,
                                      inputProperties: $inputProperties,
                                      presentationMode: presentationMode)
    }

    /// Handles person delete
    static func handlePersonDelete(id personId: FirebasePerson.ID,
                                   loggedInPerson: Settings.Person,
                                   fineList: [FirebaseFine],
                                   inputProperties: Binding<InputProperties>,
                                   presentationMode: Binding<PresentationMode>? = nil) async {
        guard loggedInPerson.isCashier else { return }
        guard inputProperties.wrappedValue.connectionStateUpdate != .loading,
              inputProperties.wrappedValue.connectionStateDelete.restart() == .passed else { return }
        inputProperties.wrappedValue.errorMessages = [:]
        inputProperties.wrappedValue.imageUploadProgess = nil

        do {

            // Delete person
            let callItem = FFChangeListCall<FirebasePerson>(clubId: loggedInPerson.club.id, id: personId)
            try await FirebaseFunctionCaller.shared.call(callItem)
        } catch {

            // Handle error
            inputProperties.wrappedValue.functionCallErrorMessage = .internalErrorDelete
            if let error = error as NSError?, error.domain == FunctionsErrorDomain {
                let errorCode = FunctionsErrorCode(rawValue: error.code)
                switch errorCode {
                case .unavailable:
                    inputProperties.wrappedValue.functionCallErrorMessage = .personUndeletable
                default: break
                }
            }
            return inputProperties.wrappedValue.connectionStateDelete.failed()
        }

        await withTaskGroup(of: Void.self) { group in

            // Delete image
            group.async {
                let imageType = FirebaseImageStorage.ImageType(id: personId, clubId: loggedInPerson.club.id)
                try? await FirebaseImageStorage.shared.delete(imageType)
            }

            // Delete fines
            for fine in fineList where fine.assoiatedPersonId == personId {
                group.async {
                    let callItem = FFChangeListCall<FirebaseFine>(clubId: loggedInPerson.club.id, id: fine.id)
                    _ = try? await FirebaseFunctionCaller.shared.call(callItem)
                }
            }
        }

        presentationMode?.wrappedValue.dismiss()
        inputProperties.wrappedValue.connectionStateDelete.passed()
    }

    /// Handles person update
    static func handlePersonUpdate(id personId: FirebasePerson.ID,
                                   loggedInPerson: Settings.Person,
                                   inputProperties: Binding<InputProperties>,
                                   presentationMode: Binding<PresentationMode>? = nil) async {
        guard loggedInPerson.isCashier else { return }
        guard inputProperties.wrappedValue.connectionStateDelete != .loading,
              inputProperties.wrappedValue.connectionStateUpdate.restart() == .passed else { return }
        guard inputProperties.wrappedValue.validateAllInputs() == .valid else {
            return inputProperties.wrappedValue.connectionStateUpdate.failed()
        }
        inputProperties.wrappedValue.imageUploadProgess = nil

        do {

            // Update person
            let person = FirebasePerson(id: personId, name: PersonName(firstName: inputProperties.wrappedValue[.firstName], lastName: inputProperties.wrappedValue[.lastName]), signInData: nil)
            let callItem = FFChangeListCall(clubId: loggedInPerson.club.id, item: person)
            try await FirebaseFunctionCaller.shared.call(callItem)

            // Update image
            if inputProperties.wrappedValue.isNewImage {
                let imageType = FirebaseImageStorage.ImageType(id: personId, clubId: loggedInPerson.club.id)
                guard let image = inputProperties.wrappedValue.image else {
                    return try await FirebaseImageStorage.shared.delete(imageType)
                }
                inputProperties.wrappedValue.imageUploadProgess = .zero
                try await FirebaseImageStorage.shared.store(image, of: imageType, progress: { progress in
                    inputProperties.wrappedValue.imageUploadProgess = progress
                })
                inputProperties.wrappedValue.imageUploadProgess = nil
            }

            inputProperties.wrappedValue.connectionStateUpdate.passed()
        } catch {
            inputProperties.wrappedValue.functionCallErrorMessage = .internalErrorSave
            inputProperties.wrappedValue.imageUploadProgess = nil
            inputProperties.wrappedValue.connectionStateUpdate.failed()
        }
    }
}
