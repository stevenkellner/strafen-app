//
//  ListstTypes.swift
//  Strafen
//
//  Created by Steven on 02.07.20.
//

import Foundation

/// Id List type
protocol ListTypeId {
    
    /// Init from string
    init(rawId: String)
}

/// Protocol for a list type to get from the database
protocol ListTypeGet: Identifiable where ID: ListTypeId {
    
    /// Codable list type
    associatedtype CodableSelf: Decodable
    
    /// Init with id and codable self
    init(with id: ID, codableSelf: CodableSelf)
    
    /// Url for database refernce
    ///
    /// - Note: Don't use this url when no person is logged in
    static var url: URL { get }
}

/// Protocol for a list type to change it on the database
protocol ListTypeChange {
    
    #if TARGET_MAIN_APP
    /// Get list of ListData of this type
    static func getDataList() -> [Self]?
    
    /// Change list of ListData of this type
    static func changeHandler(_ newList: [Self]?)
    
    /// Parameters for database change call
    var callParameters: Parameters { get }
    #endif
}

/// Protocol for a list type of database
typealias ListType = ListTypeGet & ListTypeChange

// Extension of URL to get path to list of person / reason / fine
extension URL {
    private static func baseList(with id: Club.ID) -> URL {
        URL(string: Bundle.main.firebaseClubsComponent)!.appendingPathComponent(id.uuidString.uppercased())
    }
    
    /// Path to person list of club with given id
    static func personList(with id: Club.ID) -> URL {
        baseList(with: id).appendingPathComponent("persons")
    }
    
    /// Path to reason list of club with given id
    static func reasonList(with id: Club.ID) -> URL {
        baseList(with: id).appendingPathComponent("reasons")
    }
    
    /// Path to fine list of club with given id
    static func fineList(with id: Club.ID) -> URL {
        baseList(with: id).appendingPathComponent("fines")
    }
    
    /// Path to transaction list of club with given id
    static func transactionList(with id: Club.ID) -> URL {
        baseList(with: id).appendingPathComponent("transactions")
    }
    
    /// Path to payout list of club with given id
    static func payoutList(with id: Club.ID) -> URL {
        baseList(with: id).appendingPathComponent("payouts")
    }
}

extension String: ListTypeId {
    init(rawId: String) {
        self = rawId
    }
}

extension UUID: ListTypeId {
    init(rawId: String) {
        self = .init(uuidString: rawId)!
    }
}
