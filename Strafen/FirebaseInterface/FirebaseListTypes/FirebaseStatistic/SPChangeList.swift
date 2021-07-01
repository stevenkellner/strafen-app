//
//  SPChangeList.swift
//  Strafen
//
//  Created by Steven on 26.06.21.
//

import Foundation

/// Statistic of `changeList` call
struct SPChangeList<T>: StatisticProperty where T: FirebaseListType {

    /// Previous item to change
    let previousItem: T.Statistic

    /// Changed item
    let changedItem: T.Statistic
}
