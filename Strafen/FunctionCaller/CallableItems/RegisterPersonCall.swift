//
//  RegisterPersonCall.swift
//  Strafen
//
//  Created by Steven on 11/8/20.
//

import Foundation

/// Used to register a new person in the database
struct RegisterPersonCall: FunctionCallable, FunctionCallResult {
    
    /// Return result of function call
    struct CallResult: Decodable {
        
        /// Club identifier
        let clubIdentifier: String
        
        /// Club name
        let clubName: String
        
        /// Region code
        let regionCode: String
    }
    
    /// Cached user id, name and club id
    let cachedProperties: SignInCache.PropertyUserIdNameClubId
    
    /// Person id
    let personId: Person.ID
    
    /// Function name
    let functionName = "registerPerson"
    
    /// Parameters
    var parameters: Parameters {
        Parameters { parameters in
            parameters["clubId"] = cachedProperties.clubId
            parameters["id"] = personId
            parameters["firstName"] = cachedProperties.name.firstName
            parameters["lastName"] = cachedProperties.name.lastName
            parameters["userId"] = cachedProperties.userId
            parameters["signInDate"] = Date()
        }
    }
}
