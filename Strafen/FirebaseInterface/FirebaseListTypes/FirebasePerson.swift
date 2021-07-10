//
//  FirebasePerson.swift
//  Strafen
//
//  Created by Steven on 04.05.21.
//

import Foundation

/// Contains all properties of a person in firebase database
struct FirebasePerson {

    /// Tagged UUID type of the id
    typealias ID = Tagged<FirebasePerson, UUID>

    /// Id
    let id: ID

    /// Name
    let name: PersonName

    /// Data if person is signed in
    let signInData: SignInData?

    /// Additional person informations if person is signed in
    struct SignInData {

        /// Indicates whether person is cachier
        let isCashier: Bool

        /// User id for firebase authentication
        let userId: String

        /// Date of sign in
        let signInDate: Date
    }
}

extension FirebasePerson: FirebaseListType {

    typealias Statistic = FirebasePerson

    static let kind: FirebaseListTypeKind = .person

    /// Coding Keys for Decodable
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case signInData
    }

    var parameterSet: FirebaseCallParameterSet {
        FirebaseCallParameterSet { parameter in
            parameter["firstName"] = name.firstName
            parameter["lastName"] = name.lastName
        }
    }
}

extension FirebasePerson.SignInData: Decodable {

    /// Coding Keys for Decodable
    enum CodingKeys: String, CodingKey {
        case isCashier = "cashier"
        case userId
        case signInDate
    }
}

extension FirebasePerson: Equatable {}

extension FirebasePerson.SignInData: Equatable {}

extension FirebasePerson: RandomInstanceProtocol {

    /// Generates random person
    /// - Parameter generator: random number generator
    /// - Returns: random person
    static func random<T>(using generator: inout T) -> FirebasePerson where T: RandomNumberGenerator {
        let id = ID(rawValue: UUID())
        let name = PersonName.random(using: &generator)
        let isCashier = Bool.random(using: &generator)
        let userId = (0..<Int.random(in: 5...10, using: &generator)).map {_ in String("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmopqrstuvwxyz".randomElement(using: &generator)!) }.joined()
        let date = Date(timeIntervalSinceReferenceDate: Double.random(in: 100_000...10_000_000, using: &generator))
        let signInData = Bool.random(using: &generator) ? nil : SignInData(isCashier: isCashier, userId: userId, signInDate: date)
        return FirebasePerson(id: id, name: name, signInData: signInData)
    }
}

extension FirebasePerson {

    /// List of all fines associated to this person
    /// - Parameter fineList: list of all fines
    /// - Returns: list of fines associated to this person
    func fineList(with fineList: [FirebaseFine]) -> [FirebaseFine] {
        fineList.filter { $0.assoiatedPersonId == id }
    }
}
