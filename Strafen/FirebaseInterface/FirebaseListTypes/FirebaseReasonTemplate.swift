//
//  FirebaseReasonTemplate.swift
//  Strafen
//
//  Created by Steven on 05.05.21.
//

import Foundation

// swiftlint:disable identifier_name
// swiftlint:disable type_name

/// Contains all properties of a reason template in firebase database
struct FirebaseReasonTemplate {

    /// Tagged UUID type of the id
    typealias ID = Tagged<FirebaseReasonTemplate, UUID>

    /// Id
    let id: ID

    /// Reason of this template
    let reason: String

    /// Imporance of this template
    let importance: Importance

    /// Amount of this template
    let amount: Amount
}

extension FirebaseReasonTemplate: FirebaseListType {

    static let urlFromClub = URL(string: "reasons")!

    static let listType: String = "reason"

    /// Coding Keys for Decodable
    enum CodingKeys: String, CodingKey {
        case id
        case reason
        case importance
        case amount
    }

    var parameterSet: FirebaseCallParameterSet {
        FirebaseCallParameterSet { parameter in
            parameter["reason"] = reason
            parameter["amount"] = amount
            parameter["importance"] = importance
        }
    }
}

extension FirebaseReasonTemplate: Equatable {}

extension FirebaseReasonTemplate: RandomInstanceProtocol {

    /// Generates random reason
    /// - Parameter generator: random number generator
    /// - Returns: random reason
    static func random<T>(using generator: inout T) -> FirebaseReasonTemplate where T: RandomNumberGenerator {
        let id = ID(rawValue: UUID())
        let reason = (10..<Int.random(in: 20...40, using: &generator)).map { _ in String("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmopqrstuvwxyz".randomElement(using: &generator)!) }.joined()
        let importance = Importance.random(using: &generator)
        let amount = Amount.random(using: &generator)
        return FirebaseReasonTemplate(id: id, reason: reason, importance: importance, amount: amount)
    }
}
