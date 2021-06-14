//
//  PersonAddNew.swift
//  Strafen
//
//  Created by Steven on 06.06.21.
//

import SwiftUI

/// View to add a new person
struct PersonAddNew: View {

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

        /// Progess of image upload
        var imageUploadProgess: Double?

        /// Error message of function call
        var functionCallErrorMessage: ErrorMessages?

        /// State of data task connection
        var connectionState: ConnectionState = .notStarted

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
    }

    /// Currently logged in person
    @EnvironmentObject var person: Settings.Person

    /// Presentation mode
    @Environment(\.presentationMode) private var presentationMode

    /// Input properties
    @State var inputProperties = InputProperties()

    var body: some View {
        ZStack {

            // Background color
            Color.backgroundGray

            VStack(spacing: 0) {

                // Bar to ipe sheet down
                SheetBar()

                // Title
                Header(String(localized: "person-add-new-header-text", comment: "Header of person add new view."))

                ScrollView(showsIndicators: false) {
                    ScrollViewReader { proxy in
                        VStack(spacing: 20) {

                            // Image
                            VStack(spacing: 5) {
                                ImageSelector(image: $inputProperties.image, uploadProgress: $inputProperties.imageUploadProgess)
                                    .frame(width: 120, height: 120)
                                    .padding(.bottom, 20)

                                // Progress bar
                                if let imageUploadProgess = inputProperties.imageUploadProgess {
                                    VStack(spacing: 5) {
                                        Text("person-add-new-upload-image-text", comment: "Text that image is uploading.")
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
                            TitledContent(String(localized: "person-add-new-name-title", comment: "Plain text of name for text field title.")) {
                                VStack(spacing: 5) {

                                    // First name
                                    CustomTextField(.firstName, inputProperties: $inputProperties)
                                        .placeholder(String(localized: "person-add-new-first-name-placeholder", comment: "Plain text of first name for text field placeholder."))
                                        .defaultTextFieldSize
                                        .scrollViewProxy(proxy)

                                    // Last name
                                    CustomTextField(.lastName, inputProperties: $inputProperties)
                                        .placeholder(String(localized: "person-add-new-optional-last-name-placeholder", comment: "Plain text of last name that can be optional for text field placeholder."))
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

                    // Cancel and confirm button
                    SplittedButton.cancelConfirm
                        .rightConnectionState($inputProperties.connectionState)
                        .onLeftClick { presentationMode.wrappedValue.dismiss() }
                        .onRightClick(perform: handlePersonSave)

                }.padding(.bottom, 35)
                    .animation(.default)

            }
        }.maxFrame
    }

    /// Handles person and image saving
    func handlePersonSave() async {
        await Self.handlePersonSave(person: person,
                              inputProperties: $inputProperties,
                              presentationMode: presentationMode)
    }

    /// Handles person and image saving
    static func handlePersonSave(person: Settings.Person,
                                 inputProperties: Binding<InputProperties>,
                                 presentationMode: Binding<PresentationMode>? = nil) async {
        guard inputProperties.wrappedValue.connectionState.restart() == .passed else { return }
        inputProperties.wrappedValue.functionCallErrorMessage = nil
        guard inputProperties.wrappedValue.validateAllInputs() == .valid else {
            return inputProperties.wrappedValue.connectionState.failed()
        }
        inputProperties.wrappedValue.imageUploadProgess = nil
        let personId = FirebasePerson.ID(rawValue: UUID())

        do {

            // Set person image
            try await setPersonImage(of: personId, person: person, inputProperties: inputProperties)

            // Create new person in database
            await createNewPerson(of: personId, person: person, inputProperties: inputProperties)

        } catch {
            inputProperties.wrappedValue.functionCallErrorMessage = .internalErrorSave
            inputProperties.wrappedValue.imageUploadProgess = nil
            inputProperties.wrappedValue.connectionState.failed()
        }
    }

    /// Set person image
    static func setPersonImage(of personId: FirebasePerson.ID,
                               person: Settings.Person,
                               inputProperties: Binding<InputProperties>) async throws {
        guard let image = inputProperties.wrappedValue.image else { return }
        inputProperties.wrappedValue.imageUploadProgess = .zero
        let imageType = FirebaseImageStorage.ImageType(id: personId, clubId: person.club.id)
        try await FirebaseImageStorage.shared.store(image, of: imageType) { progress in
            inputProperties.wrappedValue.imageUploadProgess = progress
        }
    }

    /// Create new person in database
    static func createNewPerson(of personId: FirebasePerson.ID,
                                person loggedInPerson: Settings.Person,
                                inputProperties: Binding<InputProperties>) async {
        let name = PersonName(firstName: inputProperties.wrappedValue[.firstName], lastName: inputProperties.wrappedValue[.lastName])
        let person = FirebasePerson(id: personId, name: name, signInData: nil)
        let callItem = FFChangeListCall(clubId: loggedInPerson.club.id, item: person)

        do {
            try await FirebaseFunctionCaller.shared.call(callItem)
            inputProperties.wrappedValue.connectionState.passed()
        } catch {
            inputProperties.wrappedValue.functionCallErrorMessage = .internalErrorSave
            inputProperties.wrappedValue.connectionState.failed()
        }
    }
}
