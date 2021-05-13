//
//  SignInProperty.swift
//  Strafen
//
//  Created by Steven on 13.05.21.
//

import Foundation

/// Contains properties for sign in
struct SignInProperty {
    
    /// Sign in property with userId and name
    struct UserIdName {
        
        /// User id of person signed in
        let userId: String
        
        /// Name of  person signed in
        let name: PersonName
    }
}
