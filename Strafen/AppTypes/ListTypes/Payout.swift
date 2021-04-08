//
//  Payout.swift
//  Strafen
//
//  Created by Steven on 3/25/21.
//

import Foundation

struct Payout {
    
    enum Status: String, Decodable {
        case pending
        case approved
        case denied
    }
    
    /// Type of Id
    typealias ID = Tagged<(Payout, id: Void), UUID>
    
    /// id
    let id: ID
    
    /// Amount
    let amount: Amount
    
    /// Person detail
    let personDetail: String
    
    /// Status
    let status: Status
}

// Extension of Payout confirm to ListTypeGet
extension Payout: ListTypeGet {
    
    /// Url for database refernce
    static var url: URL {
        guard let clubId = Settings.shared.person?.clubProperties.id else {
            fatalError("No person is logged in.")
        }
        return URL.payoutList(with: clubId)
    }
    
    /// Init with id and codable self
    init(with id: ID, codableSelf: CodableSelf) {
        self.id = id
        self.amount = codableSelf.amount
        self.personDetail = codableSelf.personDetail
        self.status = codableSelf.status
    }
}

// Extension of Payout for CodableSelf
extension Payout {
    
    /// Payout to fetch from database
    struct CodableSelf: Decodable {
        
        /// Amount
        let amount: Amount
        
        /// Person detail
        let personDetail: String
        
        /// Status
        let status: Status
    }
}
