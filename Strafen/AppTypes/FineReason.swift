//
//  FineReason.swift
//  Strafen
//
//  Created by Steven on 11/7/20.
//

import Foundation

/// Protocol of fine reason for reason / amount / importance or templateId
protocol NewFineReason {
    
    /// Reason
    ///
    /// Use it only when reason list is fetched
    var reason: String { get }
    
    /// Amount
    ///
    /// Use it only when reason list is fetched
    var amount: Amount { get }
    
    /// Importance
    ///
    /// Use it only when reason list is fetched
    var importance: Importance { get }
    
    /// Parameters for database change call
    var callParameters: NewParameters { get }
}

/// Fine Reason for reason / amount / importance
struct NewFineReasonCustom: NewFineReason, Equatable {
    
    /// Reason
    let reason: String
    
    /// Amount
    let amount: Amount
    
    /// Importance
    let importance: Importance
    
    /// Parameters for database change call
    var callParameters: NewParameters {
        NewParameters { parameters in
            parameters["reason"] = reason
            parameters["amount"] = amount
            parameters["importance"] = importance
        }
    }
}

/// Fine Reason for templateId
struct NewFineReasonTemplate: NewFineReason, Equatable {
    
    /// Template id
    let templateId: UUID
    
    /// Reason template
    var reasonTemplate: ReasonTemplate? {
        NewListData.reason.list?.first(where: { $0.id == templateId })
    }
    
    /// Reason
    ///
    /// Use it only when reason list is fetched
    var reason: String {
        reasonTemplate?.reason ?? ""
    }
    
    /// Amount
    ///
    /// Use it only when reason list is fetched
    var amount: Amount {
        reasonTemplate?.amount ?? .zero
    }
    
    /// Importance
    ///
    /// Use it only whenreason list is fetched
    var importance: Importance {
        reasonTemplate?.importance ?? .low
    }
    
    /// Parameters for database change call
    var callParameters: NewParameters {
        NewParameters { parameters in
            parameters["templateId"] = templateId
        }
    }
}

/// Codable fine reason to get custom or template fine reason
struct NewCodableFineReason: Decodable {
    
    /// Reason
    let reason: String?
    
    /// Amount
    let amount: Amount?
    
    /// Importance
    let importance: Importance?
    
    /// Template id
    let templateId: UUID?
    
    /// Custom or template fine reason
    var fineReason: NewFineReason {
        if let templateId = templateId {
            return NewFineReasonTemplate(templateId: templateId)
        } else if let reason = reason,
                  let amount = amount,
                  let importance = importance {
            return NewFineReasonCustom(reason: reason, amount: amount, importance: importance)
        } else {
            fatalError("No template id and no properties for custom fine reason.")
        }
    }
}
