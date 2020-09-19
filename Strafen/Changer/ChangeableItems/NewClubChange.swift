//
//  NewClubChange.swift
//  Strafen
//
//  Created by Steven on 9/19/20.
//

import Foundation

/// New club Change
struct NewClubChange: Changeable, Parameterable {
    
    /// New club
    let club: ChangerClub
    
    /// Path from AppUrls to changer url
    var urlPath: KeyPath<AppUrls, URL> = \.changer.newClub
    
    /// Parameters
    var parameters: Parameters {
        Parameters(club.parameters)
    }
}
