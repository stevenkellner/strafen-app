//
//  ChangeFinePayedCall.swift
//  Strafen
//
//  Created by Steven on 11/26/20.
//

import Foundation

/// Used to change payed of a fine
struct ChangeFinePayedCall: FunctionCallable {
    
    /// Club id
    let clubId: UUID
    
    /// Fine id
    let fineId: UUID
    
    /// Payed
    let payed: Payed
    
    /// Function name
    let functionName = "changeFinePayed"
    
    /// Parameters
    var parameters: NewParameters {
        NewParameters { parameters in
            parameters["clubId"] = clubId
            parameters["fineId"] = fineId
            parameters["payed"] = payed
        }
    }
}
