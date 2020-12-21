//
//  Settings+Person.swift
//  Strafen
//
//  Created by Steven on 9/4/20.
//

import Foundation

typealias Club = Settings.Person.ClubProperties
typealias _Person = Person

extension Settings {
    
    /// Logged in person
    struct Person: Codable {
        
        /// Club properties
        struct ClubProperties: Codable {
            
            /// Type of Id
            typealias ID = Tagged<(ClubProperties, id: Void), UUID>
            
            /// Id of the club
            let id: ID
            
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
        let id: _Person.ID
        
        /// Name of the person
        let name: PersonName
        
        /// Sign in date
        let signInDate: Date
        
        /// Indicates whether the signed-in person is the club's cashier
        var isCashier: Bool
    }
}
