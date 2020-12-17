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
    typealias CallResult = Settings.Person
    
    /// User id
    let userId: String
    
    /// Function name
    let functionName = "getPersonProperties"
    
    /// Parameters
    var parameters: Parameters {
        Parameters { parameters in
            parameters["userId"] = userId
        }
    }
}
