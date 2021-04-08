//
//  CheckTransactionsCall.swift
//  Strafen
//
//  Created by Steven on 3/15/21.
//

import Foundation

/// Used to check transactions of the club
struct CheckTransactionsCall: FunctionCallable {
    
    /// Club id
    let clubId: Club.ID
    
    /// Function name
    let functionName: String = "checkTransactions"
    
    /// Parameters
    var parameters: Parameters {
        Parameters { parameters in
            parameters["clubId"] = clubId
        }
    }
}
