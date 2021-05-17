//
//  InputPropertiesProtocol.swift
//  Strafen
//
//  Created by Steven on 13.05.21.
//

import Foundation

/// Contains all properties of the textfield inputs
protocol InputPropertiesProtocol {

    /// All textfields
    associatedtype TextFields: TextFieldsProtocol

    /// Input properties of all textfields
    var inputProperties: [TextFields: String] { get set }

    /// Error messages of all textfields
    var errorMessages: [TextFields: ErrorMessages] { get set }

    /// List of all textfield handlers to become first responder
    var firstResponders: TextFieldFirstResponders<TextFields> { get set }

    /// Validates given textfield input and sets associated error messages if setErrorMessage is `true`
    /// - Parameter textfield: textfield
    /// - Parameter setErrorMessage: Indicates whether error message will be set
    /// - Returns: result of this validation
    mutating func validateTextField(_ textfield: TextFields, setErrorMessage: Bool) -> ValidationResult
}

extension InputPropertiesProtocol {

    /// Gets and sets input property of given textfield
    /// - Parameters:
    ///   - textfield: textfield
    /// - Returns: input propertiy of textfield
    public subscript(_ textField: TextFields) -> String {
        get { inputProperties[textField, default: ""] }
        set { inputProperties[textField] = newValue }
    }

    /// Gets and sets error message of given textfield
    /// - Parameters:
    ///   - textfield: textfield
    /// - Returns: error message of textfield
    public subscript(error textField: TextFields) -> ErrorMessages? {
        get { errorMessages[textField] }
        set { errorMessages[textField] = newValue }
    }

    /// Validates given textfield input and sets associated error messages
    /// - Parameter textfield: textfield
    /// - Returns: result of this validation
    public mutating func validateTextField(_ textfield: TextFields) -> ValidationResult {
        validateTextField(textfield, setErrorMessage: true)
    }

    /// Validates all given textfields and sets associated error messages
    /// - Parameter textFields: textfields to validate
    /// - Returns: result of this validation
    public mutating func validateTextFields(_ textFields: [TextFields]) -> ValidationResult {
        textFields.validateAll { textField in
            validateTextField(textField)
        }
    }

    /// Validates all input and sets associated error messages
    /// - Returns: result of this validation
    public mutating func validateAllInputs() -> ValidationResult {
        TextFields.allCases.validateAll { textField in
            validateTextField(textField)
        }
    }

    /// Gets the next invalid textfield
    /// - Parameters:
    ///   - textfield: textfield to find after
    /// - Returns: next invalid textfield
    public mutating func nextTextField(after textfield: TextFields) -> TextFields? {
        guard textfield.rawValue != TextFields.allCases.count - 1 else { return nil }
        let nextField = textfield.next
        if validateTextField(nextField, setErrorMessage: false) == .invalid {
            return nextField
        }
        return nextTextField(after: nextField)
    }
}

/// Contains all properties of the textfield inputs
struct DefaultInputProperties: InputPropertiesProtocol {

    var inputProperties = [DefaultTextFields: String]()

    var errorMessages = [DefaultTextFields: ErrorMessages]()

    var firstResponders = TextFieldFirstResponders<DefaultTextFields>()

    mutating func validateTextField(_ textfield: DefaultTextFields, setErrorMessage: Bool) -> ValidationResult {
        self[.textField].isEmpty ? .invalid : .valid
    }
}
