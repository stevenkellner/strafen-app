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
    
    /// Path from AppUrls to changer url
    var urlPath: KeyPath<AppUrls, URL> = \.changer.latePaymentInterest
    
    /// Parameters
    var parameters: Parameters {
        var parameters = Parameters { parameters in
            parameters["clubId"] = Settings.shared.person!.clubId.uuidString
        }
        if let latePaymentInterest = latePaymentInterest {
            parameters.add(latePaymentInterest.parameters)
        }
        return parameters
    }
}
