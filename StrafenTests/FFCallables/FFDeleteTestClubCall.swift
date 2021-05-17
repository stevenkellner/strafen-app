//
//  FFDeleteTestClubCall.swift
//  StrafenTests
//
//  Created by Steven on 05.05.21.
//

import Foundation
@testable import Strafen

/// Deletes a test club in database
struct FFDeleteTestClubCall: FFCallable {

    /// Id of test club to delete
    let clubId: Club.ID

    let functionName = "deleteTestClub"

    var parameters: FirebaseCallParameterSet {
        FirebaseCallParameterSet { parameters in
            parameters["clubId"] = clubId
        }
    }
}
