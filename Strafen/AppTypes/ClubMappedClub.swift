//
//  ClubMappedClub.swift
//  Strafen
//
//  Created by Steven on 02.07.20.
//

import Foundation

/// Club mapped to Id and name
struct ClubMappedClub: AppTypes {
    
    /// Url to list on server
    static var serverListUrl = \AppUrls.allClubs.onlyClubs
    
    /// Coding Key for Decoding Json
    enum CodingKeys: String, CodingKey {
        
        /// Club id
        case id = "clubId"
        
        /// Club name
        case name = "clubName"
    }
    
    /// Club id
    let id: UUID
    
    /// Club name
    let name: String
}
