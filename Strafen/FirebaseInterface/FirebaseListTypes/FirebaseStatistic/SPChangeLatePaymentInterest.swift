//
//  SPChangeLatePaymentInterest.swift
//  Strafen
//
//  Created by Steven on 26.06.21.
//

import Foundation

/// Statistic of `changeLatePaymentInterest` call
struct SPChangeLatePaymentInterest: StatisticProperty {

    /// Previous late payment interest
    let previousInterest: LatePaymentInterest?

    /// Changed late payment interest or null if change type is `remove`
    let changedInterest: LatePaymentInterest?

    init() {
        self.previousInterest = nil
        self.changedInterest = nil
    }
}

extension SPChangeLatePaymentInterest: Decodable {

    /// Coding Keys for Decodable
    enum CodingKeys: String, CodingKey {

        /// Previous late payment interest
        case previousInterest

        /// Changed late payment interest
        case changedInterest
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.previousInterest = try container.decodeIfPresent(LatePaymentInterest.self, forKey: .previousInterest)
        self.changedInterest = try container.decodeIfPresent(LatePaymentInterest.self, forKey: .changedInterest)
    }
}
