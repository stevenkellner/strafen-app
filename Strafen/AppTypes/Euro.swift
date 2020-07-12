//
//  Euro.swift
//  Strafen
//
//  Created by Steven on 12.07.20.
//

import Foundation

/// UInt with max value of 99
@propertyWrapper
struct UIntMax99 {
    
    /// Stored number
    private var number: UInt
    
    init() { number = 0 }
    
    init(_ number: UInt) { self.number = min(number, 99) }
    
    /// Wrapped value with max value of 99
    var wrappedValue: UInt {
        get { number }
        set { number = min(newValue, 99) }
    }
}

// Extension of UIntMax99 for ExpressibleByIntegerLiteral
extension UIntMax99: ExpressibleByIntegerLiteral {
    init(integerLiteral value: IntegerLiteralType) { self.init(UInt(abs(value))) }
}

/// Stores an amount in euro
struct Euro {
    
    /// Euro value
    let euro: UInt
    
    /// Cent value
    @UIntMax99 var cent: UInt
    
    /// Init with euro and cent
    init(euro: UInt, cent: UInt) {
        self.euro = euro
        self.cent = cent
    }
    
    /// Zero value
    static let zero = Euro(euro: 0, cent: 0)
}

// Extenstion of Euro to confirm to CustomStringConvertible
extension Euro: CustomStringConvertible {
    
    /// String value of amount
    var stringValue: String {
        if cent == 0 {
            return "\(euro)"
        } else if (1..<10).contains(Int(cent)) {
            return "\(euro),0\(cent)"
        } else {
            return "\(euro),\(cent)"
        }
    }
    
    /// Description
    var description: String {
        "\(stringValue)€"
    }
}

// Extension of Euro to multiply with Int and adding to another Euro
extension Euro: Equatable {
    
    static func ==(lhs: Euro, rhs: Euro) -> Bool {
        lhs.euro == rhs.euro && lhs.cent == rhs.cent
    }

    static func *(amount: Euro, multiplier: Int) -> Euro {
        let cent = (amount.cent * UInt(abs(multiplier))) % 100
        let euro = amount.euro * UInt(abs(multiplier)) + UInt((amount.cent * UInt(abs(multiplier))) / 100)
        return Euro(euro: euro, cent: cent)
    }
    
    static func +(lhs: Euro, rhs: Euro) -> Euro {
        let cent = (lhs.cent + rhs.cent) % 100
        let euro = lhs.euro + rhs.euro + UInt((lhs.cent + rhs.cent) / 100)
        return Euro(euro: euro, cent: cent)
    }
}

// Extension of Euro for Decodable
extension Euro: Decodable {
    
    /// Init from decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawAmount = try container.decode(Double.self)
        let euroCent = UInt(round(abs(rawAmount) * 100))
        euro = UInt(abs(rawAmount))
        cent = euroCent - euro * 100
    }
}
