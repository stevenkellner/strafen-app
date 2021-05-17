//
//  FFRegisterPersonCall.swift
//  Strafen
//
//  Created by Steven on 17.05.21.
//

import Foundation

/// Register person to club
struct FFRegisterPersonCall: FFCallable, FFCallResult {

    struct CallResult: Decodable {

        /// Club identifier
        let clubIdentifier: String

        /// Club name
        let clubName: String

        /// Region code
        let regionCode: String

        /// Is in app payment active
        let inAppPaymentActive: Bool
    }

    /// Sign in property with userId and name
    let signInProperty: SignInProperty.UserIdNameClubId

    /// Person id
    let personId: FirebasePerson.ID

    let functionName = "registerPerson"

    var parameters: FirebaseCallParameterSet {
        FirebaseCallParameterSet { parameters in
            parameters["clubId"] = signInProperty.clubId
            parameters["id"] = personId
            parameters["firstName"] = signInProperty.name.firstName
            parameters["lastName"] = signInProperty.name.lastName
            parameters["userId"] = signInProperty.userId
            parameters["signInDate"] = Date()
        }
    }
}
