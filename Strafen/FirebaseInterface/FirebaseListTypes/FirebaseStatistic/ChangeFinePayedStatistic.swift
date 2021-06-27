//
//  ChangeFinePayedStatistic.swift
//  Strafen
//
//  Created by Steven on 26.06.21.
//

import Foundation

/// Statistic of `changeFinePayed` call
struct ChangeFinePayedStatistic: FirebaseStatisticProperty {

    /// Id of the fine with changed payed state
    let fineId: FirebaseFine.ID

    /// State of the payment of the fine
    let payedState: Payed
}

extension ChangeFinePayedStatistic: Decodable {

    /// Coding Keys for Decodable
    enum CodingKeys: String, CodingKey {

        /// Id of the fine with changed payed state
        case fineId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.fineId = try container.decode(FirebaseFine.ID.self, forKey: .fineId)
        self.payedState = try Payed(from: decoder)
    }
}
