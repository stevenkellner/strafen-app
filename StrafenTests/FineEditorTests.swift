//
//  FineEditorTests.swift
//  StrafenTests
//
//  Created by Steven on 31.05.21.
//

import XCTest
import SwiftUI
import FirebaseFunctions
import FirebaseAuth
@testable import Strafen

class FineEditorTests: XCTestCase {

    let clubId = Club.ID(rawValue: UUID(uuidString: "65d13ed5-f1bc-4a7b-898c-850c88f54765")!)

    @MainActor override func setUpWithError() throws {
        continueAfterFailure = false
        FirebaseFetcher.shared.level = .testing
        FirebaseFunctionCaller.shared.level = .testing

        waitExpectation { handler in
            async {

                // Sign test user in
                try await Auth.auth().signIn(withEmail: "app.demo@web.de", password: "Demopw12")

                let callItem = FFNewTestClubCall(clubId: clubId, testClubType: .fetcherTestClub)
                try await FirebaseFunctionCaller.shared.call(callItem)

                handler()
            }
        }
        try Task.checkCancellation()
    }

    override func tearDownWithError() throws {
        waitExpectation { handler in
            async {
                let callItem = FFDeleteTestClubCall(clubId: clubId)
                try await FirebaseFunctionCaller.shared.call(callItem)
                handler()
            }
        }
        try Task.checkCancellation()
    }

    /// Tests update with future date
    func testUpdateFutureDate() async {
        let personId = TestClub.fetcherTestClub.persons.first { $0.signInData != nil }!.id
        let settingsClub = Club(id: clubId, name: "ClubName", identifier: "ClubIdentifier", regionCode: "DE", inAppPaymentActive: true)
        let settingsPerson = Settings.Person(club: settingsClub, id: personId, name: PersonName(firstName: "FirstName"), signInDate: Date(), isCashier: true)
        var inputProperties = FineEditor.InputProperties()
        let fineId = FirebaseFine.ID(rawValue: UUID())
        let date = Date(timeIntervalSinceNow: 100000)
        let fineReason = FineReasonTemplate(templateId: TestClub.fetcherTestClub.reasons.first!.id)
        let fine = FirebaseFine(id: fineId, assoiatedPersonId: personId, date: date, payed: .unpayed, number: 1, fineReason: fineReason)
        inputProperties.setProperties(of: fine, with: TestClub.fetcherTestClub.reasons)
        let inputBinding = Binding<FineEditor.InputProperties> { inputProperties} set: { inputProperties = $0 }
        await FineEditor.handleFineUpdate(person: settingsPerson, inputProperties: inputBinding, reasonList: TestClub.fetcherTestClub.reasons)
        XCTAssertEqual(inputProperties.connectionStateDelete, .notStarted)
        XCTAssertEqual(inputProperties.connectionStateUpdate, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertNil(inputProperties.functionCallErrorMessage)
        XCTAssertNil(inputProperties.numberErrorMessages)
        XCTAssertEqual(inputProperties.dateErrorMessages, .futureDate)
    }

    /// Tests update with too small number
    func testUpdateNumberTooSmall() async {
        let personId = TestClub.fetcherTestClub.persons.first { $0.signInData != nil }!.id
        let settingsClub = Club(id: clubId, name: "ClubName", identifier: "ClubIdentifier", regionCode: "DE", inAppPaymentActive: true)
        let settingsPerson = Settings.Person(club: settingsClub, id: personId, name: PersonName(firstName: "FirstName"), signInDate: Date(), isCashier: true)
        var inputProperties = FineEditor.InputProperties()
        let fineId = FirebaseFine.ID(rawValue: UUID())
        let date = Date(timeIntervalSinceReferenceDate: 100000)
        let fineReason = FineReasonTemplate(templateId: TestClub.fetcherTestClub.reasons.first!.id)
        let fine = FirebaseFine(id: fineId, assoiatedPersonId: personId, date: date, payed: .unpayed, number: -1, fineReason: fineReason)
        inputProperties.setProperties(of: fine, with: TestClub.fetcherTestClub.reasons)
        let inputBinding = Binding<FineEditor.InputProperties> { inputProperties} set: { inputProperties = $0 }
        await FineEditor.handleFineUpdate(person: settingsPerson, inputProperties: inputBinding, reasonList: TestClub.fetcherTestClub.reasons)
        XCTAssertEqual(inputProperties.connectionStateDelete, .notStarted)
        XCTAssertEqual(inputProperties.connectionStateUpdate, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertNil(inputProperties.functionCallErrorMessage)
        XCTAssertNil(inputProperties.dateErrorMessages)
        XCTAssertEqual(inputProperties.numberErrorMessages, .invalidNumberRange)
    }

    /// Tests update with too large number
    func testUpdateNumberTooLarge() async {
        let personId = TestClub.fetcherTestClub.persons.first { $0.signInData != nil }!.id
        let settingsClub = Club(id: clubId, name: "ClubName", identifier: "ClubIdentifier", regionCode: "DE", inAppPaymentActive: true)
        let settingsPerson = Settings.Person(club: settingsClub, id: personId, name: PersonName(firstName: "FirstName"), signInDate: Date(), isCashier: true)
        var inputProperties = FineEditor.InputProperties()
        let fineId = FirebaseFine.ID(rawValue: UUID())
        let date = Date(timeIntervalSinceReferenceDate: 100000)
        let fineReason = FineReasonTemplate(templateId: TestClub.fetcherTestClub.reasons.first!.id)
        let fine = FirebaseFine(id: fineId, assoiatedPersonId: personId, date: date, payed: .unpayed, number: 120, fineReason: fineReason)
        inputProperties.setProperties(of: fine, with: TestClub.fetcherTestClub.reasons)
        let inputBinding = Binding<FineEditor.InputProperties> { inputProperties} set: { inputProperties = $0 }
        await FineEditor.handleFineUpdate(person: settingsPerson, inputProperties: inputBinding, reasonList: TestClub.fetcherTestClub.reasons)
        XCTAssertEqual(inputProperties.connectionStateDelete, .notStarted)
        XCTAssertEqual(inputProperties.connectionStateUpdate, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertNil(inputProperties.functionCallErrorMessage)
        XCTAssertNil(inputProperties.dateErrorMessages)
        XCTAssertEqual(inputProperties.numberErrorMessages, .invalidNumberRange)
    }

    /// Tests update with empty reason
    func testUpdateEmptyReason() async {
        let personId = TestClub.fetcherTestClub.persons.first { $0.signInData != nil }!.id
        let settingsClub = Club(id: clubId, name: "ClubName", identifier: "ClubIdentifier", regionCode: "DE", inAppPaymentActive: true)
        let settingsPerson = Settings.Person(club: settingsClub, id: personId, name: PersonName(firstName: "FirstName"), signInDate: Date(), isCashier: true)
        var inputProperties = FineEditor.InputProperties()
        let fineId = FirebaseFine.ID(rawValue: UUID())
        let date = Date(timeIntervalSinceReferenceDate: 100000)
        let fineReason = FineReasonTemplate(templateId: TestClub.fetcherTestClub.reasons.first!.id)
        let fine = FirebaseFine(id: fineId, assoiatedPersonId: personId, date: date, payed: .unpayed, number: 1, fineReason: fineReason)
        inputProperties.setProperties(of: fine, with: TestClub.fetcherTestClub.reasons)
        inputProperties[.reason] = ""
        let inputBinding = Binding<FineEditor.InputProperties> { inputProperties} set: { inputProperties = $0 }
        await FineEditor.handleFineUpdate(person: settingsPerson, inputProperties: inputBinding, reasonList: TestClub.fetcherTestClub.reasons)
        XCTAssertEqual(inputProperties.connectionStateDelete, .notStarted)
        XCTAssertEqual(inputProperties.connectionStateUpdate, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.reason: .emptyField])
        XCTAssertNil(inputProperties.functionCallErrorMessage)
        XCTAssertNil(inputProperties.dateErrorMessages)
        XCTAssertNil(inputProperties.numberErrorMessages)
    }

    /// Tests update with empty amount
    func testUpdateEmptyAmount() async {
        let personId = TestClub.fetcherTestClub.persons.first { $0.signInData != nil }!.id
        let settingsClub = Club(id: clubId, name: "ClubName", identifier: "ClubIdentifier", regionCode: "DE", inAppPaymentActive: true)
        let settingsPerson = Settings.Person(club: settingsClub, id: personId, name: PersonName(firstName: "FirstName"), signInDate: Date(), isCashier: true)
        var inputProperties = FineEditor.InputProperties()
        let fineId = FirebaseFine.ID(rawValue: UUID())
        let date = Date(timeIntervalSinceReferenceDate: 100000)
        let fineReason = FineReasonTemplate(templateId: TestClub.fetcherTestClub.reasons.first!.id)
        let fine = FirebaseFine(id: fineId, assoiatedPersonId: personId, date: date, payed: .unpayed, number: 1, fineReason: fineReason)
        inputProperties.setProperties(of: fine, with: TestClub.fetcherTestClub.reasons)
        inputProperties[.amount] = ""
        let inputBinding = Binding<FineEditor.InputProperties> { inputProperties} set: { inputProperties = $0 }
        await FineEditor.handleFineUpdate(person: settingsPerson, inputProperties: inputBinding, reasonList: TestClub.fetcherTestClub.reasons)
        XCTAssertEqual(inputProperties.connectionStateDelete, .notStarted)
        XCTAssertEqual(inputProperties.connectionStateUpdate, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.amount: .emptyField])
        XCTAssertNil(inputProperties.functionCallErrorMessage)
        XCTAssertNil(inputProperties.dateErrorMessages)
        XCTAssertNil(inputProperties.numberErrorMessages)
    }

    /// Tests update with amount zero
    func testUpdateAmountZero() async {
        let personId = TestClub.fetcherTestClub.persons.first { $0.signInData != nil }!.id
        let settingsClub = Club(id: clubId, name: "ClubName", identifier: "ClubIdentifier", regionCode: "DE", inAppPaymentActive: true)
        let settingsPerson = Settings.Person(club: settingsClub, id: personId, name: PersonName(firstName: "FirstName"), signInDate: Date(), isCashier: true)
        var inputProperties = FineEditor.InputProperties()
        let fineId = FirebaseFine.ID(rawValue: UUID())
        let date = Date(timeIntervalSinceReferenceDate: 100000)
        let fineReason = FineReasonTemplate(templateId: TestClub.fetcherTestClub.reasons.first!.id)
        let fine = FirebaseFine(id: fineId, assoiatedPersonId: personId, date: date, payed: .unpayed, number: 1, fineReason: fineReason)
        inputProperties.setProperties(of: fine, with: TestClub.fetcherTestClub.reasons)
        inputProperties[.amount] = "0"
        let inputBinding = Binding<FineEditor.InputProperties> { inputProperties} set: { inputProperties = $0 }
        await FineEditor.handleFineUpdate(person: settingsPerson, inputProperties: inputBinding, reasonList: TestClub.fetcherTestClub.reasons)
        XCTAssertEqual(inputProperties.connectionStateDelete, .notStarted)
        XCTAssertEqual(inputProperties.connectionStateUpdate, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.amount: .amountZero])
        XCTAssertNil(inputProperties.functionCallErrorMessage)
        XCTAssertNil(inputProperties.dateErrorMessages)
        XCTAssertNil(inputProperties.numberErrorMessages)
    }

    /// Tests update with same fine
    func testUpdateSameFine() async {
        let personId = TestClub.fetcherTestClub.persons.first { $0.signInData != nil }!.id
        let settingsClub = Club(id: clubId, name: "ClubName", identifier: "ClubIdentifier", regionCode: "DE", inAppPaymentActive: true)
        let settingsPerson = Settings.Person(club: settingsClub, id: personId, name: PersonName(firstName: "FirstName"), signInDate: Date(), isCashier: true)
        var inputProperties = FineEditor.InputProperties()
        let fineId = FirebaseFine.ID(rawValue: UUID())
        let date = Date(timeIntervalSinceReferenceDate: 100000)
        let fineReason = FineReasonTemplate(templateId: TestClub.fetcherTestClub.reasons.first!.id)
        let fine = FirebaseFine(id: fineId, assoiatedPersonId: personId, date: date, payed: .unpayed, number: 1, fineReason: fineReason)
        inputProperties.setProperties(of: fine, with: TestClub.fetcherTestClub.reasons)
        let inputBinding = Binding<FineEditor.InputProperties> { inputProperties} set: { inputProperties = $0 }
        await FineEditor.handleFineUpdate(person: settingsPerson, inputProperties: inputBinding, reasonList: TestClub.fetcherTestClub.reasons)
        XCTAssertEqual(inputProperties.connectionStateDelete, .notStarted)
        XCTAssertEqual(inputProperties.connectionStateUpdate, .passed)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertNil(inputProperties.functionCallErrorMessage)
        XCTAssertNil(inputProperties.dateErrorMessages)
        XCTAssertNil(inputProperties.numberErrorMessages)
    }

    /// Tests update
    func testUpdate() async throws {
        let personId = TestClub.fetcherTestClub.persons.first { $0.signInData != nil }!.id
        let settingsClub = Club(id: clubId, name: "ClubName", identifier: "ClubIdentifier", regionCode: "DE", inAppPaymentActive: true)
        let settingsPerson = Settings.Person(club: settingsClub, id: personId, name: PersonName(firstName: "FirstName"), signInDate: Date(), isCashier: true)
        var inputProperties = FineEditor.InputProperties()
        let fine = TestClub.fetcherTestClub.fines.first!
        inputProperties.setProperties(of: fine, with: TestClub.fetcherTestClub.reasons)
        inputProperties[.reason] = "Reason_1"
        inputProperties[.amount] = "10,21"
        inputProperties.date = Date(timeIntervalSinceReferenceDate: 497987)
        inputProperties.number = 8
        inputProperties.importance = .low
        let inputBinding = Binding<FineEditor.InputProperties> { inputProperties} set: { inputProperties = $0 }
        await FineEditor.handleFineUpdate(person: settingsPerson, inputProperties: inputBinding, reasonList: TestClub.fetcherTestClub.reasons)
        XCTAssertEqual(inputProperties.connectionStateDelete, .notStarted)
        XCTAssertEqual(inputProperties.connectionStateUpdate, .passed)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertNil(inputProperties.functionCallErrorMessage)
        XCTAssertNil(inputProperties.dateErrorMessages)
        XCTAssertNil(inputProperties.numberErrorMessages)

        let fineList = try await FirebaseFetcher.shared.fetchList(FirebaseFine.self, clubId: clubId)
        let fetchedFine = fineList.first { $0.id == fine.id }
        XCTAssertNotNil(fetchedFine)
        XCTAssertEqual(fetchedFine?.reason(with: TestClub.fetcherTestClub.reasons), "Reason_1")
        XCTAssertEqual(fetchedFine?.amount(with: TestClub.fetcherTestClub.reasons), Amount(10, subUnit: 21))
        XCTAssertEqual(fetchedFine?.importance(with: TestClub.fetcherTestClub.reasons), .low)
        XCTAssertEqual(fetchedFine?.date, inputProperties.date)
        XCTAssertEqual(fetchedFine?.number, 8)
    }

    /// Tests delete
    func testDelete() async throws {
        let personId = TestClub.fetcherTestClub.persons.first { $0.signInData != nil }!.id
        let settingsClub = Club(id: clubId, name: "ClubName", identifier: "ClubIdentifier", regionCode: "DE", inAppPaymentActive: true)
        let settingsPerson = Settings.Person(club: settingsClub, id: personId, name: PersonName(firstName: "FirstName"), signInDate: Date(), isCashier: true)
        let fine = TestClub.fetcherTestClub.fines.first!
        var inputProperties = FineEditor.InputProperties()
        let inputBinding = Binding<FineEditor.InputProperties> { inputProperties} set: { inputProperties = $0 }
        await FineEditor.handleFineDelete(fine: fine, person: settingsPerson, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionStateDelete, .passed)
        XCTAssertEqual(inputProperties.connectionStateUpdate, .notStarted)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertNil(inputProperties.functionCallErrorMessage)
        XCTAssertNil(inputProperties.dateErrorMessages)
        XCTAssertNil(inputProperties.numberErrorMessages)

        let fineList = try await FirebaseFetcher.shared.fetchList(FirebaseFine.self, clubId: clubId)
        let fetchedFine = fineList.first { $0.id == fine.id }
        XCTAssertNil(fetchedFine)
    }
}
