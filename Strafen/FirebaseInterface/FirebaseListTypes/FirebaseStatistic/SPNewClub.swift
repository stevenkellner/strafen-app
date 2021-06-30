//
//  SPNewClub.swift
//  Strafen
//
//  Created by Steven on 30.06.21.
//

import Foundation

/// Statistic of `newClub` call
struct SPNewClub: StatisticProperty {

    /// Identifier of created club
    let identifier: String

    /// Name of created club
    let name: String

    /// Region code of created club
    let regionCode: String

    /// Indicates wheather in app payment is active in created club
    let inAppPaymentActive: Bool

    /// Person created the new club
    let person: FirebasePerson
}
