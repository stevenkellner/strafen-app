//
//  Reason.swift
//  Strafen
//
//  Created by Steven on 12.07.20.
//

import Foundation

/// Contains all data of a reason
struct Reason: ListTypes, Identifiable, Equatable {
    
    /// Url to list on server
    static let serverListUrl = \AppUrls.listTypesUrls?.reason
    
    /// List data of this server list type
    static let listData = ListData.reason
    
    /// Url to changer on server
    static let changerUrl: KeyPath<AppUrls, URL>? = \AppUrls.changer.reasonList
    
    /// Parameters for POST method
    var postParameters: [String : Any]? {
        [
            "id": id,
            "reason": reason,
            "amount": amount.doubleValue,
            "importance": importance.string
        ]
    }
    
    /// Reason
    let reason: String
    
    /// Id
    let id: UUID
    
    /// Amount
    let amount: Euro
    
    /// Importance
    let importance: Fine.Importance
}
