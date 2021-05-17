//
//  FFForceSignOutCall.swift
//  Strafen
//
//  Created by Steven on 17.05.21.
//

import Foundation

/// Force sign out a person
struct FFForceSignOutCall: FFCallable {

    /// Club id
    let clubId: UUID

    /// Person id
    let personId: FirebasePerson.ID

    let functionName = "forceSignOut"

    var parameters: FirebaseCallParameterSet {
        FirebaseCallParameterSet { parameters in
            parameters["clubId"] = clubId
            parameters["personId"] = personId
        }
    }
}
