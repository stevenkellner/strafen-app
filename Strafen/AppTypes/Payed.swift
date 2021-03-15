//
//  Payed.swift
//  Strafen
//
//  Created by Steven on 11/7/20.
//

import Foundation

/// Fine payed
enum Payed {
    
    /// Payed
    case payed(date: Date, inApp: Bool)
    
    /// Settled
    case settled
    
    /// Unpayed
    case unpayed
}

// Extension of Payed to confirm to Decodable
extension Payed: Decodable, Equatable {
    
    /// Used to decode payed state and date
    private struct CodablePayed: Decodable {
        
        /// State (payed ot unpayed)
        let state: String
        
        /// Date of payment
        let payDate: Date?
        
        /// Payed with in app payment
        let inApp: Bool?
    }
    
    /// Init from decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawPayed = try container.decode(CodablePayed.self)
        switch rawPayed.state {
        case "unpayed":
            self = .unpayed
        case "settled":
            self = .settled
        case "payed":
            guard let date = rawPayed.payDate else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Date for payed not found.")
            }
            self = .payed(date: date, inApp: rawPayed.inApp ?? false)
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid state found: \(rawPayed.state)")
        }
    }
}

#if TARGET_MAIN_APP
// Extension of Payed to confirm to ParameterableObject
extension Payed: ParameterableObject {
    
    /// State of payment
    var state: String {
        switch self {
        case .unpayed:
            return "unpayed"
        case .settled:
            return "settled"
        case .payed(date: _, inApp: _):
            return "payed"
        }
    }
    
    /// Pay date (only for payed)
    var payDate: Date? {
        switch self {
        case .unpayed:
            return nil
        case .settled:
            return nil
        case .payed(date: let date, inApp: _):
            return date
        }
    }
    
    var payedInApp: Bool {
        switch self {
        case .unpayed:
            return false
        case .settled:
            return false
        case .payed(date: _, inApp: let inApp):
            return inApp
        }
    }
    
    /// Object call with Firebase function as Parameter
    var parameterableObject: _ParameterableObject {
        ["state": state, "payDate": payDate?.parameterableObject]
    }
}
#endif
