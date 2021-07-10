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
        let clubProperties: Club

        /// Date of sign in
        let signInDate: Date

        /// Indicates whether the person is cashier
        let isCashier: Bool

        /// Name of the person
        let name: PersonName

        /// Id of the person
        let id: FirebasePerson.ID

        /// Properties of logged in person
        var settingsPerson: Settings.Person {
            Settings.Person(club: clubProperties, id: id, name: name, signInDate: signInDate, isCashier: isCashier)
        }
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
