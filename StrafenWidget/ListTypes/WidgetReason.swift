//
//  WidgetReason.swift
//  Strafen
//
//  Created by Steven on 25.07.20.
//

import Foundation

/// Contains all data of a reason
struct WidgetReason: WidgetListTypes {
    
    /// Url to list on server
    static let serverListUrl = \WidgetUrls.ListTypesUrls.reason
    
    /// Reason
    let reason: String
    
    /// Id
    let id: UUID
    
    /// Amount
    let amount: Euro
    
    /// Importance
    let importance: WidgetFine.Importance
}
