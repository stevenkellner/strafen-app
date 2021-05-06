//
//  FirebaseReasonTemplate.swift
//  Strafen
//
//  Created by Steven on 05.05.21.
//

import Foundation

/// Contains all properties of a reason template in firebase database
struct FirebaseReasonTemplate {
    
    /// Tagged UUID type of the id
    typealias ID = Tagged<(FirebaseReasonTemplate, id: Void), UUID>
    
    /// Id
    let id: ID
    
    /// Reason of this template
    let reason: String
    
    /// Imporance of this template
    let importance: Importance
    
    /// Amount of this template
    let amount: Amount
}

extension FirebaseReasonTemplate: FirebaseListType {
    
    static let urlFromClub = URL(string: "reasons")!
    
    /// Coding Keys for Decodable
    enum CodingKeys: String, CodingKey {
        case id = "key"
        case reason
        case importance
        case amount
    }
}

extension FirebaseReasonTemplate: Equatable {}
