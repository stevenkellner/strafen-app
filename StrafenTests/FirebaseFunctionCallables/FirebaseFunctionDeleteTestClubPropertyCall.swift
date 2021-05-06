//
//  FirebaseFunctionDeleteTestClubPropertyCall.swift
//  StrafenTests
//
//  Created by Steven on 06.05.21.
//

import Foundation
@testable import Strafen

/// Deletes a test club property in database
struct FirebaseFunctionDeleteTestClubPropertyCall: FirebaseFunctionCallable {
    
    /// Id of test club to delete
    let clubId: UUID
    
    /// Url from club to property to delete
    let urlFromClub: URL
    
    let functionName = "deleteTestClubProperty"
    
    var parameters: FirebaseCallParameterSet {
        FirebaseCallParameterSet { parameters in
            parameters["clubId"] = clubId
            parameters["propertyPath"] = urlFromClub
        }
    }
}


