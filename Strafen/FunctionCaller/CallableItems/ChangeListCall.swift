//
//  ChangeListCall.swift
//  Strafen
//
//  Created by Steven on 11/8/20.
//

import Foundation

/// Used to change list types in database
struct ChangeListCall<Type>: FunctionCallable where Type: NewListType {
    
    /// Club id
    let clubId: UUID
    
    /// Change type
    let changeType: ChangeType
    
    /// Change item
    let changeItem: Type
    
    /// Function name
    let functionName = "changeList"
    
    /// Parameters
    var parameters: NewParameters {
        NewParameters(changeItem.callParameters) { parameters in
            parameters["clubId"] = clubId
            parameters["changeType"] = changeType
        }
    }
}
