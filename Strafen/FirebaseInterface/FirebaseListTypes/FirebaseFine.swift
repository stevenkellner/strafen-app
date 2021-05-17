//
//  FirebaseFine.swift
//  Strafen
//
//  Created by Steven on 05.05.21.
//

import Foundation

// swiftlint:disable identifier_name
// swiftlint:disable type_name

/// Contains all properties of a fine in firebase database
struct FirebaseFine {

    /// Tagged UUID type of the id
    typealias ID = Tagged<(FirebaseFine, id: Void), UUID>

    /// Id
    let id: ID

    /// Id of the associated person
    let assoiatedPersonId: FirebasePerson.ID

    /// Date this fine was issued
    let date: Date

    /// Is fine payed
    var payed: Payed

    /// Number of fines
    let number: Int

    /// Codable fine reason for reason / amount / importance or templateId
    private var codableFineReason: CodableFineReason

    /// Fine reason for reason / amount / importance or templateId
    var fineReason: FineReason {
        get { codableFineReason.fineReason }
        set {
            if let fineReason = newValue as? FineReasonTemplate {
                codableFineReason = CodableFineReason(reason: nil, amount: nil, importance: nil, templateId: fineReason.templateId)
            } else if let fineReason = newValue as? FineReasonCustom {
                codableFineReason = CodableFineReason(reason: fineReason.reason, amount: fineReason.amount, importance: fineReason.importance, templateId: nil)
            } else {
                fatalError("No valid fine reason")
            }
        }
    }

    init(id: ID, assoiatedPersonId: FirebasePerson.ID, date: Date, payed: Payed, number: Int, fineReason: FineReason) {
        self.id = id
        self.assoiatedPersonId = assoiatedPersonId
        self.date = date
        self.payed = payed
        self.number = number
        if let fineReason = fineReason as? FineReasonTemplate {
            codableFineReason = CodableFineReason(reason: nil, amount: nil, importance: nil, templateId: fineReason.templateId)
        } else if let fineReason = fineReason as? FineReasonCustom {
            codableFineReason = CodableFineReason(reason: fineReason.reason, amount: fineReason.amount, importance: fineReason.importance, templateId: nil)
        } else {
            fatalError("No valid fine reason")
        }
    }
}

extension FirebaseFine: FirebaseListType {

    static let urlFromClub = URL(string: "fines")!

    /// Coding Keys for Decodable
    enum CodingKeys: String, CodingKey {
        case id = "key"
        case assoiatedPersonId = "personId"
        case date
        case payed
        case number
        case codableFineReason = "reason"
     }
}

extension FirebaseFine: Equatable {}
