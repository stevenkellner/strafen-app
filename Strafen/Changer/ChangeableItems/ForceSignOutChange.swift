//
//  ForceSignOutChange.swift
//  Strafen
//
//  Created by Steven on 9/19/20.
//

import Foundation

/// Force sign out change
struct ForceSignOutChange: Changeable, Parameterable {
    
    /// Person id
    let personId: UUID
    
    /// Path from AppUrls to changer url
    var urlPath: KeyPath<AppUrls, URL> = \.changer.forceSignOut
    
    /// Parameters
    var parameters: Parameters {
        Parameters { parameters in
            parameters["clubId"] = Settings.shared.person!.clubId.uuidString
            parameters["personId"] = personId.uuidString
        }
    }
    
    /// Change cached
    func changeCached() {
        var club = ListData.club.list!.first(where: { $0.id == Settings.shared.person!.clubId })!
        club.allPersons.filtered({ $0.id != personId })
        ListData.club.list!.filtered({ $0.id != Settings.shared.person!.clubId })
        ListData.club.list!.append(club)
    }
}
