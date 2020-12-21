//
//  ReasonTemplate.swift
//  Strafen
//
//  Created by Steven on 11/7/20.
//

import Foundation

/// Contains all properties of a reason
struct ReasonTemplate {
    
    /// Type of Id
    typealias ID = Tagged<(ReasonTemplate, id: Void), UUID>
    
    /// Id
    let id: ID
    
    /// Reason of this template
    let reason: String
    
    /// Imporance of this template
    let importance: Importance
    
    /// Amount of this template
    let amount: Amount
}

// Extension of ReasonTemplate to confirm to ListType
extension ReasonTemplate: ListType {
    
    /// Url for database refernce
    static var url: URL {
        guard let clubId = Settings.shared.person?.clubProperties.id else {
            fatalError("No person is logged in.")
        }
        return URL.reasonList(with: clubId)
    }
    
    /// Init with id and codable self
    init(with id: ID, codableSelf: CodableSelf) {
        self.id = id
        self.reason = codableSelf.reason
        self.importance = codableSelf.importance
        self.amount = codableSelf.amount
    }
    
    #if TARGET_MAIN_APP
    /// Get reason template list of ListData
    static func getDataList() -> [ReasonTemplate]? {
        ListData.reason.list
    }
    
    /// Change reason template list of ListData
    static func changeHandler(_ newList: [ReasonTemplate]?) {
        ListData.reason.list = newList
    }
    
    /// Parameters for database change call
    var callParameters: Parameters {
        Parameters { parameters in
            parameters["itemId"] = id
            parameters["reason"] = reason
            parameters["amount"] = amount
            parameters["importance"] = importance
            parameters["listType"] = "reason"
        }
    }
    #endif
}

// Extension of ReasonTemplate for CodableSelf
extension ReasonTemplate {
    
    /// Reason template to fetch from database
    struct CodableSelf: Decodable {
        
        /// Reason of this template
        let reason: String
        
        /// Imporance of this template
        let importance: Importance
        
        /// Amount of this template
        let amount: Amount
    }
}
