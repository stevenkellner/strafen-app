//
//  Reason.swift
//  Strafen
//
//  Created by Steven on 12.07.20.
//

import Foundation

/// Contains all data of a reason
struct Reason: ListTypes {
    
    /// Url to list on server
    static let serverListUrl = \AppUrls.listTypesUrls?.reason
    
    /// Reason
    let reason: String
    
    /// Id
    let id: UUID
    
    /// Amount
    let amount: Euro
    
    /// Importance
    let importance: Fine.Importance
}
