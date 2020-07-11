//
//  RegisterPerson.swift
//  Strafen
//
//  Created by Steven on 04.07.20.
//

import Foundation

/// Contains all properties for a person to register on server
struct RegisterPerson {
    
    /// Id of the club
    let clubId: UUID
    
    /// Id of the person
    let personId: UUID
    
    /// Name of the person
    let personName: PersonName
    
    /// Contains all properties for the login
    let login: PersonLogin
    
    /// POST parameters
    var parameters: [String : Any] {
        var parameters: [String : Any] = [
            "clubId": clubId,
            "id": personId
        ]
        parameters.merge(personName.parameters) { firstValue, _ in firstValue }
        parameters.merge(login.parameters) { firstValue, _ in firstValue }
        return parameters
    }
}
