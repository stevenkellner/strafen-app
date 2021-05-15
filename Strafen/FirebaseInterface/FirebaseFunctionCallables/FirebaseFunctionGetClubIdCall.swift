//
//  FirebaseFunctionGetClubIdCall.swift
//  Strafen
//
//  Created by Steven on 15.05.21.
//

import Foundation

/// Get club id with given club identifier
struct FirebaseFunctionGetClubIdCall: FirebaseFunctionCallable, FirebaseFunctionCallResult {
    
    typealias CallResult = UUID
    
    /// Identifer of the club to search
    let identifier: String
    
    let functionName = "getClubId"
    
    var parameters: FirebaseCallParameterSet {
        FirebaseCallParameterSet { parameters in
            parameters["identifier"] = identifier
        }
    }
}
