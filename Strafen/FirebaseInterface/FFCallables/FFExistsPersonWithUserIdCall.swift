//
//  FFExistsPersonWithUserIdCall.swift
//  Strafen
//
//  Created by Steven on 17.05.21.
//

import Foundation

/// Checks if a person with user id exists
struct FFExistsPersonWithUserIdCall: FFCallable, FFCallResult {

    typealias CallResult = Bool

    /// User id
    let userId: String

    let functionName = "existsPersonWithUserId"

    var parameters: FirebaseCallParameterSet {
        FirebaseCallParameterSet { parameters in
            parameters["userId"] = userId
        }
    }
}
