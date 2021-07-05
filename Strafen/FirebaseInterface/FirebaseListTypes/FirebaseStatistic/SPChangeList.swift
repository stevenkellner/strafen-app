//
//  SPChangeList.swift
//  Strafen
//
//  Created by Steven on 26.06.21.
//

import Foundation

/// Statistic of `changeList` call
struct SPChangeList<T>: StatisticProperty where T: FirebaseListType {

    enum ChangedItem<T>: Decodable where T: FirebaseListType {
        case update(item: T.Statistic)
        case delete(id: T.ID) // swiftlint:disable:this identifier_name

        enum IDCodingKeys: CodingKey {
            case id // swiftlint:disable:this identifier_name
        }

        init(from decoder: Decoder) throws {
            do {
                let item = try T.Statistic(from: decoder)
                self = .update(item: item)
            } catch {
                let container = try decoder.container(keyedBy: IDCodingKeys.self)
                let id = try container.decode(T.ID.self, forKey: .id) // swiftlint:disable:this identifier_name
                self = .delete(id: id)
            }
        }

        /// Item if change type is `.update`
        var item: T.Statistic? {
            switch self {
            case .update(let item): return item
            case .delete(_): return nil
            }
        }
    }

    /// Previous item to change
    let previousItem: T.Statistic?

    /// Changed item
    let changedItem: ChangedItem<T>
}

extension SPChangeList.ChangedItem: Equatable where T.Statistic: Equatable {}
