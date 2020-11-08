//
//  ClubIdentifierAlreadyExistsCall.swift
//  Strafen
//
//  Created by Steven on 11/8/20.
//

import Foundation

/// Used to check if a club identifier already exists
struct ClubIdentifierAlreadyExistsCall: FunctionCallable, FunctionCallResult {
    
    /// Result type
    typealias CallResult = Bool
    
    /// Club identifier
    let identifier: String
    
    /// Function name
    let functionName = "existsClubWithIdentifier"
    
    /// Parameters
    var parameters: NewParameters {
        NewParameters { parameters in
            parameters["identifier"] = identifier
        }
    }
}
