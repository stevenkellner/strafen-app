//
//  Importance.swift
//  Strafen
//
//  Created by Steven on 05.05.21.
//

import Foundation

/// Different importances (high / medium / low)
enum Importance: Int {

    /// High importance
    case high = 2

    /// Medium importance
    case medium = 1

    /// Low importance
    case low = 0
}

extension Importance: Decodable {

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

extension Importance: Equatable, Comparable {
    static func < (lhs: Importance, rhs: Importance) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension Importance: FirebaseParameterable {

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

    var primordialParameter: FirebasePrimordialParameterable {
        stringValue
    }
}
