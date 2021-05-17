//
//  FirebasePerson.swift
//  Strafen
//
//  Created by Steven on 04.05.21.
//

import Foundation

// swiftlint:disable identifier_name
// swiftlint:disable type_name

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

    static let urlFromClub = URL(string: "persons")!

    static let listType: String = "person"

    /// Coding Keys for Decodable
    enum CodingKeys: String, CodingKey {
        case id = "key"
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
