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
    
    /// Email is already signed in
    case alreadySignedIn
    
    /// Passwword is too weak
    case weakPassword
    
    /// Club doesn't exist
    case clubNotExists
    
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
        case .alreadySignedIn:
            return "Diese Email ist bereits registriert!"
        case .weakPassword:
            return "Das Passwort ist zu schwach!"
        case .clubNotExists:
            return "Es gibt keinen Verein mit dieser Kennung!"
        }
    }
}
