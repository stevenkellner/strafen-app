//
//  FFChangeListCall.swift
//  Strafen
//
//  Created by Steven on 17.05.21.
//

import Foundation

/// Used to change list types in database
struct FFChangeListCall<T>: FFCallable where T: FirebaseListType {

    /// Type of the change
    enum ChangeType<T> where T: FirebaseListType {

        /// Update / set a list item
        case update(item: T)

        /// Remove a list item
        case delete

        /// Item to change
        var item: T? {
            switch self {
            case .update(item: let item):
                return item
            case .delete:
                return nil
            }
        }
    }

    /// Club id
    let clubId: UUID

    /// Type of the change
    let changeType: ChangeType<T>

    /// Used to delete a list item
    /// - Parameter clubId: Club id
    init(clubId: UUID) {
        self.clubId = clubId
        self.changeType = .delete
    }

    /// Used to update a list item
    /// - Parameters:
    ///   - clubId: Club id
    ///   - item: Item to update
    init(clubId: UUID, item: T) {
        self.clubId = clubId
        self.changeType = .update(item: item)
    }

    let functionName = "changeList"

    var parameters: FirebaseCallParameterSet {
        FirebaseCallParameterSet(changeType.item?.parameterSet) { parameters in
            parameters["clubId"] = clubId
            parameters["changeType"] = changeType
        }
    }
}

extension FFChangeListCall.ChangeType: FirebaseParameterable {
    var primordialParameter: FirebasePrimordialParameterable {
        switch self {
        case .update(item: _):
            return "update"
        case .delete:
            return "delete"
        }
    }
}
