//
//  FirebaseStatistic.swift
//  Strafen
//
//  Created by Steven on 27.06.21.
//

import Foundation

protocol FirebaseStatisticProperty: Decodable {}

struct FirebaseStatistic {

    /// Tagged UUID type of the id
    typealias ID = Tagged<FirebaseStatistic, UUID> // swiftlint:disable:this type_name

    /// Id of the statistic
    let id: ID // swiftlint:disable:this identifier_name

    /// Timestamp of the statistic
    let timestamp: Date

    /// Properties of the statistic
    let properties: FirebaseStatisticProperty
}

extension FirebaseStatistic: FirebaseListType {

    static let urlFromClub = URL(string: "statistics")!

    static let listType: String = "statistic"

    /// Coding Keys for Decodable
    enum CodingKeys: String, CodingKey {
        case id = "key" // swiftlint:disable:this identifier_name
        case name
        case timestamp
        case properties
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
            self.properties = try container.decode(ChangeFinePayedStatistic.self, forKey: .properties)
        case "changeLatePaymentInterest":
            self.properties = try container.decode(ChangeLatePaymentInterestStatistic.self, forKey: .properties)
        case "changeList":
            let listType = try container.decode(ListType.self, forKey: .properties)
            switch listType {
            case .person: self.properties = try container.decode(ChangeListStatistic<FirebasePerson>.self, forKey: .properties)
            case .fine: self.properties = try container.decode(ChangeListStatistic<FirebaseFine>.self, forKey: .properties)
            case .reason: self.properties = try container.decode(ChangeListStatistic<FirebaseReasonTemplate>.self, forKey: .properties)
            case .transaction: self.properties = try container.decode(ChangeListStatistic<FirebaseTransaction>.self, forKey: .properties)
            }
        case "forceSignOut":
            self.properties = try container.decode(ForceSignOutStatistic.self, forKey: .properties)
        case "newClub":
            self.properties = NewClubStatistic()
        case "registerPerson":
            self.properties = try container.decode(RegisterPersonStatistic.self, forKey: .properties)
        default:
            throw DecodingError.dataCorruptedError(forKey: .name, in: container, debugDescription: "Invalid statistic name: \(statisticName)")
        }
    }

    var parameterSet: FirebaseCallParameterSet {
        fatalError("FirebaseStatistic can't be changed in database.")
    }
}
