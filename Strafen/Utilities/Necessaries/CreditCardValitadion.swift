//
//  CreditCardValitadion.swift
//  Strafen
//
//  Created by Steven on 3/8/21.
//

import Foundation

/// Used validate a credit card and get type of the card
struct CreditCardValitation {
    
    /// Type of credit card (e.g. Visa or MasterCard)
    enum CardType: CaseIterable {
        case visa
        case mastercard
        case americanEpress
        case dinerClub
        case discover
        case jcb
        
        /// Regex to check card
        var validationRegex: String {
            switch self {
            case .visa:
                return "^4[0-9]{6,}$"
            case .mastercard:
                return "^5[1-5][0-9]{5,}|222[1-9][0-9]{3,}|22[3-9][0-9]{4,}|2[3-6][0-9]{5,}|27[01][0-9]{4,}|2720[0-9]{3,}$"
            case .americanEpress:
                return "^3[47][0-9]{5,}$"
            case .dinerClub:
                return "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$"
            case .discover:
                return "^6(?:011|5[0-9]{2})[0-9]{3,}$"
            case .jcb:
                return "^(?:2131|1800|35[0-9]{3})[0-9]{3,}$"
            }
        }
        
        var style: String {
            switch self {
            case .visa:
                return "#### #### #### ####"
            case .mastercard:
                return "#### #### #### ####"
            case .americanEpress:
                return "#### ##### #####"
            case .dinerClub:
                return "#### ###### ####"
            case .discover:
                return "#### #### #### ####"
            case .jcb:
                return "#### #### #### ####"
            }
        }
        
        var imageName: String {
            switch self {
            case .visa:
                return "visa_icon"
            case .mastercard:
                return "master_card_icon"
            case .americanEpress:
                return "amex_icon"
            case .dinerClub:
                return "diner_club_icon"
            case .discover:
                return "discover_icon"
            case .jcb:
                return "jcb_icon"
            }
        }
    }
    
    /// Number of credit card
    @OnlyNumbers private var cardNumber = ""
    
    /// Expiration date
    @OnlyNumbers private var expirationDate = ""
    
    /// CVV
    @OnlyNumbers private var cvv = ""
    
    private(set) var possibleCardTypes = CardType.allCases
    
    mutating func formatCardNumber(_ cardNumber: String) -> String {
        self.cardNumber = cardNumber
        possibleCardTypes = []
        for cardType in CardType.allCases {
            let predicate = NSPredicate(format:"SELF MATCHES %@", cardType.validationRegex)
            if predicate.evaluate(with: self.cardNumber) {
                possibleCardTypes.append(cardType)
            }
        }
        if self.cardNumber.isEmpty {
            possibleCardTypes = CardType.allCases
        }
        return formattedCardNumber
    }
    
    mutating func formatExpirationDate(_ expirationDate: String) -> String {
        self.expirationDate = expirationDate
        return formattedExpirationDate
    }
    
    mutating func formatCvv(_ cvv: String) -> String {
        self.cvv = cvv
        self.cvv = formattedCvv
        return formattedCvv
    }
    
    var formattedCardNumber: String {
        guard let cardType = possibleCardTypes.first else { return cardNumber }
        var formattedNumber = Array(cardType.style)
        for char in cardNumber {
            guard let index = formattedNumber.firstIndex(of: "#") else {
                formattedNumber.append(char)
                continue
            }
            formattedNumber[index] = char
        }
        if let index = formattedNumber.firstIndex(of: "#") {
            guard index != 0 else { return "" }
            formattedNumber = Array(formattedNumber[0..<index])
        }
        return formattedNumber.map(String.init).joined()
    }
    
    var formattedExpirationDate: String {
        var newValue = ""
        for (index, char) in expirationDate.enumerated() {
            if index == 2 { newValue.append(" ") }
            newValue.append(char)
            if index == 1 { newValue.append(" /") }
        }
        return newValue
    }
    
    var formattedCvv: String {
        return String(cvv.prefix(3))
    }
    
    var isCardNumberValid: Bool {
        !possibleCardTypes.isEmpty
    }
    
    var isExpirationDateValid: Bool {
        let predicate = NSPredicate(format:"SELF MATCHES %@", "^(?:0[1-9]|10|11|12)[0-9]{2}$")
        return predicate.evaluate(with: expirationDate)
    }
    
    var isExpirationDateInFuture: Bool {
        guard isExpirationDateValid else { return false }
        guard let month = Int(expirationDate.prefix(2)),
              let year = Int(expirationDate.suffix(2)) else { return false }
        let currentYear = Calendar.current.component(.year, from: Date()) - 2000
        let currentMonth = Calendar.current.component(.month, from: Date())
        if year > currentYear { return true }
        if year < currentYear { return false }
        if month < currentMonth { return false }
        return true
    }
    
    var isCvvValid: Bool {
        let predicate = NSPredicate(format:"SELF MATCHES %@", "^[0-9]{3}$")
        return predicate.evaluate(with: cvv)
    }
}

@propertyWrapper struct OnlyNumbers {
    
    private var value: String
    
    init(wrappedValue value: String) {
        self.value = Self.formatted(value)
    }
    
    var wrappedValue: String {
        get { value }
        set { value = Self.formatted(newValue) }
    }
    
    private static func formatted(_ value: String) -> String {
        var newValue = ""
        for char in value where (0...9).map(String.init).map(Character.init).contains(char) {
            newValue.append(char)
        }
        return newValue
    }
}
