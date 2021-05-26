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
    
    private var color: Color? = nil
    
    public init(_ title: String) {
        self.title = title
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            Text("\(title):")
                .font(.text(20))
                .foregroundColor(color ?? .textColor)
                .lineLimit(1)
                .padding(.leading, 10)
            Spacer()
        }
    }
    
    func color(_ color: Color?) -> Title {
        var title = self
        title.color = color
        return title
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
    
    private var titleColor: Color? = nil
    
    init(_ title: String?, errorMessages: Binding<ErrorMessages?>? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.errorMessages = errorMessages
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 5) {
            
            // Title
            if let title = title {
                Title(title).color(titleColor)
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
    
    func titleColor(_ color: Color) -> TitledContent {
        var content = self
        content.titleColor = color
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
    case emptyField(code: Int)
    
    /// Club doesn't exist
    case clubNotExists
    
    /// Internal error
    case internalErrorSignIn(code: Int)
    
    /// Invalid email
    case emailNotRegistered
    
    /// Internal error
    case internalErrorLogIn(code: Int)
    
    /// Password is incorrect
    case incorrectPassword
    
    /// Not signed in
    case notSignedIn(code: Int)
    
    /// Invalid email
    case invalidEmail(code: Int)
    
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
    
    /// Password is too weak
    case weakPassword
    
    /// Not same password
    case notSamePassword
    
    /// Club identifier already exists
    case identifierAlreadyExists(code: Int)
    
    /// No region given
    case noRegionGiven
    
    /// Internal error
    case internalErrorSave(code: Int)
    
    /// Internal error
    case internalErrorDelete(code: Int)
    
    /// Amount mustn't be zero
    case amountZero(code: Int)
    
    /// Person is undeleteable
    case personUndeletable
    
    /// No persons are selected
    case noPersonsSelected(code: Int)
    
    /// No reason given
    case noReasonGiven
    
    /// No reason selected
    case noReasonSelected
    
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
    
    /// Raw message of the error
    var rawMessage: String {
        switch self {
        case .emptyField(code: _):
            return "Dieses Feld darf nicht leer sein!"
        case .clubNotExists:
            return "Es gibt keinen Verein mit dieser Kennung!"
        case .internalErrorSignIn(code: _):
            return "Es gab ein Problem beim Registrieren!"
        case .emailNotRegistered:
            return "Diese Email-Adresse ist nicht registriert!"
        case .internalErrorLogIn(code: _):
            return "Es gab ein Problem beim Anmelden!"
        case .incorrectPassword:
            return "Das eingegebene Passwort ist falsch!"
        case .notSignedIn(code: _):
            return "Du bist noch nicht registriert!"
        case .invalidEmail(code: _):
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
        case .identifierAlreadyExists(code: _):
            return "Vereinskennung ist bereits vergeben!"
        case .noRegionGiven:
            return "Keine Region angegeben!"
        case .internalErrorSave(code: _):
            return "Es gab ein Problem beim Speichern!"
        case .internalErrorDelete(code: _):
            return "Es gab ein Problem beim Löschen!"
        case .amountZero(code: _):
            return "Betrag darf nicht Null sein!"
        case .personUndeletable:
            return "Nicht löschbar, da sie bereits registriert ist!"
        case .noPersonsSelected(code: _):
            return "Keine Person ausgewählt!"
        case .noReasonGiven:
            return "Keine Strafe angegeben!"
        case .noReasonSelected:
            return "Keine Strafe ausgewählt!"
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
    
    /// Error code
    var errorCode: Int {
        switch self {
        case .emptyField(code: _): return 1
        case .internalErrorSignIn(code: _): return 2
        case .internalErrorLogIn(code: _): return 3
        case .identifierAlreadyExists(code: _): return 4
        case .notSignedIn(code: _): return 5
        case .invalidEmail(code: _): return 6
        case .internalErrorSave(code: _): return 7
        case .internalErrorDelete(code: _): return 8
        case .noPersonsSelected(code: _): return 9
        case .amountZero(code: _): return 10
        case .alreadySignedIn: return 11
        case .clubNotExists: return 12
        case .incorrectPassword: return 13
        case .noDigit: return 14
        case .noLowerCharacter: return 15
        case .noRegionGiven: return 16
        case .noUpperCharacter: return 17
        case .notEuro: return 18
        case .notSamePassword: return 19
        case .tooFewCharacters: return 20
        case .weakPassword: return 21
        case .emailNotRegistered: return 22
        case .alreadySignedInApple: return 23
        case .personUndeletable: return 24
        case .noReasonGiven: return 25
        case .noReasonSelected: return 26
        case .futureDate: return 27
        case .invalidNumberRange: return 28
        case .rateIsZero: return 29
        case .periodIsZero: return 30
        case .noFinesSelected: return 31
        case .internalError: return 32
        case .invalidCreditCardNumber: return 33
        case .invalidDateFormat: return 34
        case .dateInPast: return 35
        case .invalidCvv: return 36
        }
    }
    
    /// Sub error code
    var errorSubCode: Int? {
        switch self {
        case .emptyField(code: let code),
             .internalErrorSignIn(code: let code),
             .internalErrorLogIn(code: let code),
             .identifierAlreadyExists(code: let code),
             .notSignedIn(code: let code),
             .invalidEmail(code: let code),
             .internalErrorSave(code: let code),
             .internalErrorDelete(code: let code),
             .noPersonsSelected(code: let code),
             .amountZero(code: let code):
            return code
        case .alreadySignedIn,
             .clubNotExists,
             .incorrectPassword,
             .noDigit,
             .noLowerCharacter,
             .noRegionGiven,
             .noUpperCharacter,
             .notEuro,
             .notSamePassword,
             .tooFewCharacters,
             .weakPassword,
             .emailNotRegistered,
             .alreadySignedInApple,
             .personUndeletable,
             .noReasonGiven,
             .noReasonSelected,
             .futureDate,
             .invalidNumberRange,
             .rateIsZero,
             .periodIsZero,
             .noFinesSelected,
             .internalError,
             .invalidCreditCardNumber,
             .invalidDateFormat,
             .dateInPast,
             .invalidCvv:
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
