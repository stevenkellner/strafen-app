//
//  FirebaseFunctionDeleteTestClubCall.swift
//  StrafenTests
//
//  Created by Steven on 05.05.21.
//

import Foundation
@testable import Strafen

/// Deletes a test club in database
struct FirebaseFunctionDeleteTestClubCall: FirebaseFunctionCallable {
    
    /// Id of test club to delete
    let clubId: UUID
    
    let functionName = "deleteTestClub"
    
    var parameters: FirebaseCallParameterSet {
        FirebaseCallParameterSet { parameters in
            parameters["clubId"] = clubId
        }
    }
}

