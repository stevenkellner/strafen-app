//
//  FineReason.swift
//  Strafen
//
//  Created by Steven on 05.05.21.
//

import Foundation

/// Protocol of fine reason for reason / amount / importance or templateId
protocol FineReason {

    /// Reason of the fine
    /// - Parameter reasonList: list of firebase reason templates
    func reason(with reasonList: [FirebaseReasonTemplate]) -> String

    /// Amount of the amount
    /// - Parameter reasonList: list of firebase reason templates
    func amount(with reasonList: [FirebaseReasonTemplate]) -> Amount

    /// Importance of the fine
    /// - Parameter reasonList: list of firebase reason templates
    func importance(with reasonList: [FirebaseReasonTemplate]) -> Importance

    /// Parameters for firebase function call
    var parameterSet: FirebaseCallParameterSet { get }
}

/// Fine Reason for reason / amount / importance
struct FineReasonCustom: FineReason, Equatable {

    /// Reason of the fine
    let reason: String

    /// Amount of the amount
    let amount: Amount

    /// Importance of the fine
    let importance: Importance

    func reason(with reasonList: [FirebaseReasonTemplate]) -> String { reason }

    func amount(with reasonList: [FirebaseReasonTemplate]) -> Amount { amount }

    func importance(with reasonList: [FirebaseReasonTemplate]) -> Importance { importance }

    var parameterSet: FirebaseCallParameterSet {
        FirebaseCallParameterSet { parameters in
            parameters["reason"] = reason
            parameters["amount"] = amount
            parameters["importance"] = importance
        }
    }
}

/// Fine Reason for templateId
struct FineReasonTemplate: FineReason, Equatable {

    /// Template id
    let templateId: FirebaseReasonTemplate.ID

    func reason(with reasonList: [FirebaseReasonTemplate]) -> String {
        reasonList.first(where: { $0.id == templateId })?.reason ?? ""
    }

    func amount(with reasonList: [FirebaseReasonTemplate]) -> Amount {
        reasonList.first(where: { $0.id == templateId })?.amount ?? .zero
    }

    func importance(with reasonList: [FirebaseReasonTemplate]) -> Importance {
        reasonList.first(where: { $0.id == templateId })?.importance ?? .low
    }

    var parameterSet: FirebaseCallParameterSet {
        FirebaseCallParameterSet { parameters in
            parameters["templateId"] = templateId
        }
    }
}

/// Codable fine reason to get custom or template fine reason
struct CodableFineReason: Decodable {

    /// Reason
    let reason: String?

    /// Amount
    let amount: Amount?

    /// Importance
    let importance: Importance?

    /// Template id
    let templateId: FirebaseReasonTemplate.ID?

    /// Custom or template fine reason
    var fineReason: FineReason {
        if let templateId = templateId {
            return FineReasonTemplate(templateId: templateId)
        } else if let reason = reason,
                  let amount = amount,
                  let importance = importance {
            return FineReasonCustom(reason: reason, amount: amount, importance: importance)
        } else {
            fatalError("No template id and no properties for custom fine reason.")
        }
    }
}

extension CodableFineReason: Equatable {}
