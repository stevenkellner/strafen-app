//
//  FirebaseFunctionExistsClubWithIdentifierCall.swift
//  Strafen
//
//  Created by Steven on 16.05.21.
//

import Foundation

/// Checks if club with given identifier already exists
struct FirebaseFunctionExistsClubWithIdentifierCall: FirebaseFunctionCallable, FirebaseFunctionCallResult {
    
    typealias CallResult = Bool
    
    /// Identifer of the club to search
    let identifier: String
    
    let functionName = "existsClubWithIdentifier"
    
    var parameters: FirebaseCallParameterSet {
        FirebaseCallParameterSet { parameters in
            parameters["identifier"] = identifier
        }
    }
}
