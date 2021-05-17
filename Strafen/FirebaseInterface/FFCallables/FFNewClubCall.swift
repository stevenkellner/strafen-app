//
//  FFNewClubCall.swift
//  Strafen
//
//  Created by Steven on 16.05.21.
//

import Foundation

/// Creates a new club with given properties
struct FFNewClubCall: FFCallable {

    /// Sign in property with userId and name
    let signInProperty: SignInProperty.UserIdName

    /// Club id
    let clubId: UUID

    /// Person id
    let personId: FirebasePerson.ID

    /// Name of the club
    let clubName: String

    /// Region code
    let regionCode: String

    /// Identifier of the club
    let clubIdentifier: String

    /// In app payment
    let inAppPayment: Bool

    let functionName = "newClub"

    var parameters: FirebaseCallParameterSet {
        FirebaseCallParameterSet { parameters in
            parameters["clubId"] = clubId
            parameters["clubName"] = clubName
            parameters["regionCode"] = regionCode
            parameters["personId"] = personId
            parameters["personFirstName"] = signInProperty.name.firstName
            parameters["personLastName"] = signInProperty.name.lastName
            parameters["clubIdentifier"] = clubIdentifier
            parameters["userId"] = signInProperty.userId
            parameters["signInDate"] = Date()
            parameters["inAppPayment"] = inAppPayment
        }
    }
}
