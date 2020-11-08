//
//  Amount.swift
//  Strafen
//
//  Created by Steven on 11/8/20.
//

import Foundation

/// Stores an amount
struct Amount {
    
    /// Value of the amount
    @NonNegative private var value: Int = .zero
    
    /// Value of the subunit of this amount
    @Clamping(0...99) private var subUnitValue: Int = .zero
    
    /// Init with euro and cent
    init(_ value: Int, subUnit: Int) {
        self.value = value
        self.subUnitValue = subUnit
    }
}

// Extension of Amount to confirm to CustomStringConvertible
extension Amount: CustomStringConvertible {
    
    /// Description
    var description: String {
        let doubleValue = Double(value) + Double(subUnitValue) / 100
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "de_DE") // TODO
        numberFormatter.numberStyle = .currency
        return numberFormatter.string(from: NSNumber(value: doubleValue)) ?? numberFormatter.string(from: 0)!
    }
}

// Extension of Amount to confirm to CustomDebugStringConvertible
extension Amount: CustomDebugStringConvertible {
    
    /// Debug description
    var debugDescription: String {
        let doubleValue = Double(value) + Double(subUnitValue) / 100
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        numberFormatter.numberStyle = .currency
        return numberFormatter.string(from: NSNumber(value: doubleValue)) ?? numberFormatter.string(from: 0)!
    }
}

// Extension of Amount to confirm to AdditiveArithmetic
extension Amount: AdditiveArithmetic {
    
    static var zero: Amount {
        Amount(.zero, subUnit: .zero)
    }
    
    static func +(lhs: Amount, rhs: Amount) -> Amount {
        let newSubUnitValue = lhs.subUnitValue + rhs.subUnitValue
        let value = lhs.value + rhs.value + newSubUnitValue / 100
        let subUnitValue = newSubUnitValue % 100
        return Amount(value, subUnit: subUnitValue)
    }
    
    static func -(lhs: Amount, rhs: Amount) -> Amount {
        let newSubUnitValue = lhs.subUnitValue - rhs.subUnitValue
        let value = lhs.value - rhs.value - (newSubUnitValue >= 0 ? 0 : 1)
        let subUnitValue = (newSubUnitValue + 100) % 100
        guard value >= 0 else { return .zero }
        return Amount(value, subUnit: subUnitValue)
    }
}

// Extension of Amount to confirm to Equatable
extension Amount: Equatable {
    static func ==(lhs: Amount, rhs: Amount) -> Bool {
        lhs.value == rhs.value && lhs.subUnitValue == rhs.subUnitValue
    }
}

// Extension of Amount to confirm to Comparable
extension Amount: Comparable {
    static func <(lhs: Amount, rhs: Amount) -> Bool {
        if lhs.value < rhs.value {
            return true
        } else if lhs.value == rhs.value && lhs.subUnitValue < rhs.subUnitValue {
            return true
        }
        return false
    }
}

// Extension of Amount to confirm to Decodable
extension Amount: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawAmount = try container.decode(Double.self)
        
        // Check if amount is positive
        guard rawAmount >= 0 else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Amount is negative.")
        }
        
        self.value = Int(rawAmount)
        self.subUnitValue = Int(rawAmount * 100) - value * 100
    }
}

// Extension of Amount to confirm to Encodable
extension Amount: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let doubleValue = Double(value) + Double(subUnitValue) / 100
        try container.encode(doubleValue)
    }
}

// Extension of Amount to confirm to ParameterableObject
extension Amount: ParameterableObject {
    
    /// Double value
    var doubleValue: Double {
        Double(value) + Double(subUnitValue) / 100
    }
    
    // Object call with Firebase function as Parameter
    var parameterableObject: _ParameterableObject {
        doubleValue
    }
}
