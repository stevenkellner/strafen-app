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
                Header("person-add-new-header-text", table: .personList, comment: "Person add new header text")

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
                                        Text("person-add-new-upload-image-text", table: .personList, comment: "Person add new upload image text")
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
                            TitledContent("person-add-new-name", table: .personList, comment: "Person add new name text") {
                                VStack(spacing: 5) {

                                    // First name
                                    CustomTextField(.firstName, inputProperties: $inputProperties)
                                        .placeholder("person-add-new-first-name", table: .personList, comment: "Person add new first name text")
                                        .defaultTextFieldSize
                                        .scrollViewProxy(proxy)

                                    // Last name
                                    CustomTextField(.lastName, inputProperties: $inputProperties)
                                        .placeholder("person-add-new-optional-last-name", table: .personList, comment: "Person add new optional last name text")
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
    func handlePersonSave() {
        Self.handlePersonSave(person: person,
                              inputProperties: $inputProperties,
                              presentationMode: presentationMode)
    }

    /// Handles person and image saving
    static func handlePersonSave(person: Settings.Person,
                                 inputProperties: Binding<InputProperties>,
                                 presentationMode: Binding<PresentationMode>? = nil,
                                 onCompletion completionHandler: (() -> Void)? = nil) {
        guard inputProperties.wrappedValue.connectionState.restart() == .passed else { return }
        inputProperties.wrappedValue.functionCallErrorMessage = nil
        guard inputProperties.wrappedValue.validateAllInputs() == .valid else {
            return inputProperties.wrappedValue.connectionState.failed()
        }
        inputProperties.wrappedValue.imageUploadProgess = nil
        let personId = FirebasePerson.ID(rawValue: UUID())

        // Set person image
        setPersonImage(of: personId,
                       person: person,
                       inputProperties: inputProperties) {

            // Create new person in database
            createNewPerson(of: personId,
                            person: person,
                            inputProperties: inputProperties) {
                completionHandler?()
                presentationMode?.wrappedValue.dismiss()
            }
        }
    }

    /// Set person image
    static func setPersonImage(of personId: FirebasePerson.ID,
                               person: Settings.Person,
                               inputProperties: Binding<InputProperties>,
                               onCompletion completionHandler: @escaping () -> Void) {
        guard let image = inputProperties.wrappedValue.image else { return completionHandler() }
        inputProperties.wrappedValue.imageUploadProgess = .zero
        FirebaseImageStorage.shared.store(image, of: .personImage(clubId: person.club.id, personId: personId)) { _ in
            inputProperties.wrappedValue.imageUploadProgess = nil
            completionHandler()
        } failedHandler: { _ in
            inputProperties.wrappedValue.functionCallErrorMessage = .internalErrorSave
            inputProperties.wrappedValue.imageUploadProgess = nil
            inputProperties.wrappedValue.connectionState.failed()
        } progressChangeHandler: { progress in
            inputProperties.wrappedValue.imageUploadProgess = progress
        }

    }

    /// Create new person in database
    static func createNewPerson(of personId: FirebasePerson.ID,
                                person loggedInPerson: Settings.Person,
                                inputProperties: Binding<InputProperties>,
                                onCompletion completionHandler: @escaping () -> Void) {
        let name = PersonName(firstName: inputProperties.wrappedValue[.firstName], lastName: inputProperties.wrappedValue[.lastName])
        let person = FirebasePerson(id: personId, name: name, signInData: nil)
        let callItem = FFChangeListCall(clubId: loggedInPerson.club.id, item: person)

        FirebaseFunctionCaller.shared.call(callItem).then { _ in
            inputProperties.wrappedValue.connectionState.passed()
        }.catch { _ in
            inputProperties.wrappedValue.functionCallErrorMessage = .internalErrorSave
            inputProperties.wrappedValue.connectionState.failed()
        }.always {
            completionHandler()
        }
    }
}
