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
    
    /// List data of this server list type
    static let listData = ListData.person
    
    /// Url to changer on server
    static let changerUrl: KeyPath<AppUrls, URL>? = \AppUrls.changer.personList
    
    /// Parameters for POST method
    var postParameters: [String : Any]? {
        [
            "id": id,
            "firstName": firstName,
            "lastName": lastName
        ]
    }
    
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
