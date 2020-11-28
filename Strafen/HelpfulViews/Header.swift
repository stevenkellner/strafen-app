//
//  Header.swift
//  Strafen
//
//  Created by Steven on 28.06.20.
//

import SwiftUI

/// Page Header with underlines
struct Header: View {
    
    /// Page title
    private let title: String
    
    /// Line limit
    private var lineLimit: Int? = 1
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) private var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject private var settings = Settings.shared
    
    public init(_ title: String) {
        self.title = title
    }
    
    public var body: some View {
        VStack(spacing: 10) {
                
            // Title
            HStack {
                Text(title)
                    .foregroundColor(.textColor)
                    .font(.text(35))
                    .padding(.horizontal, 22)
                    .lineLimit(lineLimit)
                Spacer()
            }
            
            // Top Underline
            Underlines()
                
        }
    }
    
    /// Set line limit
    public func lineLimit(_ lineLimit: Int?) -> Header {
        var header = self
        header.lineLimit = lineLimit
        return header
    }
}

/// Title of a textfield
struct Title: View {
    
    /// Title
    private let title: String
    
    public init(_ title: String) {
        self.title = title
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            Text("\(title):")
                .configurate(size: 20)
                .padding(.leading, 10)
            Spacer()
        }
    }
}

/// Content with a title
struct TitledContent<Content>: View where Content: View {
    
    /// Title
    private let title: String
    
    /// Content
    private let content: Content
    
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 5) {
            
            // Title
            Title(title)
            
            // Content
            content
            
        }
    }
}

/// Two underlines
struct Underlines: View {
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = NewSettings.shared
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 5) {
            
            // Top Underline
            HStack {
                Rectangle()
                    .frame(width: 300, height: 2)
                    .border(settings.properties.style == .default ? Color.custom.darkGreen : (colorScheme == .dark ? Color.plain.lightGray : Color.plain.darkGray), width: 1)
                Spacer()
            }
            
            // Bottom Underline
            HStack {
                Rectangle()
                    .frame(width: 275, height: 2)
                    .border(settings.properties.style == .default ? Color.custom.darkGreen : (colorScheme == .dark ? Color.plain.lightGray : Color.plain.darkGray), width: 1)
                Spacer()
            }
            
        }
    }
}


/// Error messages under a textfield
struct ErrorMessageView: View {
    
    /// Type of the error message
    @Binding public var errorMessages: ErrorMessages?
    
    public var body: some View {
        if let errorMessages = errorMessages {
            Text(errorMessages.message)
                .foregroundColor(Color.custom.red)
                .font(.text(20))
                .lineLimit(1)
                .padding(.horizontal, 15)
        }
    }
}

/// Error messages
enum ErrorMessages {
    
    /// Textfield is empty
    case emptyField
    
    /// Club doesn't exist
    case clubNotExists
    
    /// Internal error
    case internalErrorSignIn
    
    /// Invalid email
    case emailNotRegistered
    
    /// Internal error
    case internalErrorLogIn
    
    /// Password is incorrect
    case incorrectPassword
    
    /// Not signed in
    case notSignedIn
    
    /// Invalid email
    case invalidEmail
    
    /// Email is already signed in
    case alreadySignedIn
    
    /// Apple id is already signed in
    case alreadySignedInApple
    
    /// Less than 8 characters
    case tooFewCharacters
    
    /// No upper character in Password
    case noUpperCharacter
    
    /// No lower character in Password
    case noLowerCharacter
    
    /// No digit in Password
    case noDigit
    
    /// Passwword is too weak
    case weakPassword
    
    /// Not same password
    case notSamePassword
    
    /// Club identifier already exists
    case identifierAlreadyExists
    
    /// No region given
    case noRegionGiven
    
    /// Internal error
    case internalErrorSave
    
    /// Amount mustn't be zero
    case amountZero
    
    /// Message of the error
    var message: String {
        switch self {
        case .emptyField:
            return "Dieses Feld darf nicht leer sein!"
        case .clubNotExists:
            return "Es gibt keinen Verein mit dieser Kennung!"
        case .internalErrorSignIn:
            return "Es gab ein Problem beim Registrieren!"
        case .emailNotRegistered:
            return "Diese Email-Adresse ist nicht registriert!"
        case .internalErrorLogIn:
            return "Es gab ein Problem beim Anmelden!"
        case .incorrectPassword:
            return "Das eingegebene Passwort ist falsch!"
        case .notSignedIn:
            return "Du bist noch nicht registriert!"
        case .invalidEmail:
            return "Dies ist keine gültige Email!"
        case .alreadySignedIn:
            return "Diese Email ist bereits registriert!"
        case .alreadySignedInApple:
            return "Diese Apple-Id existiert bereits!"
        case .tooFewCharacters:
            return "Passwort ist zu kurz!"
        case .noUpperCharacter:
            return "Muss einen Großbuchstaben enthalten!"
        case .noLowerCharacter:
            return "Muss einen Kleinbuchstaben enthalten!"
        case .noDigit:
            return "Muss eine Zahl enthalten!"
        case .weakPassword:
            return "Das Passwort ist zu schwach!"
        case .notSamePassword:
            return "Passwörter stimmen nicht überein!"
        case .identifierAlreadyExists:
            return "Vereinskennung ist bereits vergeben!"
        case .noRegionGiven:
            return "Keine Region angegeben!"
        case .internalErrorSave:
            return "Es gab ein Problem beim Speichern!"
        case .amountZero:
            return "Betrag darf nicht Null sein!"
        }
    }
}
