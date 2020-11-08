//
//  UserIdAlreadyExistsCall.swift
//  Strafen
//
//  Created by Steven on 11/8/20.
//

import Foundation

/// Used to check if person with user id already exists
struct UserIdAlreadyExistsCall: FunctionCallable, FunctionCallResult {
    
    /// Result type
    typealias CallResult = Bool
    
    /// User id
    let userId: String
    
    /// Function name
    let functionName = "existsPersonWithUserId"
    
    /// Parameters
    var parameters: NewParameters {
        NewParameters { parameters in
            parameters["userId"] = userId
        }
    }
}
