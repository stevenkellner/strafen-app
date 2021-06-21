//
//  AddNewFineTests.swift
//  StrafenTests
//
//  Created by Steven on 21.06.21.
//

import XCTest
import SwiftUI
import FirebaseFunctions
import FirebaseAuth
@testable import Strafen

class AddNewFineTests: XCTestCase {
    let clubId = Club.ID(rawValue: UUID(uuidString: "34d63ed5-f1bc-4a7b-898c-850c88f54765")!)

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

    /// Test empty person ids
    func testEmptyPersonIds() async {
        var inputProperties = AddNewFine.InputProperties()
        inputProperties.personIds = []
        inputProperties.fineReason = FineReasonTemplate(templateId: FirebaseReasonTemplate.ID(rawValue: UUID(uuidString: "062FB0CB-F730-497B-BCF5-A4F907A6DCD5")!))
        inputProperties.number = 1
        inputProperties.date = Date()
        let inputBinding = Binding<AddNewFine.InputProperties> { inputProperties} set: { inputProperties = $0 }
        await AddNewFine.handleFinesSave(clubId: clubId, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.personIdErrorMessage, .noPersonSelected)
        XCTAssertNil(inputProperties.fineReasonErrorMessage)
        XCTAssertNil(inputProperties.dateErrorMessage)
        XCTAssertNil(inputProperties.numberErrorMessage)
        XCTAssertNil(inputProperties.functionCallErrorMessage)
    }

    /// Test no fine reason
    func testNoFineReason() async {
        var inputProperties = AddNewFine.InputProperties()
        inputProperties.personIds = [FirebasePerson.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!)]
        inputProperties.fineReason = nil
        inputProperties.number = 1
        inputProperties.date = Date()
        let inputBinding = Binding<AddNewFine.InputProperties> { inputProperties} set: { inputProperties = $0 }
        await AddNewFine.handleFinesSave(clubId: clubId, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.fineReasonErrorMessage, .noReasonGiven)
        XCTAssertNil(inputProperties.personIdErrorMessage)
        XCTAssertNil(inputProperties.dateErrorMessage)
        XCTAssertNil(inputProperties.numberErrorMessage)
        XCTAssertNil(inputProperties.functionCallErrorMessage)
    }

    /// Test future date
    func testFutureDate() async {
        var inputProperties = AddNewFine.InputProperties()
        inputProperties.personIds = [FirebasePerson.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!)]
        inputProperties.fineReason = FineReasonTemplate(templateId: FirebaseReasonTemplate.ID(rawValue: UUID(uuidString: "062FB0CB-F730-497B-BCF5-A4F907A6DCD5")!))
        inputProperties.number = 1
        inputProperties.date = .distantFuture
        let inputBinding = Binding<AddNewFine.InputProperties> { inputProperties} set: { inputProperties = $0 }
        await AddNewFine.handleFinesSave(clubId: clubId, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.dateErrorMessage, .futureDate)
        XCTAssertNil(inputProperties.personIdErrorMessage)
        XCTAssertNil(inputProperties.fineReasonErrorMessage)
        XCTAssertNil(inputProperties.numberErrorMessage)
        XCTAssertNil(inputProperties.functionCallErrorMessage)
    }

    /// Test number too low
    func testNumberTooLow() async {
        var inputProperties = AddNewFine.InputProperties()
        inputProperties.personIds = [FirebasePerson.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!)]
        inputProperties.fineReason = FineReasonTemplate(templateId: FirebaseReasonTemplate.ID(rawValue: UUID(uuidString: "062FB0CB-F730-497B-BCF5-A4F907A6DCD5")!))
        inputProperties.number = 0
        inputProperties.date = Date()
        let inputBinding = Binding<AddNewFine.InputProperties> { inputProperties} set: { inputProperties = $0 }
        await AddNewFine.handleFinesSave(clubId: clubId, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.numberErrorMessage, .invalidNumberRange)
        XCTAssertNil(inputProperties.personIdErrorMessage)
        XCTAssertNil(inputProperties.fineReasonErrorMessage)
        XCTAssertNil(inputProperties.dateErrorMessage)
        XCTAssertNil(inputProperties.functionCallErrorMessage)
    }

    /// Test number too high
    func testNumberTooHigh() async {
        var inputProperties = AddNewFine.InputProperties()
        inputProperties.personIds = [FirebasePerson.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!)]
        inputProperties.fineReason = FineReasonTemplate(templateId: FirebaseReasonTemplate.ID(rawValue: UUID(uuidString: "062FB0CB-F730-497B-BCF5-A4F907A6DCD5")!))
        inputProperties.number = 101
        inputProperties.date = Date()
        let inputBinding = Binding<AddNewFine.InputProperties> { inputProperties} set: { inputProperties = $0 }
        await AddNewFine.handleFinesSave(clubId: clubId, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.numberErrorMessage, .invalidNumberRange)
        XCTAssertNil(inputProperties.personIdErrorMessage)
        XCTAssertNil(inputProperties.fineReasonErrorMessage)
        XCTAssertNil(inputProperties.dateErrorMessage)
        XCTAssertNil(inputProperties.functionCallErrorMessage)
    }

    /// Test single person id
    func testSinglePersonId() async throws {
        var inputProperties = AddNewFine.InputProperties()
        let personIds = [FirebasePerson.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!)]
        let fineReason = FineReasonTemplate(templateId: FirebaseReasonTemplate.ID(rawValue: UUID(uuidString: "062FB0CB-F730-497B-BCF5-A4F907A6DCD5")!))
        inputProperties.personIds = personIds
        inputProperties.fineReason = fineReason
        inputProperties.number = 4
        inputProperties.date = Date()
        let inputBinding = Binding<AddNewFine.InputProperties> { inputProperties} set: { inputProperties = $0 }
        let fineIds = await AddNewFine.handleFinesSave(clubId: clubId, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .passed)
        XCTAssertNil(inputProperties.numberErrorMessage)
        XCTAssertNil(inputProperties.personIdErrorMessage)
        XCTAssertNil(inputProperties.fineReasonErrorMessage)
        XCTAssertNil(inputProperties.dateErrorMessage)
        XCTAssertNil(inputProperties.functionCallErrorMessage)

        XCTAssertEqual(fineIds?.count, 1)
        let fineList: [FirebaseFine] = try await FirebaseFetcher.shared.fetchList(clubId: clubId)
        let fine = fineList.first { $0.id == fineIds!.first! }
        XCTAssertNotNil(fine)
        XCTAssertEqual(fine?.number, 4)
        XCTAssertEqual(fine?.assoiatedPersonId, personIds.first!)
        XCTAssertEqual(fine?.fineReason as? FineReasonTemplate, fineReason)
        XCTAssertEqual(fine?.payed, .unpayed)
    }

    /// Test multiple person id
    func testMultiplePersonId() async throws {
        var inputProperties = AddNewFine.InputProperties()
        var personIds = [FirebasePerson.ID(rawValue: UUID(uuidString: "7BB9AB2B-8516-4847-8B5F-1A94B78EC7B7")!),
                         FirebasePerson.ID(rawValue: UUID(uuidString: "76025DDE-6893-46D2-BC34-9864BB5B8DAD")!),
                         FirebasePerson.ID(rawValue: UUID(uuidString: "D1852AC0-A0E2-4091-AC7E-CB2C23F708D9")!)]
        let fineReason = FineReasonCustom(reason: "aadfnb", amount: Amount(5, subUnit: 98), importance: .low)
        inputProperties.personIds = personIds
        inputProperties.fineReason = fineReason
        inputProperties.number = 5
        inputProperties.date = Date()
        let inputBinding = Binding<AddNewFine.InputProperties> { inputProperties} set: { inputProperties = $0 }
        let fineIds = await AddNewFine.handleFinesSave(clubId: clubId, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .passed)
        XCTAssertNil(inputProperties.numberErrorMessage)
        XCTAssertNil(inputProperties.personIdErrorMessage)
        XCTAssertNil(inputProperties.fineReasonErrorMessage)
        XCTAssertNil(inputProperties.dateErrorMessage)
        XCTAssertNil(inputProperties.functionCallErrorMessage)

        XCTAssertEqual(fineIds?.count, 3)
        let fineList: [FirebaseFine] = try await FirebaseFetcher.shared.fetchList(clubId: clubId)
        for fineId in fineIds! {
            let fine = fineList.first { $0.id == fineId }
            XCTAssertNotNil(fine)
            XCTAssertTrue(personIds.contains(fine!.assoiatedPersonId))
            personIds.removeAll { $0 == fine!.assoiatedPersonId }
            XCTAssertEqual(fine?.number, 5)
            XCTAssertEqual(fine?.fineReason as? FineReasonCustom, fineReason)
            XCTAssertEqual(fine?.payed, .unpayed)
        }
        XCTAssertEqual(personIds, [])
    }
}
