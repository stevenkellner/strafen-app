//
//  Transaction.swift
//  Strafen
//
//  Created by Steven on 3/25/21.
//

import Foundation

struct Transaction: Decodable {
    
    /// Type of Id
    typealias ID = Tagged<(Transaction, id: Void), String>
    
    /// id
    let id: ID
    
    /// Indicates whether transaction is approved
    let approved: Bool
    
    /// Ids of fines payed with this transaction
    let fineIds: [Fine.ID]
    
    /// Name of person that payed this transaction
    let name: OptionalPersonName?
    
    /// Date
    let payDate: Date
    
    /// Id of person that payed this transaction
    let personId: Person.ID
    
    /// Id of payout
    let payoutId: Payout.ID?
}

extension Transaction {
    init(id: String, fineIds: [Fine.ID], name: OptionalPersonName?, personId: Person.ID) {
        self.id = ID(rawValue: id)
        self.approved = false
        self.fineIds = fineIds
        self.name = name
        self.payDate = Date()
        self.personId = personId
        self.payoutId = nil
    }
}

// Extension of Transaction confirm to ListTypeGet
extension Transaction: ListTypeGet {
    
    /// Url for database refernce
    static var url: URL {
        guard let clubId = Settings.shared.person?.clubProperties.id else {
            fatalError("No person is logged in.")
        }
        return URL.transactionList(with: clubId)
    }
    
    /// Init with id and codable self
    init(with id: ID, codableSelf: CodableSelf) {
        self.id = id
        self.approved = codableSelf.approved
        self.fineIds = codableSelf.fineIds
        self.name = codableSelf.name
        self.payDate = codableSelf.payDate
        self.personId = codableSelf.personId
        self.payoutId = codableSelf.payoutId
    }
}

// Extension of Transaction for CodableSelf
extension Transaction {
    
    /// Payout to fetch from database
    struct CodableSelf: Decodable {
        
        /// Indicates whether transaction is approved
        let approved: Bool
        
        /// Ids of fines payed with this transaction
        let fineIds: [Fine.ID]
        
        /// Name of person that payed this transaction
        let name: OptionalPersonName?
        
        /// Date
        let payDate: Date
        
        /// Id of person that payed this transaction
        let personId: Person.ID
        
        /// Id of payout
        let payoutId: Payout.ID?
    
    }
}
