//
//  SPRegisterPerson.swift
//  Strafen
//
//  Created by Steven on 27.06.21.
//

import Foundation

/// Statistic of `registerPerson` call
struct SPRegisterPerson: StatisticProperty {

    /// Id of the person to be registered
    let personId: FirebasePerson.ID
}

extension SPRegisterPerson: Decodable {

    /// Coding Keys for Decodable
    enum CodingKeys: String, CodingKey {

        /// Id of the person to be registered
        case personId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.personId = try container.decode(FirebasePerson.ID.self, forKey: .personId)
    }
}
