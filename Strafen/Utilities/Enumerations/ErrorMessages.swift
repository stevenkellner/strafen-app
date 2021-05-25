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

    /// Email is already signed in
    case alreadySignedInEmail

    /// User is already signed in
    case alreadySignedIn

    /// Passwword is too weak
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

    /// Message of the error
    var message: String {
        switch self {
        case .emptyField:
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
        case .internalErrorSignIn:
            return "Es gab ein Problem beim Registrieren!"
        case .internalErrorLogIn:
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
        case .identifierAlreadyExists:
            return "Vereinskennung ist bereits vergeben!"
        case .incorrectPassword:
            return "Das eingegebene Passwort ist falsch!"
        case .notSignedIn:
            return "Du bist noch nicht registriert!"
        }
    }
}
