//
//  ReasonTemplate.swift
//  Strafen
//
//  Created by Steven on 11/7/20.
//

import Foundation

/// Contains all properties of a reason
struct ReasonTemplate {
    
    /// Id
    let id: UUID
    
    /// Reason of this template
    let reason: String
    
    /// Imporance of this template
    let importance: Importance
    
    /// Amount of this template
    let amount: Amount
}

// Extension of ReasonTemplate to confirm to ListType
extension ReasonTemplate: NewListType {
    
    /// Url for database refernce
    static var url: URL {
        guard let clubId = NewSettings.shared.properties.person?.clubProperties.id else {
            fatalError("No person is logged in.")
        }
        return URL.reasonList(with: clubId)
    }
    
    /// Init with id and codable self
    init(with id: UUID, codableSelf: CodableSelf) {
        self.id = id
        self.reason = codableSelf.reason
        self.importance = codableSelf.importance
        self.amount = codableSelf.amount
    }
    
    /// Get reason template list of ListData
    static func getDataList() -> [ReasonTemplate]? {
        NewListData.reason.list
    }
    
    /// Change reason template list of ListData
    static func changeHandler(_ newList: [ReasonTemplate]?) {
        NewListData.reason.list = newList
    }
    
    /// Parameters for database change call
    var callParameters: NewParameters {
        NewParameters { parameters in
            parameters["itemId"] = id
            parameters["reason"] = reason
            parameters["amount"] = amount
            parameters["importance"] = importance
            parameters["listType"] = "reason"
        }
    }
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
