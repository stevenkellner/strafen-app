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
