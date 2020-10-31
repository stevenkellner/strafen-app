//
//  Settings+Person.swift
//  Strafen
//
//  Created by Steven on 9/4/20.
//

import Foundation

extension Settings { // TODO remove
    
    /// Logged in person
    struct Person: Codable {
        
        /// Id of the person
        let id: UUID
        
        /// Name of the person
        let name: PersonName
        
        /// Id of the associated club
        let clubId: UUID
        
        /// Name of the associated club
        let clubName: String
        
        /// True if person is cashier of the club
        var isCashier: Bool
    }
}

extension NewSettings {
    
    /// Logged in person
    struct Person: Codable {
        
        /// Id of the person
        let personId: UUID
        
        /// Id of the associated club
        let clubId: UUID
        
        /// Indicates whether the signed-in person is the club's cashier
        let isCashier: Bool
    }
}
