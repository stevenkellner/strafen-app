//
//  GetPersonPropertiesCall.swift
//  Strafen
//
//  Created by Steven on 11/8/20.
//

import Foundation

/// Used to get club and person id from user id
struct GetPersonPropertiesCall: FunctionCallable, FunctionCallResult {
    
    /// Function call result
    typealias CallResult = NewSettings.Person
    
    /// User id
    let userId: String
    
    /// Function name
    let functionName = "getPersonProperties"
    
    /// Parameters
    var parameters: NewParameters {
        NewParameters { parameters in
            parameters["userId"] = userId
        }
    }
}
