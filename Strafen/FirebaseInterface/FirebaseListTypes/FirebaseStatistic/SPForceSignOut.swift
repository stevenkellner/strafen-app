//
//  SPForceSignOut.swift
//  Strafen
//
//  Created by Steven on 27.06.21.
//

import Foundation

/// Statistic of `forceSignOut` call
struct SPForceSignOut: StatisticProperty {

    /// Id of person to be force signed out
    let personId: FirebasePerson.ID
}

extension SPForceSignOut: Decodable {

    /// Coding Keys for Decodable
    enum CodingKeys: String, CodingKey {

        /// Id of person to be force signed out
        case personId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.personId = try container.decode(FirebasePerson.ID.self, forKey: .personId)
    }
}
