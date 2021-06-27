//
//  ChangeLatePaymentInterestStatistic.swift
//  Strafen
//
//  Created by Steven on 26.06.21.
//

import Foundation

/// Statistic of `changeLatePaymentInterest` call
struct ChangeLatePaymentInterestStatistic: FirebaseStatisticProperty {

    /// Type of the changed late payment interest
    let changeType: FFChangeLatePaymentInterestCall.ChangeType
}

extension ChangeLatePaymentInterestStatistic: Decodable {

    /// Coding Keys for Decodable
    enum CodingKeys: String, CodingKey {

        /// Type of the change
        case changeType

        /// Changed late payment interest
        case latePaymentInterest
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let changeType = try container.decode(String.self, forKey: .changeType)
        switch changeType {
        case "update":
            let latePaymentInterest = try container.decode(LatePaymentInterest.self, forKey: .latePaymentInterest)
            self.changeType = .update(interest: latePaymentInterest)
        case "remove":
            self.changeType = .remove
        default:
            throw DecodingError.dataCorruptedError(forKey: .changeType, in: container, debugDescription: "Invalid change type: \(changeType)")
        }
    }
}
