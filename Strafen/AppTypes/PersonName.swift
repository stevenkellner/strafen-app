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
    
    /// Unknown person name
    static let unknown = PersonName(firstName: "Unknown", lastName: "Person")
    
    /// POST parameters
    var parameters: [String : Any] {
        [
            "firstName": firstName,
            "lastName": lastName
        ]
    }
    
    /// Formatted
    var formatted: String {
        var componets = PersonNameComponents()
        componets.givenName = firstName
        componets.familyName = lastName
        let formatter = PersonNameComponentsFormatter()
        formatter.style = .default
        return formatter.string(from: componets)
    }
}
