//
//  Person.swift
//  Strafen
//
//  Created by Steven on 03.07.20.
//

import Foundation

/// Person with name, id and loggedIn
struct Person: AppTypes, Identifiable {
    
    /// Url to list on server
    static var serverListUrl = \AppUrls.appTypesUrls?.person
    
    /// First name
    let firstName: String
    
    /// Last name
    let lastName: String
    
    /// id
    let id: UUID
    
    /// True if person logged in on a device
    let loggedIn: Bool
    
    /// First and last name
    var personName: PersonName {
        PersonName(firstName: firstName, lastName: lastName)
    }
}
