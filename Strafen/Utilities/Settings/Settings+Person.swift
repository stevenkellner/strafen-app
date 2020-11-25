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
        
        /// Club properties
        struct ClubProperties: Codable {
            
            /// Id of the club
            let id: UUID
            
            /// Name of the club
            let name: String
            
            /// Identifier of the club
            let identifier: String
            
            /// Region code
            var regionCode: String
        }
        
        /// Club properties
        var clubProperties: ClubProperties
        
        /// Id of the person
        let id: UUID
        
        /// Name of the person
        let name: PersonName
        
        /// Sign in date
        let signInDate: Date
        
        /// Indicates whether the signed-in person is the club's cashier
        var isCashier: Bool
    }
}
