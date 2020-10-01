//
//  LatePaymentInterestChange.swift
//  Strafen
//
//  Created by Steven on 9/19/20.
//

import Foundation

/// Late payment interest change
struct LatePaymentInterestChange: Changeable, Parameterable {
    
    /// Late payment interest
    let latePaymentInterest: Settings.LatePaymentInterest?
    
    /// Club id
    let clubId: UUID
    
    init(latePaymentInterest: Settings.LatePaymentInterest?, clubId: UUID? = nil) {
        self.latePaymentInterest = latePaymentInterest
        self.clubId = clubId ?? Settings.shared.person!.clubId
    }
    
    /// Path from AppUrls to changer url
    var urlPath: KeyPath<AppUrls, URL> = \.changer.latePaymentInterest
    
    /// Parameters
    var parameters: Parameters {
        var parameters = Parameters { parameters in
            parameters["clubId"] = clubId.uuidString
        }
        if let latePaymentInterest = latePaymentInterest {
            parameters.add(latePaymentInterest.parameters)
        }
        return parameters
    }
}
