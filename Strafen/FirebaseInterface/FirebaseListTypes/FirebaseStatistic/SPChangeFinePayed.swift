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

/// Contains all properties of a fine in statistics
struct StatisticsFine: Decodable {

    /// Id of the fine
    let id: FirebaseFine.ID // swiftlint:disable:this identifier_name

    /// Associated person of the fine
    let person: FirebasePerson

    /// State of payement
    let payed: Payed

    /// Number of fines
    let number: Int

    /// Date when fine was created
    let date: Date

    /// Reason of fine
    let reason: StatisticsFineReason
}

/// Contains all properties of a fine reason in staistics
struct StatisticsFineReason: Decodable {

    /// Id of template reason, nil if fine reason is custom
    let id: FirebaseReasonTemplate.ID? // swiftlint:disable:this identifier_name

    /// Reason message of the fine
    let reason: String

    /// Amount of the fine
    let amount: Amount

    /// Importance of the fine
    let importance: Importance
}
