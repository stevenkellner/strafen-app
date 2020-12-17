//
//  ListstTypes.swift
//  Strafen
//
//  Created by Steven on 02.07.20.
//

import Foundation

/// Id List type
protocol ListTypeId {
    
    /// Init from uuid
    init(rawValue: UUID)
}

/// Protocol for a list type of database
protocol ListType: Identifiable where ID: ListTypeId {
    
    /// Codable list type
    associatedtype CodableSelf: Decodable
    
    /// Init with id and codable self
    init(with id: ID, codableSelf: CodableSelf)
    
    /// Get list of ListData of this type
    static func getDataList() -> [Self]?
    
    /// Change list of ListData of this type
    static func changeHandler(_ newList: [Self]?)
    
    /// Url for database refernce
    ///
    /// - Note: Don't use this url when no person is logged in
    static var url: URL { get }
    
    /// Parameters for database change call
    var callParameters: Parameters { get }
}
