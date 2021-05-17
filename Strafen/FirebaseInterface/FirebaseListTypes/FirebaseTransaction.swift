//
//  FirebaseTransaction.swift
//  Strafen
//
//  Created by Steven on 06.05.21.
//

import Foundation

// swiftlint:disable identifier_name
// swiftlint:disable type_name

/// Contains all properties of a transaction in firebase database
struct FirebaseTransaction {

    /// Tagged String type of the id
    typealias ID = Tagged<(FirebaseTransaction, id: Void), String>

    /// id
    let id: ID

    /// Indicates whether transaction is approved
    let approved: Bool

    /// Ids of fines payed with this transaction
    let fineIds: [FirebaseFine.ID]

    /// Name of person that payed this transaction
    let name: OptionalPersonName?

    /// Date
    let payDate: Date

    /// Id of person that payed this transaction
    let personId: FirebasePerson.ID

    /// Id of payout
    let payoutId: String?

    init(id: ID, approved: Bool, fineIds: [FirebaseFine.ID], name: OptionalPersonName?, payDate: Date, personId: FirebasePerson.ID, payoutId: String?) {
        self.id = id
        self.approved = approved
        self.fineIds = fineIds.sorted { $0.uuidString < $1.uuidString }
        self.name = name
        self.payDate = payDate
        self.personId = personId
        self.payoutId = payoutId
    }
}

extension FirebaseTransaction: FirebaseListType {

    static let urlFromClub = URL(string: "transactions")!

    /// Coding Keys for Decodable
    enum CodingKeys: String, CodingKey {
        case id = "key"
        case approved
        case fineIds
        case name
        case payDate
        case personId
        case payoutId
    }
}

extension FirebaseTransaction: Equatable {}
