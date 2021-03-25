//
//  PaymentTransaction.swift
//  Strafen
//
//  Created by Steven on 3/25/21.
//

import Foundation

struct PaymentTransaction: Decodable {
    
    /// Custom fields
    struct CustomFields: Decodable {
        enum CodingKeys: String, CodingKey {
            case _clubId = "clubId"
            case _fineIds = "fineIds"
        }
        
        /// Raw club id
        private let _clubId: String
        
        /// Raw fine ids
        private let _fineIds: String
        
        /// Club id
        var clubId: Club.ID {
            Club.ID(rawValue: UUID(uuidString: _clubId)!)
        }
        
        /// Fine ids
        var fineIds: [Fine.ID] {
            try! JSONDecoder().decode([Fine.ID].self, from: _fineIds.data(using: .utf8)!)
        }
    }
    
    /// Type of Id
    typealias ID = Tagged<(PaymentTransaction, id: Void), String>
    
    /// id
    let id: ID
    
    /// Status
    let status: String
    
    /// Currency code
    let currencyIsoCode: String
    
    /// Amount string
    let amount: String
    
    /// Custom fields
    let customFields: CustomFields
}
