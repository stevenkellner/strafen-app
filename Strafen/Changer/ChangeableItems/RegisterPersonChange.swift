//
//  RegisterPersonChange.swift
//  Strafen
//
//  Created by Steven on 9/18/20.
//

import Foundation

/// Used to register a new person on server
struct RegisterPersonChange: Changeable, Parameterable {
    
    /// Person
    let person: RegisterPerson
    
    /// Path from AppUrls to changer url
    var urlPath: KeyPath<AppUrls, URL> = \.changer.registerPerson
    
    /// Parameters
    var parameters: Parameters {
        Parameters(person.parameters)
    }
}
