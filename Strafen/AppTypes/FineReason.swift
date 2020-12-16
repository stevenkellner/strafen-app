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
    func reason(with reasonList: [ReasonTemplate]?) -> String
    
    /// Amount
    func amount(with reasonList: [ReasonTemplate]?) -> Amount
    
    /// Importance
    func importance(with reasonList: [ReasonTemplate]?) -> Importance
    
    /// Parameters for database change call
    var callParameters: NewParameters { get }
}

extension NewFineReason {
    
    /// Complete reason
    func complete(with reasonList: [ReasonTemplate]?) -> NewFineReasonCustom {
        NewFineReasonCustom(reason: reason(with: reasonList),
                       amount: amount(with: reasonList),
                       importance: importance(with: reasonList))
    }
}

/// Fine Reason for reason / amount / importance
struct NewFineReasonCustom: NewFineReason, Equatable {
    
    /// Reason
    let reason: String
    
    /// Amount
    let amount: Amount
    
    /// Importance
    let importance: Importance
    
    /// Reason
    func reason(with reasonList: [ReasonTemplate]?) -> String { reason }
    
    /// Amount
    func amount(with reasonList: [ReasonTemplate]?) -> Amount { amount }
    
    /// Importance
    func importance(with reasonList: [ReasonTemplate]?) -> Importance { importance }
    
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
    let templateId: ReasonTemplate.ID
    
    /// Reason
    func reason(with reasonList: [ReasonTemplate]?) -> String {
        reasonList?.first(where: { $0.id == templateId })?.reason ?? ""
    }
    
    /// Amount
    func amount(with reasonList: [ReasonTemplate]?) -> Amount {
        reasonList?.first(where: { $0.id == templateId })?.amount ?? .zero
    }
    
    /// Importance
    func importance(with reasonList: [ReasonTemplate]?) -> Importance {
        reasonList?.first(where: { $0.id == templateId })?.importance ?? .low
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
    let templateId: ReasonTemplate.ID?
    
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
