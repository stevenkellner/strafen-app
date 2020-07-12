//
//  ChangerClub.swift
//  Strafen
//
//  Created by Steven on 03.07.20.
//

import Foundation

/// Contains all properties for a new club
struct ChangerClub {
    
    /// Id of the club
    let clubId: UUID
    
    /// Name of the club
    let clubName: String
    
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
            "clubName": clubName,
            "personId": personId
        ]
        parameters.merge(personName.parameters) { firstValue, _ in firstValue }
        parameters.merge(login.parameters) { firstValue, _ in firstValue }
        return parameters
    }
}
