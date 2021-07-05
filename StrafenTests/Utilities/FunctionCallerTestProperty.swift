//
//  FunctionCallerTestProperty.swift
//  StrafenTests
//
//  Created by Steven on 17.05.21.
//

import FirebaseAuth
@testable import Strafen

// swiftlint:disable identifier_name

/// Properties for all test data
struct TestProperty {

    /// Shared instance for singelton
    static let shared = Self()

    /// Private init for singleton
    private init() {}

    /// Properties for the test club
    struct TestClub {

        /// Id of the test club
        let id = Club.ID(rawValue: UUID(uuidString: "1e917710-4f69-11eb-ae93-0242ac130002")!)

        /// Name of the test club
        let name = "Test Club"

        /// Identifier of the test club
        let identifier = "test-club"

        /// Region code of the test club
        let regionCode = "DE"

        /// Club
        var club: Club {
            .init(id: id, name: name, identifier: identifier, regionCode: regionCode, inAppPaymentActive: true)
        }
    }

    /// Properties for the first test person
    struct TestPersonFirst {

        /// Id of the first test person
        let id = FirebasePerson.ID(rawValue: UUID(uuidString: "5bf1ffda-4f69-11eb-ae93-0242ac130002")!)

        /// User id of the first test person
        let userId = Auth.auth().currentUser!.uid

        /// Name of the first test person
        let name = PersonName(firstName: "First Person First Name", lastName: "First Person Last Name")

        /// Person
        var person: FirebasePerson {
            .init(id: id, name: name, signInData: nil)
        }
    }

    /// Properties for the second test person
    struct TestPersonSecond {

        /// Id of the first test person
        let id = FirebasePerson.ID(rawValue: UUID(uuidString: "3530d06e-8c79-4375-ae4c-3b9d1fdd6e28")!)

        /// User id of the first test person
        let userId = Auth.auth().currentUser!.uid

        /// Name of the first test person
        let name = PersonName(firstName: "Second Person First Name")

        /// Person
        var person: FirebasePerson {
            .init(id: id, name: name, signInData: nil)
        }
    }

    /// Properties for the third test person
    struct TestPersonThird {

        /// Id of the first test person
        let id = FirebasePerson.ID(rawValue: UUID(uuidString: "96a9c7c4-5f7b-4ea8-aac5-8ec7f0403960")!)

        /// User id of the first test person
        let userId = "Third_Person_User_Id"

        /// Name of the first test person
        let name = PersonName(firstName: "Third Person First Name", lastName: "Third Person Last Name")

        /// Person
        var person: FirebasePerson {
            .init(id: id, name: name, signInData: nil)
        }
    }

    /// Properties for test reason
    struct TestReason {

        /// Id of the test reason
        let id = FirebaseReasonTemplate.ID(rawValue: UUID(uuidString: "9d0681f0-2045-4a1d-abbc-6bb289934ff9")!)

        /// Reason
        let reason = "Test Reason 1"

        /// Updated reason
        let updatedReason = "Test Reason 2"

        /// Importance
        let importance = Importance.low

        /// Updated importance
        let updatedImportance = Importance.medium

        /// Amount
        let amount = Amount(2, subUnit: 50)

        /// Updated amount
        let updatedAmount = Amount(10, subUnit: 99)

        /// Reason
        var reasonTemplate: FirebaseReasonTemplate {
            .init(id: id, reason: reason, importance: importance, amount: amount)
        }

        /// Updated reason
        var updatedReasonTemplate: FirebaseReasonTemplate {
            .init(id: id, reason: updatedReason, importance: updatedImportance, amount: updatedAmount)
        }

        var statisticsFineReason: StatisticsFineReason {
            StatisticsFineReason(id: id, reason: reason, amount: amount, importance: importance)
        }
    }

    /// Properties for test fine
    struct TestFine {

        /// Id of the test fine
        let id = FirebaseFine.ID(rawValue: UUID(uuidString: "637d6187-68d2-4000-9cb8-7dfc3877d5ba")!)

        /// Assoiated person id
        let assoiatedPersonId = FirebasePerson.ID(rawValue: UUID(uuidString: "5bf1ffda-4f69-11eb-ae93-0242ac130002")!)

        /// Date
        let date = Date(timeIntervalSinceReferenceDate: 9284765)

        /// Fine reason template
        let reasonTemplate = FineReasonTemplate(templateId: FirebaseReasonTemplate.ID(rawValue: UUID(uuidString: "9d0681f0-2045-4a1d-abbc-6bb289934ff9")!))

        /// Fine reason custom
        let reasonCustom = FineReasonCustom(reason: "Reason", amount: Amount(1, subUnit: 50), importance: .high)

        /// Fine with reason template
        var withReasonTemplate: FirebaseFine {
            .init(id: id, assoiatedPersonId: assoiatedPersonId, date: date, payed: .unpayed, number: 2, fineReason: reasonTemplate)
        }

        /// Fine with reason custom
        var withReasonCustom: FirebaseFine {
            .init(id: id, assoiatedPersonId: assoiatedPersonId, date: date, payed: .payed(date: Date(timeIntervalSinceReferenceDate: 234689), inApp: false), number: 10, fineReason: reasonCustom)
        }

        /// Fine with reason custom
        func withReasonCustom(_ payedTimeInterval: TimeInterval) -> FirebaseFine {
            .init(id: id, assoiatedPersonId: assoiatedPersonId, date: date, payed: .payed(date: Date(timeIntervalSinceReferenceDate: payedTimeInterval), inApp: false), number: 10, fineReason: reasonCustom)
        }

        func statisticWithReasonTemplate(person: FirebasePerson, fineReason: StatisticsFineReason) -> StatisticsFine {
            StatisticsFine(id: id, person: person, payed: .unpayed, number: 2, date: date, reason: fineReason)
        }

        func statisticWithReasonCustom(person: FirebasePerson) -> StatisticsFine {
            StatisticsFine(id: id, person: person, payed: .payed(date: Date(timeIntervalSinceReferenceDate: 234689), inApp: false), number: 10, date: date, reason: StatisticsFineReason(id: nil, reason: reasonCustom.reason, amount: reasonCustom.amount, importance: reasonCustom.importance))
        }
    }

    /// Properties for test fine
    struct TestFine2 {

        /// Id of the test fine
        let id = FirebaseFine.ID(rawValue: UUID(uuidString: "137d6187-68d2-4000-9cb8-7dfc3877d5ba")!)

        /// Assoiated person id
        let assoiatedPersonId = FirebasePerson.ID(rawValue: UUID(uuidString: "5bf1ffda-4f69-11eb-ae93-0242ac130002")!)

        /// Date
        let date = Date(timeIntervalSinceReferenceDate: 9284765)

        /// Fine reason template
        let reasonTemplate = FineReasonTemplate(templateId: FirebaseReasonTemplate.ID(rawValue: UUID(uuidString: "9d0681f0-2045-4a1d-abbc-6bb289934ff9")!))

        /// Fine reason custom
        let reasonCustom = FineReasonCustom(reason: "Reason", amount: Amount(1, subUnit: 50), importance: .high)

        /// Fine with reason template
        var withReasonTemplate: FirebaseFine {
                .init(id: id, assoiatedPersonId: assoiatedPersonId, date: date, payed: .unpayed, number: 2, fineReason: reasonTemplate)
        }

        /// Fine with reason custom
        var withReasonCustom: FirebaseFine {
                .init(id: id, assoiatedPersonId: assoiatedPersonId, date: date, payed: .payed(date: Date(timeIntervalSinceReferenceDate: 234689), inApp: false), number: 10, fineReason: reasonCustom)
        }

        /// Fine with reason custom
        func withReasonCustom(_ payedTimeInterval: TimeInterval) -> FirebaseFine {
                .init(id: id, assoiatedPersonId: assoiatedPersonId, date: date, payed: .payed(date: Date(timeIntervalSinceReferenceDate: payedTimeInterval), inApp: false), number: 10, fineReason: reasonCustom)
        }
    }

    /// Propertries for the first test late payment interest
    struct TestLatePaymentInterestFirst {

        /// Interest free period
        let interestFreePeriod = LatePaymentInterest.TimePeriod(value: 2, unit: .day)

        /// Interest rate
        let interestRate = 0.05

        /// Interest Period
        let interestPeriod = LatePaymentInterest.TimePeriod(value: 1, unit: .month)

        /// Compound interest
        let compuondInterest = false

        /// Late payment interest
        var latePaymentInterest: LatePaymentInterest {
            .init(interestFreePeriod: interestFreePeriod, interestRate: interestRate, interestPeriod: interestPeriod, compoundInterest: compuondInterest)
        }
    }

    /// Propertries for the second test late payment interest
    struct TestLatePaymentInterestSecond {

        /// Interest free period
        let interestFreePeriod = LatePaymentInterest.TimePeriod(value: 5, unit: .month)

        /// Interest rate
        let interestRate = 0.25

        /// Interest Period
        let interestPeriod = LatePaymentInterest.TimePeriod(value: 2, unit: .year)

        /// Compound interest
        let compuondInterest = true

        /// Late payment interest
        var latePaymentInterest: LatePaymentInterest {
            .init(interestFreePeriod: interestFreePeriod, interestRate: interestRate, interestPeriod: interestPeriod, compoundInterest: compuondInterest)
        }
    }

    /// Properties for the test club
    let testClub = TestClub()

    /// Properties for the first test person
    let testPersonFirst = TestPersonFirst()

    /// Properties for the second test person
    let testPersonSecond = TestPersonSecond()

    /// Properties for the third test person
    let testPersonThird = TestPersonThird()

    /// Properties for reason
    let testReason = TestReason()

    /// Properties for test fine
    let testFine = TestFine()

    /// Properties for test fine
    let testFine2 = TestFine2()

    /// Propertries for the first test late payment interest
    let testLatePaymentInterestFirst = TestLatePaymentInterestFirst()

    /// Propertries for the second test late payment interest
    let testLatePaymentInterestSecond = TestLatePaymentInterestSecond()
}
