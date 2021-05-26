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
    case emptyField(code: Int)

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
    case internalErrorSignIn(code: Int)

    /// Internal error for log in
    case internalErrorLogIn(code: Int)

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
    case identifierAlreadyExists(code: Int)

    /// Password is incorrect
    case incorrectPassword

    /// Not signed in
    case notSignedIn

    /// Raw message of the error
    var rawMessage: String {
        switch self {
        case .emptyField(code: _):
            return "Dieses Feld darf nicht leer sein!"
        case .invalidEmail:
            return "Dies ist keine gültige Email!"
        case .tooFewCharacters:
            return "Passwort ist zu kurz!"
        case .noUpperCharacter:
            return "Muss einen Großbuchstaben enthalten!"
        case .noLowerCharacter:
            return "Muss einen Kleinbuchstaben enthalten!"
        case .noDigit:
            return "Muss eine Zahl enthalten!"
        case .notSamePassword:
            return "Passwörter stimmen nicht überein!"
        case .internalErrorSignIn(code: _):
            return "Es gab ein Problem beim Registrieren!"
        case .internalErrorLogIn(code: _):
            return "Es gab ein Problem beim Anmelden!"
        case .alreadySignedInEmail:
            return "Diese Email ist bereits registriert!"
        case .alreadySignedIn:
            return "Du bist bereits registriert!"
        case .weakPassword:
            return "Das Passwort ist zu schwach!"
        case .clubNotExists:
            return "Es gibt keinen Verein mit dieser Kennung!"
        case .noRegionGiven:
            return "Keine Region angegeben!"
        case .notEuro:
            return "Funktioniert nur in Ländern mit Euro!"
        case .identifierAlreadyExists(code: _):
            return "Vereinskennung ist bereits vergeben!"
        case .incorrectPassword:
            return "Das eingegebene Passwort ist falsch!"
        case .notSignedIn:
            return "Du bist noch nicht registriert!"
        }
    }

    /// Error code
    var errorCode: Int {
        switch self {
        case .emptyField(code: _): return 1
        case .invalidEmail: return 2
        case .tooFewCharacters: return 3
        case .noUpperCharacter: return 4
        case .noLowerCharacter: return 5
        case .noDigit: return 6
        case .notSamePassword: return 7
        case .internalErrorSignIn(code: _): return 8
        case .internalErrorLogIn(code: _): return 9
        case .alreadySignedInEmail: return 10
        case .alreadySignedIn: return 11
        case .weakPassword: return 12
        case .clubNotExists: return 13
        case .noRegionGiven: return 14
        case .notEuro: return 15
        case .identifierAlreadyExists(code: _): return 16
        case .incorrectPassword: return 17
        case .notSignedIn: return 18
        }
    }

    /// Sub error code
    var errorSubCode: Int? {
        switch self {
        case .emptyField(code: let code),
             .internalErrorSignIn(code: let code),
             .internalErrorLogIn(code: let code),
             .identifierAlreadyExists(code: let code):
            return code
        case .alreadySignedIn,
             .alreadySignedInEmail,
             .clubNotExists,
             .incorrectPassword,
             .invalidEmail,
             .noDigit,
             .noLowerCharacter,
             .noRegionGiven,
             .noUpperCharacter,
             .notEuro,
             .notSamePassword,
             .notSignedIn,
             .tooFewCharacters,
             .weakPassword:
            return nil
        }
    }

    /// Message of the error
    var message: String {
        if let errorSubCode = errorSubCode {
            return "(\(errorCode).\(errorSubCode)) \(rawMessage)"
        }
        return "(\(errorCode)) \(rawMessage)"
    }
}
