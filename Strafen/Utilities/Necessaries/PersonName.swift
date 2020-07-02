//
//  PersonName.swift
//  Strafen
//
//  Created by Steven on 27.06.20.
//

import Foundation

/// Contains first and last name of a person
struct PersonName: Codable {
    
    /// First name of a person
    let firstName: String
    
    /// Last name of a person
    let lastName: String
    
    /// POST parameters
    var parameters: [String : Any] {
        [
            "firstName": firstName,
            "lastName": lastName
        ]
    }
}
