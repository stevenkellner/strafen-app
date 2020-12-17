//
//  ForceSignOutCall.swift
//  Strafen
//
//  Created by Steven on 12/17/20.
//

import Foundation

/// Late payment interest call
struct ForceSignOutCall: FunctionCallable {
    
    /// Person id
    let personId: NewPerson.ID
    
    /// Club id
    let clubId: NewClub.ID
    
    /// Function name
    let functionName: String = "forceSignOut"
    
    /// Parameters
    var parameters: NewParameters {
        NewParameters { parameters in
            parameters["clubId"] = clubId
            parameters["personId"] = personId
        }
    }
}
