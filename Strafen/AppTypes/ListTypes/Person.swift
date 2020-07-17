//
//  Person.swift
//  Strafen
//
//  Created by Steven on 03.07.20.
//

import Foundation

/// Person with name, id
struct Person: ListTypes, Identifiable {
    
    /// Url to list on server
    static var serverListUrl = \AppUrls.listTypesUrls?.person
    
    /// First name
    let firstName: String
    
    /// Last name
    let lastName: String
    
    /// id
    let id: UUID
    
    /// First and last name
    var personName: PersonName {
        PersonName(firstName: firstName, lastName: lastName)
    }
}