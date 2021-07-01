//
//  SPChangeFinePayed.swift
//  Strafen
//
//  Created by Steven on 26.06.21.
//

import Foundation

/// Statistic of `changeFinePayed` call
struct SPChangeFinePayed: StatisticProperty {

    /// Fine before the change, always has custom fine reason
    let previousFine: StatisticsFine

    /// Changed state of the payment of the fine
    let changedState: Payed
}
