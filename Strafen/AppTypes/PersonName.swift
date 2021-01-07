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
    let lastName: String?
    
    init?(firstName: String?, lastName: String?) {
        guard let firstName = firstName else { return nil }
        self.firstName = firstName
        self.lastName = lastName?.isEmpty ?? true ? nil : lastName
    }
    
    init(firstName: String, lastName: String?) {
        self.firstName = firstName
        self.lastName = lastName?.isEmpty ?? true ? nil : lastName
    }
    
    /// Unknown person name
    static let unknown = PersonName(firstName: "Unknown", lastName: "Person")
    
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
