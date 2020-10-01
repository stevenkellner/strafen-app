//
//  DeleteClubChange.swift
//  Strafen
//
//  Created by Steven on 9/25/20.
//

import Foundation

/// Delete club Change
struct DeleteClubChange: Changeable, Parameterable {
    
    /// Club id
    let clubId: UUID
    
    /// Path from AppUrls to changer url
    var urlPath: KeyPath<AppUrls, URL> = \.changer.deleteClub
    
    /// Parameters
    var parameters: Parameters {
        Parameters { parameters in
            parameters["clubId"] = clubId.uuidString
        }
    }
}
