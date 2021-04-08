//
//  NewTransactionCall.swift
//  Strafen
//
//  Created by Steven on 3/11/21.
//

import Foundation

/// Used to create a new transaction in the database
struct NewTransactionCall: FunctionCallable {
    
    /// Club id
    let clubId: Club.ID
    
    /// Transaction
    let transaction: Transaction
    
    /// Function name
    let functionName: String = "newTransaction"
    
    /// Parameters
    var parameters: Parameters {
        Parameters { parameters in
            parameters["clubId"] = clubId
            parameters["personId"] = transaction.personId
            parameters["transactionId"] = transaction.id
            parameters["payedFinesIds"] = transaction.fineIds as [ParameterableObject]
            parameters["payDate"] = transaction.payDate
            parameters["firstName"] = transaction.name?.first
            parameters["lastName"] = transaction.name?.last
        }
    }
}
