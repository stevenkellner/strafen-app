//
//  ChangeListStatistic.swift
//  Strafen
//
//  Created by Steven on 26.06.21.
//

import Foundation

/// Statistic of `changeList` call
struct ChangeListStatistic<T>: FirebaseStatisticProperty where T: FirebaseListType {

    /// Type of the changed item
    let changeType: FFChangeListCall<T>.ChangeType<T>
}

extension ChangeListStatistic: Decodable {

    /// Coding Keys for Decodable
    enum CodingKeys: String, CodingKey {

        /// Type of the changed item
        case changeType

        /// Changed item
        case item
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let changeType = try container.decode(String.self, forKey: .changeType)
        switch changeType {
        case "update":
            let item = try container.decode(T.self, forKey: .item)
            self.changeType = .update(item: item)
        case "delete":
            guard let itemId = try container.decode([String: T.ID].self, forKey: .item)["key"] else {
                throw DecodingError.dataCorruptedError(forKey: .item, in: container, debugDescription: "Item has no vaild key")
            }
            self.changeType = .delete(itemId: itemId)
        default:
            throw DecodingError.dataCorruptedError(forKey: .changeType, in: container, debugDescription: "Invalid change type: \(changeType)")
        }
    }
}
