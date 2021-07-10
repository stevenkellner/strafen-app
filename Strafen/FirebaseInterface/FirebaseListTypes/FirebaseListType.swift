//
//  FirebaseListType.swift
//  Strafen
//
//  Created by Steven on 04.05.21.
//

import Foundation

/// Type of Firebase List
protocol FirebaseListType: Decodable, Identifiable where ID: FirebaseParameterable & Decodable {

    associatedtype Statistic: Decodable

    /// Kind of firebase list type
    static var kind: FirebaseListTypeKind { get }

    /// Set of parameters to call a firebase function
    var parameterSet: FirebaseCallParameterSet { get }
}

extension FirebaseListType {

    /// Url from club to list in firebase database
    static var urlFromClub: URL {
        switch Self.kind {
        case .person: return URL(string: "persons")!
        case .fine: return URL(string: "fines")!
        case .reason: return URL(string: "reasons")!
        case .transaction: return URL(string: "transactions")!
        case .statistic: return URL(string: "statistics")!
        }
    }

    /// List type to change in database
    static var listType: String {
        switch Self.kind {
        case .person: return "person"
        case .fine: return "fine"
        case .reason: return "reason"
        case .transaction: return "transaction"
        case .statistic: return "statistic"
        }
    }
}

/// All kinds of firebase list types
enum FirebaseListTypeKind: CaseIterable, Hashable {

    /// List type has kind `person`
    case person

    /// List type has kind `fine`
    case fine

    /// List type has kind `reason`
    case reason

    /// List type has kind `transaction`
    case transaction

    /// List type has kind `statistic`
    case statistic
}
