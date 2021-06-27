//
//  NewClubStatistic.swift
//  Strafen
//
//  Created by Steven on 27.06.21.
//

import Foundation

/// Statistic of `newClub` call
struct NewClubStatistic: FirebaseStatisticProperty {}

extension NewClubStatistic: Decodable {
    init(from decoder: Decoder) throws {}
}
