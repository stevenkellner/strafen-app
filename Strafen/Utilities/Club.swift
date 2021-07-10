//
//  Club.swift
//  Strafen
//
//  Created by Steven on 17.05.21.
//

import Foundation

struct Club: Codable {

    /// Type of Id
    typealias ID = Tagged<(Club, id: Void), UUID>

    init(id: ID, name: String, identifier: String, regionCode: String, inAppPaymentActive: Bool) {
        self.id = id
        self.name = name
        self.identifier = identifier
        self.regionCode = regionCode
        self.inAppPaymentActive = inAppPaymentActive
    }

    /// Id of the club
    let id: ID

    /// Name of the club
    let name: String

    /// Identifier of the club
    let identifier: String

    /// Region code
    var regionCode: String

    /// Is in app payment active
    @DecodableDefault.False var inAppPaymentActive: Bool
}
