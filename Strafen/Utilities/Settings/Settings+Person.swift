//
//  Settings+Person.swift
//  Strafen
//
//  Created by Steven on 9/4/20.
//

import Foundation

extension Settings {
    
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
