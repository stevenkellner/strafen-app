//
//  CodableSettings.swift
//  Strafen
//
//  Created by Steven on 9/4/20.
//

import Foundation

/// Used to en- / decode settings from json
struct CodableSettings: Codable {
    
    /// Appearance of the app (light / dark / system)
    let appearance: Settings.Appearance
    
    /// Style of the app (default / plain)
    let style: Settings.Style
    
    /// Person that is logged in
    let person: Settings.Person?
    
    /// Late payment interest
    let latePaymentInterest: Settings.LatePaymentInterest?
    
    /// Json data of this setting struct
    var jsonData: Data {
        let encoder = JSONEncoder()
        return try! encoder.encode(self)
    }
}
