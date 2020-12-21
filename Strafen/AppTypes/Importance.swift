//
//  Importance.swift
//  Strafen
//
//  Created by Steven on 11/7/20.
//

import SwiftUI

/// Different importances (high / medium / low)
enum Importance: Int {
    
    /// High importance
    case high = 2
    
    /// Medium importance
    case medium = 1
    
    /// Low importance
    case low = 0
    
    /// Color of the imporance in the UI
    var color: Color {
        switch self {
        case .high:
            return Color.custom.red
        case .medium:
            return Color.custom.orange
        case .low:
            return Color.custom.yellow
        }
    }
}

// Extension of Importance to confirm to Decodable
extension Importance: Decodable {
    
    /// Init from decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawImportance = try container.decode(String.self)
        switch rawImportance {
        case "high":
            self = .high
        case "medium":
            self = .medium
        case "low":
            self = .low
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid importance: \(rawImportance)")
        }
    }
}

// Extension of Importance to confirm to Comparable
extension Importance: Equatable, Comparable {
    static func < (lhs: Importance, rhs: Importance) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

#if TARGET_MAIN_APP
// Extension of Importance to confirm to ParameterableObject
extension Importance: ParameterableObject {
    
    /// String value
    var stringValue: String {
        switch self {
        case .high:
            return "high"
        case .medium:
            return "medium"
        case .low:
            return "low"
        }
    }
    
    // Object call with Firebase function as Parameter
    var parameterableObject: _ParameterableObject {
        stringValue
    }
}
#endif
