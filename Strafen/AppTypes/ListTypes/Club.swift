//
//  Club.swift
//  Strafen
//
//  Created by Steven on 10.07.20.
//

import Foundation

/// Club for decoding json list
struct Club: ListTypes {
    
    /// Url to list on server
    static var serverListUrl = \AppUrls.allClubsUrl
    
    /// List data of this server list type
    static let listData = ListData.club
    
    /// Url to changer on server
    static let changerUrl: KeyPath<AppUrls, URL>? = nil
    
    /// Parameters for POST method
    var postParameters: [String : Any]? = nil
    
    /// Person in club list
    struct ClubPerson: Decodable {
        
        /// Coding Key for Decoding Json
        enum CodingKeys: String, CodingKey {
            
            /// Person id
            case id = "personId"
            
            /// First name
            case firstName
            
            /// Last name
            case lastName
            
            /// Person login
            case login
            
            /// Is person the cashier
            case isCashier = "cashier"
        }
        
        /// Person id
        let id: UUID
        
        /// First name
        let firstName: String
        
        /// Last name
        let lastName: String
        
        /// Person login
        let login: PersonLoginCodable
        
        /// Is person the cashier
        let isCashier: Bool
        
        /// First and last name
        var personName: PersonName {
            PersonName(firstName: firstName, lastName: lastName)
        }
    }
    
    /// Coding Key for Decoding Json
    enum CodingKeys: String, CodingKey {
        
        /// Club id
        case id = "clubId"
        
        /// Club name
        case name = "clubName"
        
        /// all persons in this club
        case allPersons
    }
    
    /// Club id
    let id: UUID
    
    /// Club name
    let name: String
    
    /// All persons in this club
    let allPersons: [ClubPerson]
}
