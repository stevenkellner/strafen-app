//
//  Amount.swift
//  Strafen
//
//  Created by Steven on 05.05.21.
//

import SwiftUI

/// Stores an amount
struct Amount {

    /// Value of the amount
    @NonNegative private var value: Int = .zero

    /// Value of the subunit of this amount
    @Clamping(0...99) private var subUnitValue: Int = .zero

    /// Init with euro and cent
    /// - Parameters:
    ///   - value: value of the amount
    ///   - subUnit: value of the subunit of the amount
    init(_ value: Int, subUnit: Int) {
        self.value = value
        self.subUnitValue = subUnit
    }

    /// Double value
    var doubleValue: Double {
        Double(value) + Double(subUnitValue) / 100
    }

    /// String value
    var stringValue: String {
        if subUnitValue == 0 {
            return "\(value)"
        } else if (1..<10).contains(subUnitValue) {
            return "\(value),0\(subUnitValue)"
        } else {
            return "\(value),\(subUnitValue)"
        }
    }
}

extension Amount: CustomStringConvertible {

    /// Locale
    static var locale: Locale {
        let countryCodeKey = Settings.shared.person?.club.regionCode ?? NSLocalizedString("region-code", tableName: "OtherTexts", value: "DE", comment: "Region code")
        let languageCodeKey = Locale.current.languageCode ?? NSLocalizedString("language-code", tableName: "OtherTexts", value: "de", comment: "Language code")
        let identifier = Locale.identifier(fromComponents: [
            "kCFLocaleCountryCodeKey": countryCodeKey,
            "kCFLocaleLanguageCodeKey": languageCodeKey
        ])
        return Locale(identifier: identifier)
    }

    var description: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Amount.locale
        numberFormatter.numberStyle = .currency
        return numberFormatter.string(from: NSNumber(value: doubleValue)) ?? numberFormatter.string(from: 0)!
    }
}

extension Amount: CustomDebugStringConvertible {

    var debugDescription: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        numberFormatter.numberStyle = .currency
        return numberFormatter.string(from: NSNumber(value: doubleValue)) ?? numberFormatter.string(from: 0)!
    }
}

extension Amount: AdditiveArithmetic {

    static var zero: Amount {
        Amount(.zero, subUnit: .zero)
    }

    static func + (lhs: Amount, rhs: Amount) -> Amount {
        let newSubUnitValue = lhs.subUnitValue + rhs.subUnitValue
        let value = lhs.value + rhs.value + newSubUnitValue / 100
        let subUnitValue = newSubUnitValue % 100
        return Amount(value, subUnit: subUnitValue)
    }

    static func - (lhs: Amount, rhs: Amount) -> Amount {
        let newSubUnitValue = lhs.subUnitValue - rhs.subUnitValue
        let value = lhs.value - rhs.value - (newSubUnitValue >= 0 ? 0 : 1)
        let subUnitValue = (newSubUnitValue + 100) % 100
        guard value >= 0 else { return .zero }
        return Amount(value, subUnit: subUnitValue)
    }
}

extension Amount: VectorArithmetic {

    mutating func scale(by rhs: Double) {
        self *= rhs
    }

    var magnitudeSquared: Double {
        doubleValue.magnitudeSquared
    }
}

extension Amount {

    /// Multiplies amount with an Int
    /// - Parameters:
    ///   - amount: amount value
    ///   - multiplier: multiplier
    /// - Returns: multiplied value
    static func * (amount: Amount, multiplier: Int) -> Amount {
        let multiplier = abs(multiplier)
        let value = amount.value * multiplier + (amount.subUnitValue * multiplier) / 100
        let subUnitValue = (amount.subUnitValue * multiplier) % 100
        return Amount(value, subUnit: subUnitValue)
    }

    /// Multiplies amount with an Double
    /// - Parameters:
    ///   - amount: amount value
    ///   - multiplier: multiplier
    /// - Returns: multiplied value
    static func * (amount: Amount, multiplier: Double) -> Amount {
        let multiplier = abs(multiplier)
        let doubleValue = amount.doubleValue * multiplier
        let value = Int(doubleValue)
        let subUnitValue = Int(doubleValue * 100) - value * 100
        return Amount(value, subUnit: subUnitValue)
    }

    // swiftlint:disable shorthand_operator

    /// Multiplies amount with an Int
    /// - Parameters:
    ///   - amount: amount value
    ///   - multiplier: multiplier
    static func *= (amount: inout Amount, multiplier: Int) {
        amount = amount * multiplier
    }

    /// Multiplies amount with an Double
    /// - Parameters:
    ///   - amount: amount value
    ///   - multiplier: multiplier
    static func *= (amount: inout Amount, multiplier: Double) {
        amount = amount * multiplier
    }
}

extension Amount: Equatable {

    static func == (lhs: Amount, rhs: Amount) -> Bool {
        lhs.value == rhs.value && lhs.subUnitValue == rhs.subUnitValue
    }
}

extension Amount: Comparable {

    static func < (lhs: Amount, rhs: Amount) -> Bool {
        if lhs.value < rhs.value {
            return true
        } else if lhs.value == rhs.value && lhs.subUnitValue < rhs.subUnitValue {
            return true
        }
        return false
    }
}

extension Amount: Decodable {

    /// Init amount with a double value
    /// - Parameter doubleValue: double value
    init(doubleValue: Double) {
        let doubleValue = abs(doubleValue)
        self.value = Int(doubleValue)
        self.subUnitValue = Int(doubleValue * 100) - value * 100
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawAmount = try container.decode(Double.self)

        // Check if amount is positive
        guard rawAmount >= 0 else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Amount is negative.")
        }

        self.init(doubleValue: rawAmount)
    }
}

extension Amount: FirebaseParameterable {

    var primordialParameter: FirebasePrimordialParameterable {
        doubleValue
    }
}

/// Used to parse string to amount
struct AmountParser {

    /// Parses string to amount
    /// - Parameter amountString: string to parse
    /// - Returns: parsed amount
    static func fromString(_ amountString: String) -> Amount {

        var commaPassed = false
        var newString = ""

        // Filter all invalid characters out
        let validCharacters = (0..<10).map { Character(String($0)) }.appending(",")
        for char in amountString where validCharacters.contains(char) {
            if char == "," && commaPassed {
                continue
            } else if char == "," && !commaPassed {
                commaPassed = true
            }
            newString.append(char)
        }

        // String is empty
        guard !newString.isEmpty else { return .zero }

        // No subunit value
        if !commaPassed {
            guard let value = Int(newString) else { return .zero }
            return Amount(value, subUnit: .zero)
        }

        // String contains only a comma
        guard newString.count != 1 else { return .zero }

        // Get value and subunit value
        var componentsIterator = newString.components(separatedBy: ",").makeIterator()
        guard let valueString = componentsIterator.next(),
              let value = valueString.isEmpty ? .zero : Int(valueString),
              let subUnitString = componentsIterator.next() else { return .zero }

        // Empty subunit string
        guard !subUnitString.isEmpty else { return Amount(value, subUnit: .zero) }

        // Only decimal digit
        if subUnitString.count == 1 {
            guard let subUnitValue = Int(subUnitString) else { return .zero }
            return Amount(value, subUnit: subUnitValue * 10)

        }

        // Both digits
        if subUnitString.count == 2 {
            guard let subUnitValue = Int(subUnitString) else { return .zero }
            return Amount(value, subUnit: subUnitValue)
        }

        // More than two digit
        var subUnitIterator = subUnitString.makeIterator()
        guard let tenthCharacter = subUnitIterator.next(),
              let hundredthCharacter = subUnitIterator.next(),
              let thousandthCharacter = subUnitIterator.next(),
              let tenth = Int(String(tenthCharacter)),
              let hundredth = Int(String(hundredthCharacter)),
              let thousandth = Int(String(thousandthCharacter))
              else { return .zero }
        let decimal = tenth * 10 + hundredth
        if thousandth >= 5 {
            if decimal == 99 {
                return Amount(value + 1, subUnit: .zero)
            }
            return Amount(value, subUnit: decimal + 1)
        }
        return Amount(value, subUnit: decimal)
    }
}
