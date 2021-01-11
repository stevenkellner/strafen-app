//
//  DeleteClubCall.swift
//  Strafen
//
//  Created by Steven on 1/5/21.
//

import Foundation

/// Used to delete a club from database
struct DeleteClubCall: FunctionCallable {
    
    /// Club id
    let clubId: Club.ID
    
    /// Function name
    let functionName: String = "deleteClub"
    
    /// Parameters
    var parameters: Parameters {
        Parameters { parameters in
            parameters["clubId"] = clubId
        }
    }
}
