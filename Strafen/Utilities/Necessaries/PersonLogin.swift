//
//  PersonLogin.swift
//  Strafen
//
//  Created by Steven on 03.07.20.
//

import Foundation

/// Contains all properties for the login
protocol PersonLogin {
    
    /// POST parameters
    var parameters: [String : Any] { get }
}

/// Contains all properties for the login with apple
struct PersonLoginApple: PersonLogin {
    
    /// Idetifier from apple
    let appleIdentifier: String
    
    /// POST parameters
    var parameters: [String : Any] {
        ["apple": appleIdentifier]
    }
}

/// Contains all properties for the login with email
struct PersonLoginEmail: PersonLogin {
    
    /// Email
    let email: String
    
    /// Password
    let password: String
    
    /// POST parameters
    var parameters: [String : Any] {
        [
            "email": email,
            "password": password.encrypted
        ]
    }
}
