//
//  NewClubCall.swift
//  Strafen
//
//  Created by Steven on 11/8/20.
//

import Foundation

/// Used to create a new club in the database
struct NewClubCall: FunctionCallable {
    
    /// Cached user id, name
    let cachedProperties: SignInCache.PropertyUserIdName
    
    /// Club credentials with club name and club identifer
    let clubCredentials: SignInClubInput.ClubCredentials
    
    /// Club id
    let clubId: Club.ID
    
    /// Person id
    let personId: Person.ID
    
    /// Function name
    let functionName: String = "newClub"
    
    /// Parameters
    var parameters: Parameters {
        Parameters { parameters in
            parameters["clubId"] = clubId
            parameters["clubName"] = clubCredentials.clubName
            parameters["regionCode"] = clubCredentials.regionCode
            parameters["personId"] = personId
            parameters["personFirstName"] = cachedProperties.name.firstName
            parameters["personLastName"] = cachedProperties.name.lastName
            parameters["clubIdentifier"] = clubCredentials.clubIdentifier
            parameters["userId"] = cachedProperties.userId
            parameters["signInDate"] = Date()
        }
    }
}
