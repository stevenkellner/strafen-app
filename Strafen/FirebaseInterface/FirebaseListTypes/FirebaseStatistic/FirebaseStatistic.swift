//
//  FirebaseStatistic.swift
//  Strafen
//
//  Created by Steven on 27.06.21.
//

import Foundation

protocol StatisticProperty: Decodable {}

struct FirebaseStatistic {

    /// Property of firebase statistic
    enum Property {

        /// For `changeFinePayed` call
        case changeFinePayed(property: SPChangeFinePayed)

        /// For `changeLatePaymentInterest` call
        case changeLatePaymentInterest(property: SPChangeLatePaymentInterest)

        /// For `changeList` person call
        case changeListPerson(property: SPChangeList<FirebasePerson>)

        /// For `changeList` fine call
        case changeListFine(property: SPChangeList<FirebaseFine>)

        /// For `changeList` reason call
        case changeListReason(property: SPChangeList<FirebaseReasonTemplate>)

        /// For `changeList` transaction call
        case changeListTransaction(property: SPChangeList<FirebaseTransaction>)

        /// For `newClub` call
        case newClub(property: SPNewClub)

        /// For `registerPerson` call
        case registerPerson(property: SPRegisterPerson)

        var rawProperty: StatisticProperty? {
            switch self {
            case .changeFinePayed(let property): return property
            case .changeLatePaymentInterest(let property): return property
            case .changeListPerson(let property): return property
            case .changeListFine(let property): return property
            case .changeListReason(let property): return property
            case .changeListTransaction(let property): return property
            case .newClub(let property): return property
            case .registerPerson(let property): return property
            }
        }
    }

    /// Tagged UUID type of the id
    typealias ID = Tagged<FirebaseStatistic, UUID> // swiftlint:disable:this type_name

    /// Id of the statistic
    let id: ID // swiftlint:disable:this identifier_name

    /// Timestamp of the statistic
    let timestamp: Date

    /// Properties of the statistic
    let property: Property
}

extension FirebaseStatistic: FirebaseListType {

    static let urlFromClub = URL(string: "statistics")!

    static let listType: String = "statistic"

    /// Coding Keys for Decodable
    enum CodingKeys: String, CodingKey {
        case id // swiftlint:disable:this identifier_name
        case name
        case timestamp
        case property = "properties"
    }

    private enum ListType: Decodable {
        case person
        case fine
        case reason
        case transaction

        /// Coding Keys for Decodable
        enum CodingKeys: String, CodingKey {
            case listType
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let listType = try container.decode(String.self, forKey: .listType)
            switch listType {
            case "person": self = .person
            case "fine": self = .fine
            case "reason": self = .reason
            case "transaction": self = .transaction
            default:
                throw DecodingError.dataCorruptedError(forKey: .listType, in: container, debugDescription: "Invalid list type: \(listType)")
            }
        }
    }

    init(from decoder: Decoder) throws { // swiftlint:disable:this cyclomatic_complexity
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(ID.self, forKey: .id)
        self.timestamp = Date(timeIntervalSince1970: try container.decode(Double.self, forKey: .timestamp) / 1000)
        let statisticName = try container.decode(String.self, forKey: .name)
        switch statisticName {
        case "changeFinePayed":
            self.property = .changeFinePayed(property: try container.decode(SPChangeFinePayed.self, forKey: .property))
        case "changeLatePaymentInterest":
            guard container.contains(.property) else {
                self.property = .changeLatePaymentInterest(property: SPChangeLatePaymentInterest())
                return
            }
            self.property = .changeLatePaymentInterest(property: try container.decode(SPChangeLatePaymentInterest.self, forKey: .property))
        case "changeList":
            let listType = try container.decode(ListType.self, forKey: .property)
            switch listType {
            case .person: self.property = .changeListPerson(property: try container.decode(SPChangeList<FirebasePerson>.self, forKey: .property))
            case .fine: self.property = .changeListFine(property: try container.decode(SPChangeList<FirebaseFine>.self, forKey: .property))
            case .reason: self.property = .changeListReason(property: try container.decode(SPChangeList<FirebaseReasonTemplate>.self, forKey: .property))
            case .transaction: self.property = .changeListTransaction(property: try container.decode(SPChangeList<FirebaseTransaction>.self, forKey: .property))
            }
        case "newClub":
            self.property = .newClub(property: try container.decode(SPNewClub.self, forKey: .property))
        case "registerPerson":
            self.property = .registerPerson(property: try container.decode(SPRegisterPerson.self, forKey: .property))
        default:
            throw DecodingError.dataCorruptedError(forKey: .name, in: container, debugDescription: "Invalid statistic name: \(statisticName)")
        }
    }

    var parameterSet: FirebaseCallParameterSet {
        fatalError("FirebaseStatistic can't be changed in database.")
    }
}
