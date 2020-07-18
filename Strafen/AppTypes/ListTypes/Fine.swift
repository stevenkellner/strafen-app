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
    
    /// Is fine payed
    var payed: Payed
    
    /// Number of fines
    let number: Int
    
    /// Id of the fine
    let id: UUID
    
    /// Fine reason for reason / amount / importance or templateId
    let fineReason: FineReason
}

// Extension of Fine to confirm to Equatable
extension Fine: Equatable {
    
    /// Function for Equatable
    static func == (lhs: Fine, rhs: Fine) -> Bool {
        var equal = lhs.personId == rhs.personId && lhs.date == rhs.date && lhs.payed == rhs.payed && lhs.number == rhs.number && lhs.id == rhs.id
        if let lhsFineReasonCustom = lhs.fineReason as? FineReasonCustom, equal {
            equal = lhsFineReasonCustom == rhs.fineReason as? FineReasonCustom
        } else if let lhsFineReasonTemplate = lhs.fineReason as? FineReasonTemplate, equal {
            equal = lhsFineReasonTemplate == rhs.fineReason as? FineReasonTemplate
        } else {
            equal = false
        }
        return equal
    }
}

// Extension of Fine to confirm to Decodable
extension Fine: Decodable {
    
    /// Keys for decoding json
    enum Keys: CodingKey {
        
        /// Person id
        case personId
        
        /// Date
        case date
        
        /// Payed
        case payed
        
        /// Number
        case number
        
        /// Id
        case id
        
        /// Reason
        case reason
        
        /// Amount
        case amount
        
        /// Importance
        case importance
        
        /// TemplateId
        case templateId
    }
    
    /// Init from decoder for decodable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        personId = try container.decode(UUID.self, forKey: .personId)
        date = try container.decode(FormattedDate.self, forKey: .date)
        payed = try container.decode(Payed.self, forKey: .payed)
        number = try container.decode(Int.self, forKey: .number)
        id = try container.decode(UUID.self, forKey: .id)
        let reason = try container.decode(Optional<String>.self, forKey: .reason)
        let amount = try container.decode(Optional<Euro>.self, forKey: .amount)
        let importace = try container.decode(Optional<Importance>.self, forKey: .importance)
        let templateId = try container.decode(Optional<UUID>.self, forKey: .templateId)
        if let templateId = templateId {
            fineReason = FineReasonTemplate(templateId: templateId)
        } else {
            fineReason = FineReasonCustom(reason: reason!, amount: amount!, importance: importace!)
        }
    }
}

/// Protocol of fine reason for reason / amount / importance or templateId
protocol FineReason {
    
    /// Reason
    ///
    /// Use it only if reason list is fetched
    var reason: String { get }
    
    /// Amount
    ///
    /// Use it only if reason list is fetched
    var amount: Euro { get }
    
    /// Importance
    ///
    /// Use it only if reason list is fetched
    var importance: Fine.Importance { get }
}

/// Fine Reason for reason / amount / importance
struct FineReasonCustom: FineReason, Equatable {
    
    /// Reason
    let reason: String
    
    /// Amount
    let amount: Euro
    
    /// Importance
    let importance: Fine.Importance
}

/// Fine Reason for templateId
struct FineReasonTemplate: FineReason, Equatable {
    
    /// Template id
    let templateId: UUID
    
    /// Reason
    ///
    /// Use it only if reason list is fetched
    var reason: String {
        ListData.reason.list!.first(where: { $0.id == templateId })!.reason
    }
    
    /// Amount
    ///
    /// Use it only if reason list is fetched
    var amount: Euro {
        ListData.reason.list!.first(where: { $0.id == templateId })!.amount
    }
    
    /// Importance
    ///
    /// Use it only if reason list is fetched
    var importance: Fine.Importance {
        ListData.reason.list!.first(where: { $0.id == templateId })!.importance
    }
}
