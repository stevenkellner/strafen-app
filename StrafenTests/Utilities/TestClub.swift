//
//  TestClub.swift
//  StrafenTests
//
//  Created by Steven on 06.05.21.
//

import Foundation
@testable import Strafen

/// Contains all properties of a club
struct TestClub: Equatable {
    let properties: Properties
    let persons: [FirebasePerson]
    let fines: [FirebaseFine]
    let reasons: [FirebaseReasonTemplate]
    let transactions: [FirebaseTransaction]

    struct Properties: Decodable, Equatable {
        let identifier: String
        let inAppPaymentActive: Bool?
        let name: String
        let regionCode: String
        let personUserIds: [String: String]

        init(identifier: String, inAppPaymentActive: Bool?, name: String, regionCode: String, personUserIds: [String: String]) {
            self.identifier = identifier
            self.inAppPaymentActive = inAppPaymentActive
            self.name = name
            self.regionCode = regionCode
            self.personUserIds = Dictionary(personUserIds.sorted { $0.key < $1.key }) { first, _ in first }
        }

        func club(with clubId: Club.ID) -> Club {
            Club(id: clubId, name: name, identifier: identifier, regionCode: regionCode, inAppPaymentActive: inAppPaymentActive)
        }
    }

    init(properties: Properties, persons: [FirebasePerson], fines: [FirebaseFine], reasons: [FirebaseReasonTemplate], transactions: [FirebaseTransaction]) {
        self.properties = properties
        self.persons = persons.sorted { $0.id.uuidString < $1.id.uuidString }
        self.fines = fines.sorted { $0.id.uuidString < $1.id.uuidString }
        self.reasons = reasons.sorted { $0.id.uuidString < $1.id.uuidString }
        self.transactions = transactions.sorted { $0.id < $1.id }
    }

    static var fetcherTestClub =
        TestClub(properties:
                Properties(
                    identifier: "demo-team",
                    inAppPaymentActive: true,
                    name: "Neuer Verein",
                    regionCode: "DE",
                    personUserIds:
                        [
                            "asdnfl": "76025DDE-6893-46D2-BC34-9864BB5B8DAD",
                            "wolkQGcNq5agu63Rky2bCWc2MIz2": "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7"
                        ]
                ),
             persons: [
                FirebasePerson(
                    id: FirebasePerson.ID(rawValue: UUID(uuidString: "76025DDE-6893-46D2-BC34-9864BB5B8DAD")!),
                    name: PersonName(
                        firstName: "Tommy",
                        lastName: "Arkins"
                    ),
                    signInData: FirebasePerson.SignInData(
                        isCashier: false,
                        userId: "asdnfl",
                        signInDate: Date(timeIntervalSinceReferenceDate: 6.30095493619915E8)
                    )
                ),
                FirebasePerson(
                    id: FirebasePerson.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!),
                    name: PersonName(
                        firstName: "Max",
                        lastName: "Mustermann"
                    ),
                    signInData: FirebasePerson.SignInData(
                        isCashier: true,
                        userId: "wolkQGcNq5agu63Rky2bCWc2MIz2",
                        signInDate: Date(timeIntervalSinceReferenceDate: 6.30095493619915E8)
                    )
                ),
                FirebasePerson(
                    id: FirebasePerson.ID(rawValue: UUID(uuidString: "D1852AC0-A0E2-4091-AC7E-CB2C23F708D9")!),
                    name: PersonName(
                        firstName: "John",
                        lastName: "Doe"
                    ),
                    signInData: nil
                )
             ],
             fines: [
                FirebaseFine(
                    id: FirebaseFine.ID(rawValue: UUID(uuidString: "02462A8B-107F-4BAE-A85B-EFF1F727C00F")!),
                    assoiatedPersonId: FirebasePerson.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!),
                    date: Date(timeIntervalSinceReferenceDate: 6.3018780725609E8),
                    payed: .unpayed,
                    number: 1,
                    fineReason: FineReasonTemplate(
                        templateId: FirebaseReasonTemplate.ID(rawValue: UUID(uuidString: "062FB0CB-F730-497B-BCF5-A4F907A6DCD5")!)
                    )
                ),
                FirebaseFine(
                    id: FirebaseFine.ID(rawValue: UUID(uuidString: "0B5F958E-9D7D-46E1-8AEE-F52F4370A95A")!),
                    assoiatedPersonId: FirebasePerson.ID(rawValue: UUID(uuidString: "76025DDE-6893-46D2-BC34-9864BB5B8DAD")!),
                    date: Date(timeIntervalSinceReferenceDate: 6.3016007523132E8),
                    payed: .payed(date: Date(timeIntervalSinceReferenceDate: 6.30160103445665E8), inApp: false),
                    number: 2,
                    fineReason: FineReasonCustom(
                        reason: "Das ist ein Test",
                        amount: Amount(1, subUnit: 10),
                        importance: .medium
                    )
                )
             ],
             reasons: [
                FirebaseReasonTemplate(
                    id: FirebaseReasonTemplate.ID(rawValue: UUID(uuidString: "062FB0CB-F730-497B-BCF5-A4F907A6DCD5")!),
                    reason: "Gelbe Karte Unsportlichkeit",
                    importance: .high,
                    amount: Amount(10, subUnit: 0)
                ),
                FirebaseReasonTemplate(
                    id: FirebaseReasonTemplate.ID(rawValue: UUID(uuidString: "16805D21-5E8D-43E9-BB5C-7B4A790F0CE7")!),
                    reason: "Mit Stutzen Auslaufen",
                    importance: .low,
                    amount: Amount(2, subUnit: 0)
                ),
                FirebaseReasonTemplate(
                    id: FirebaseReasonTemplate.ID(rawValue: UUID(uuidString: "23A3412E-87DE-4A23-A08F-67214B8A8541")!),
                    reason: "Spiel Ausrüstung Vergessen",
                    importance: .medium,
                    amount: Amount(3, subUnit: 0)
                )
             ],
             transactions: [
                FirebaseTransaction(
                    id: FirebaseTransaction.ID(rawValue: "2MQQXVPV"),
                    approved: true,
                    fineIds: [
                        FirebaseFine.ID(rawValue: UUID(uuidString: "0B5F958E-9D7D-46E1-8AEE-F52F4370A95A")!)
                    ],
                    name: OptionalPersonName(
                        first: "Max",
                        last: "Mustermann"
                    ),
                    payDate: Date(timeIntervalSinceReferenceDate: 6.37601313257926E8),
                    personId: FirebasePerson.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!),
                    payoutId: nil
                ),
                FirebaseTransaction(
                    id: FirebaseTransaction.ID(rawValue: "7RQYM2DQ"),
                    approved: false,
                    fineIds: [
                        FirebaseFine.ID(rawValue: UUID(uuidString: "02462A8B-107F-4BAE-A85B-EFF1F727C00F")!)
                    ],
                    name: nil,
                    payDate: Date(timeIntervalSinceReferenceDate: 6.37599817777474E8),
                    personId: FirebasePerson.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!),
                    payoutId: nil
                )
             ]
        )
}
