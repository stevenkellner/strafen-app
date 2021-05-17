//
//  FFGetPersonPropertiesCall.swift
//  Strafen
//
//  Created by Steven on 17.05.21.
//

import Foundation

/// Used to get club and person id from user id
struct FFGetPersonPropertiesCall: FFCallable, FFCallResult {

    struct CallResult: Decodable {

        /// All properties of the club
        struct ClubProperties: Decodable {

            /// Id of the club
            let id: UUID

            /// Name of the club
            let name: String

            /// Identifier of the club
            let identifier: String

            /// Region code
            let regionCode: String
        }

        /// All properties of the club
        let clubProperties: ClubProperties

        /// Date of sign in
        let signInDate: Date

        /// Indicates whether the person is cashier
        let isCashier: Bool

        /// Name of the person
        let name: PersonName
    }

    /// User id
    let userId: String

    let functionName = "getPersonProperties"

    var parameters: FirebaseCallParameterSet {
        FirebaseCallParameterSet { parameters in
            parameters["userId"] = userId
        }
    }
}
