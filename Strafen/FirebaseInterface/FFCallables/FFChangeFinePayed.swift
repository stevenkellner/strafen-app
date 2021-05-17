//
//  FFChangeFinePayed.swift
//  Strafen
//
//  Created by Steven on 17.05.21.
//

import Foundation

/// Changes payment state of a fine
struct FFChangeFinePayed: FFCallable {

    /// Club id
    let clubId: Club.ID

    /// Fine id
    let fineId: FirebaseFine.ID

    /// New state of payment
    let newState: Payed

    let functionName = "changeFinePayed"

    var parameters: FirebaseCallParameterSet {
        FirebaseCallParameterSet { parameters in
            parameters["clubId"] = clubId
            parameters["fineId"] = fineId
            parameters["state"] = newState.state
            parameters["payDate"] = newState.payDate
            parameters["inApp"] = newState.payedInApp
        }
    }
}
