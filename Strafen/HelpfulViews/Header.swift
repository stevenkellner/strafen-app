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
    private let title: String?
    
    /// Content
    private let content: Content
    
    private let errorMessages: Binding<ErrorMessages?>?
    
    /// Frame of content
    private var contentFrame: (width: CGFloat?, height: CGFloat?) = (width: nil, height: nil)
    
    init(_ title: String?, errorMessages: Binding<ErrorMessages?>? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.errorMessages = errorMessages
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 5) {
            
            // Title
            if let title = title {
                Title(title)
            }
            
            // Content
            content.frame(width: contentFrame.width, height: contentFrame.height)
            
            // Error message
            if let errorMessages = errorMessages {
                ErrorMessageView(errorMessages: errorMessages)
            }
            
        }
    }
    
    /// Set frame of content
    func contentFrame(size: CGSize) -> TitledContent {
        var content = self
        content.contentFrame = (width: size.width, height: size.height)
        return content
    }
    
    /// Set frame of content
    func contentFrame(width: CGFloat? = nil, height: CGFloat? = nil) -> TitledContent {
        var content = self
        content.contentFrame = (width: width, height: height)
        return content
    }
}

/// Two underlines
struct Underlines: View {
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 5) {
            
            // Top Underline
            HStack {
                Rectangle()
                    .frame(width: 300, height: 2)
                    .border(settings.style == .default ? Color.custom.darkGreen : (colorScheme == .dark ? Color.plain.lightGray : Color.plain.darkGray), width: 1)
                Spacer()
            }
            
            // Bottom Underline
            HStack {
                Rectangle()
                    .frame(width: 275, height: 2)
                    .border(settings.style == .default ? Color.custom.darkGreen : (colorScheme == .dark ? Color.plain.lightGray : Color.plain.darkGray), width: 1)
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
    
    /// Internal error
    case internalErrorDelete
    
    /// Amount mustn't be zero
    case amountZero
    
    /// Person is undeleteable
    case personUndeletable
    
    /// No persons are selected
    case noPersonsSelected
    
    /// No reason given
    case noReasonGiven
    
    /// Future date
    case futureDate
    
    /// Invalid number range
    case invalidNumberRange
    
    /// Late payment interest rate is zero
    case rateIsZero
    
    /// Late payment interest period is zero
    case periodIsZero
    
    /// In app payment currency isn't euro
    case notEuro
    
    /// No fines are selected
    case noFinesSelected
    
    /// Internal error
    case internalError
    
    /// Credit card is invalid
    case invalidCreditCardNumber
    
    /// No valid date format
    case invalidDateFormat
    
    /// Date is in past
    case dateInPast
    
    /// CVV is invalid
    case invalidCvv
    
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
        case .internalErrorDelete:
            return "Es gab ein Problem beim Löschen!"
        case .amountZero:
            return "Betrag darf nicht Null sein!"
        case .personUndeletable:
            return "Nicht löschbar, da sie bereits registriert ist!"
        case .noPersonsSelected:
            return "Keine Person ausgewählt!"
        case .noReasonGiven:
            return "Keine Strafe angegeben!"
        case .futureDate:
            return "Datum darf nicht in der Zukunft liegen!"
        case .invalidNumberRange:
            return "Anzahl muss zwischen 1 und 99 liegen!"
        case .rateIsZero:
            return "Zinssatz darf nicht null sein!"
        case .periodIsZero:
            return "Zeitraum darf nicht null sein!"
        case .notEuro:
            return "Funktioniert nur in Ländern mit Euro!"
        case .noFinesSelected:
            return "Keine Strafen ausgewählt!"
        case .internalError:
            return "Es gab ein Problem!"
        case .invalidCreditCardNumber:
            return "Kartennummer is ungültig!"
        case .invalidDateFormat:
            return "Format vom Datum ist ungültig!"
        case .dateInPast:
            return "Datum muss in der Zukunft liegen!"
        case .invalidCvv:
            return "CVV ist ungültig!"
        }
    }
}
