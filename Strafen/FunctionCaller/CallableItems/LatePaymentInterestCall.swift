//
//  LatePaymentInterestCall.swift
//  Strafen
//
//  Created by Steven on 12/16/20.
//

import Foundation

/// Late payment interest call
struct LatePaymentInterestCall: FunctionCallable {
    
    /// Late payment interest
    let latePaymentInterest: Settings.LatePaymentInterest?
    
    /// Club id
    let clubId: Club.ID
    
    /// Function name
    let functionName: String = "changeLatePaymentInterest"
    
    
    /// Parameters
    var parameters: Parameters {
        Parameters(latePaymentInterest?.parameters) { parameters in
            parameters["clubId"] = clubId
        }
    }
}
