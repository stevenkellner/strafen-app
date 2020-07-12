//
//  Fine.swift
//  Strafen
//
//  Created by Steven on 12.07.20.
//

import SwiftUI

/// Contains all data of a fine
struct Fine: Identifiable, ListTypes {
    
    /// Url to list on server
    static let serverListUrl = \AppUrls.listTypesUrls?.fine
    
    /// Importance of a fine
    enum Importance: Int, Decodable {
        
        /// High importance
        case high = 2
        
        /// Medium importance
        case medium = 1
        
        /// Low importance
        case low = 0
        
        /// Error for decoding json
        enum CodingError: Error {
            
            /// Error for unknown string value
            case unknownStringValue
        }
        
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
                throw CodingError.unknownStringValue
            }
        }
        
        /// Checks if an importance is higher or equal than another one
        static func >=(lhs: Importance, rhs: Importance) -> Bool {
            lhs.rawValue >= rhs.rawValue
        }
        
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
    
    /// Fine payed
    enum Payed: Decodable {
        
        /// payed
        case payed
        
        /// unpayed
        case unpayed
        
        /// Init from decoder
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawPayed = try container.decode(Bool.self)
            self = rawPayed ? .payed : .unpayed
        }
        
        /// True if is payed
        var boolValue: Bool {
            self == .payed
        }
    }
    
    /// Id of the associated person
    let personId: UUID
    
    /// Date this fine was issued
    let date: FormattedDate
    
    /// Reason why the fine was issued
    var reason: String?
    
    /// Amount of the fine
    var amount: Euro?
    
    /// Is fine payed
    var payed: Payed
    
    /// Number of fines
    let number: Int
    
    /// importance of fine
    var importance: Importance?
    
    /// Id of the fine
    let id: UUID
    
    /// Id of the template if it's from a template
    var templateId: UUID?
    
    var wrappedReason: String {
        if let template = ListData.reason.list!.first(where: { $0.id == templateId }) {
            return template.reason
        } else {
            return reason!
        }
    }
    
    var wrappedAmount: Euro {
        if let template = ListData.reason.list!.first(where: { $0.id == templateId }) {
            return template.amount
        } else {
            return amount!
        }
    }
    
    var wrappedImportance: Importance {
        if let template = ListData.reason.list!.first(where: { $0.id == templateId }) {
            return template.importance
        } else {
            return importance!
        }
    }
}
