//
//  ErrorMessages.swift
//  Strafen
//
//  Created by Steven on 12.05.21.
//

import Foundation

/// All error messages
enum ErrorMessages {

    /// Textfield is empty
    case emptyField

    /// Invalid email
    case invalidEmail

    /// Less than 8 characters in password
    case tooFewCharacters

    /// No upper character in password
    case noUpperCharacter

    /// No lower character in password
    case noLowerCharacter

    /// No digit in password
    case noDigit

    /// Not same password
    case notSamePassword

    /// Internal error for sign in
    case internalErrorSignIn

    /// Internal error for log in
    case internalErrorLogIn

    /// Internal error for save
    case internalErrorSave

    /// Email is already signed in
    case alreadySignedInEmail

    /// User is already signed in
    case alreadySignedIn

    /// Password is too weak
    case weakPassword

    /// Club doesn't exist
    case clubNotExists

    /// No region given
    case noRegionGiven

    /// In app payment currency isn't euro
    case notEuro

    /// Club identifier already exists
    case identifierAlreadyExists

    /// Password is incorrect
    case incorrectPassword

    /// Not signed in
    case notSignedIn

    /// Amount can't be zero
    case amountZero

    /// Future date
    case futureDate

    /// Invalid number range
    case invalidNumberRange

    /// Internal error delete
    case internalErrorDelete

    /// Raw message of the error
    var rawMessage: String {
        let localizationKey: String
        switch self {
        case .emptyField: localizationKey = "emptyField"
        case .invalidEmail: localizationKey = "invalidEmail"
        case .tooFewCharacters: localizationKey = "tooFewCharacters"
        case .noUpperCharacter: localizationKey = "noUpperCharacter"
        case .noLowerCharacter: localizationKey = "noLowerCharacter"
        case .noDigit: localizationKey = "noDigit"
        case .notSamePassword: localizationKey = "notSamePassword"
        case .internalErrorSignIn: localizationKey = "internalErrorSignIn"
        case .internalErrorLogIn: localizationKey = "internalErrorLogIn"
        case .internalErrorSave: localizationKey = "internalErrorSave"
        case .alreadySignedInEmail: localizationKey = "alreadySignedInEmail"
        case .alreadySignedIn: localizationKey = "alreadySignedIn"
        case .weakPassword: localizationKey = "weakPassword"
        case .clubNotExists: localizationKey = "clubNotExists"
        case .noRegionGiven: localizationKey = "noRegionGiven"
        case .notEuro: localizationKey = "notEuro"
        case .identifierAlreadyExists: localizationKey = "identifierAlreadyExists"
        case .incorrectPassword: localizationKey = "incorrectPassword"
        case .notSignedIn: localizationKey = "notSignedIn"
        case .amountZero: localizationKey = "amountZero"
        case .futureDate: localizationKey = "futureDate"
        case .invalidNumberRange: localizationKey = "invalidNumberRange"
        case .internalErrorDelete: localizationKey = "internalErrorDelete"
        }
        return NSLocalizedString(localizationKey, table: .errorMessages, comment: "Localizated error message")
    }

    /// Error code
    var errorCode: Int {
        switch self {
        case .emptyField: return 1
        case .invalidEmail: return 2
        case .tooFewCharacters: return 3
        case .noUpperCharacter: return 4
        case .noLowerCharacter: return 5
        case .noDigit: return 6
        case .notSamePassword: return 7
        case .internalErrorSignIn: return 8
        case .internalErrorLogIn: return 9
        case .alreadySignedInEmail: return 10
        case .alreadySignedIn: return 11
        case .weakPassword: return 12
        case .clubNotExists: return 13
        case .noRegionGiven: return 14
        case .notEuro: return 15
        case .identifierAlreadyExists: return 16
        case .incorrectPassword: return 17
        case .notSignedIn: return 18
        case .internalErrorSave: return 19
        case .amountZero: return 20
        case .futureDate: return 21
        case .invalidNumberRange: return 22
        case .internalErrorDelete: return 23
        }
    }
    /// Message of the error
    var message: String {
        "(\(errorCode)) \(rawMessage)"
    }
}
