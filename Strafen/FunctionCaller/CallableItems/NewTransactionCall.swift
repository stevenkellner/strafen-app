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
    
    /// Person id
    let personId: Person.ID
    
    /// Transaction id
    let transactionId: String
    
    /// Payed fine ids
    let payedFinesIds: [Fine.ID]
    
    /// First name
    let firstName: String?
    
    /// Last name
    let lastName: String?
    
    /// Function name
    let functionName: String = "newTransaction"
    
    /// Parameters
    var parameters: Parameters {
        Parameters { parameters in
            parameters["clubId"] = clubId
            parameters["personId"] = personId
            parameters["transactionId"] = transactionId
            parameters["payedFinesIds"] = payedFinesIds as [ParameterableObject]
            parameters["payDate"] = Date()
            parameters["firstName"] = firstName
            parameters["lastName"] = lastName
        }
    }
}
