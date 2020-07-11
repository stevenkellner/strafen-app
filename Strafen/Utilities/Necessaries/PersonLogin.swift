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
    
    /// Check if is equal to other
    func equalLogin(to other: PersonLogin) -> Bool
}

/// Contains all properties for the login with apple
struct PersonLoginApple: PersonLogin {
    
    /// Idetifier from apple
    let appleIdentifier: String
    
    /// POST parameters
    var parameters: [String : Any] {
        ["apple": appleIdentifier]
    }
    
    /// Checks for equality
    func equalLogin(to other: PersonLogin) -> Bool {
        appleIdentifier == (other as? Self)?.appleIdentifier
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
    
    /// Checks for equality
    func equalLogin(to other: PersonLogin) -> Bool {
        email == (other as? Self)?.email
    }
}

struct PersonLoginCodable: Decodable {
    
    /// Coding Key for Decoding Json
    enum CodingKeys: String, CodingKey {
        
        /// Email
        case email
        
        /// Password
        case password
        
        /// Idetifier from apple
        case appleIdentifier = "apple"
    }
    
    /// Email
    let email: String?
    
    /// Password
    let password: String?
    
    /// Idetifier from apple
    let appleIdentifier: String?
    
    /// Contains all properties for the login
    var personLogin: PersonLogin {
        if let appleIdentifier = appleIdentifier {
            return PersonLoginApple(appleIdentifier: appleIdentifier)
        } else if let email = email, let password = password {
            return PersonLoginEmail(email: email, password: password)
        } else {
            fatalError("Error while decoding person login")
        }
    }
}
 
