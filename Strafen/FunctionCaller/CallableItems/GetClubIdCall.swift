//
//  GetClubIdCall.swift
//  Strafen
//
//  Created by Steven on 11/8/20.
//

import Foundation

/// Used to get club id from club identifer
struct GetClubIdCall: FunctionCallable, FunctionCallResult {
    
    /// Result type
    typealias CallResult = UUID
    
    /// Club identifier
    let identifier: String
    
    /// Function name
    let functionName = "getClubId"
    
    /// Parameters
    var parameters: NewParameters {
        NewParameters { parameters in
            parameters["identifier"] = identifier
        }
    }
}
