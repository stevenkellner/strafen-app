//
//  FFGetClubIdCall.swift
//  Strafen
//
//  Created by Steven on 15.05.21.
//

import Foundation

/// Get club id with given club identifier
struct FFGetClubIdCall: FFCallable, FFCallResult {

    typealias CallResult = Club.ID

    /// Identifer of the club to search
    let identifier: String

    let functionName = "getClubId"

    var parameters: FirebaseCallParameterSet {
        FirebaseCallParameterSet { parameters in
            parameters["identifier"] = identifier
        }
    }
}
