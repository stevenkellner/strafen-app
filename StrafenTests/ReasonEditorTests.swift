//
//  ReasonEditorTests.swift
//  StrafenTests
//
//  Created by Steven on 18.06.21.
//

import XCTest
import SwiftUI
import FirebaseFunctions
import FirebaseAuth
@testable import Strafen

class ReasonEditorTests: XCTestCase {
    let clubId = Club.ID(rawValue: UUID(uuidString: "98d63ed5-f1bc-4a7b-898c-850c88f54765")!)

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

    /// Test delete reason used
    func testDeleteReasonUsed() async {
        var inputProperties = ReasonEditor.InputProperties()
        let inputBinding = Binding<ReasonEditor.InputProperties> { inputProperties} set: { inputProperties = $0 }
        let reasonId = FirebaseReasonTemplate.ID(rawValue: UUID(uuidString: "062FB0CB-F730-497B-BCF5-A4F907A6DCD5")!)
        await ReasonEditor.handleReasonDelete(clubId: clubId, reasonId: reasonId, fineList: TestClub.fetcherTestClub.fines, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionStateDelete, .failed)
        XCTAssertEqual(inputProperties.connectionStateUpdate, .notStarted)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertEqual(inputProperties.functionCallErrorMessage, .reasonUndeletable)
    }

    /// Test delete
    func testDelete() async throws {
        var inputProperties = ReasonEditor.InputProperties()
        let inputBinding = Binding<ReasonEditor.InputProperties> { inputProperties} set: { inputProperties = $0 }
        let reasonId = FirebaseReasonTemplate.ID(rawValue: UUID(uuidString: "16805D21-5E8D-43E9-BB5C-7B4A790F0CE7")!)
        await ReasonEditor.handleReasonDelete(clubId: clubId, reasonId: reasonId, fineList: TestClub.fetcherTestClub.fines, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionStateDelete, .passed)
        XCTAssertEqual(inputProperties.connectionStateUpdate, .notStarted)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertNil(inputProperties.functionCallErrorMessage)

        let reasonList: [FirebaseReasonTemplate] = try await FirebaseFetcher.shared.fetchList(clubId: clubId)
        let reason = reasonList.first { $0.id == reasonId }
        XCTAssertNil(reason)
    }

    /// Test empty reason
    func testUpdateEmptyReason() async {
        var inputProperties = ReasonEditor.InputProperties()
        inputProperties.inputProperties = [.amount: "12,50"]
        let inputBinding = Binding<ReasonEditor.InputProperties> { inputProperties} set: { inputProperties = $0 }
        let reasonId = FirebaseReasonTemplate.ID(rawValue: UUID(uuidString: "16805D21-5E8D-43E9-BB5C-7B4A790F0CE7")!)
        await ReasonEditor.handleReasonUpdate(clubId: clubId, reasonId: reasonId, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionStateDelete, .notStarted)
        XCTAssertEqual(inputProperties.connectionStateUpdate, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.reason: .emptyField])
        XCTAssertNil(inputProperties.functionCallErrorMessage)
    }

    /// Test empty amount
    func testUpdateEmptyAmount() async {
        var inputProperties = ReasonEditor.InputProperties()
        inputProperties.inputProperties = [.reason: "reason"]
        let inputBinding = Binding<ReasonEditor.InputProperties> { inputProperties} set: { inputProperties = $0 }
        let reasonId = FirebaseReasonTemplate.ID(rawValue: UUID(uuidString: "16805D21-5E8D-43E9-BB5C-7B4A790F0CE7")!)
        await ReasonEditor.handleReasonUpdate(clubId: clubId, reasonId: reasonId, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionStateDelete, .notStarted)
        XCTAssertEqual(inputProperties.connectionStateUpdate, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.amount: .emptyField])
        XCTAssertNil(inputProperties.functionCallErrorMessage)
    }

    /// Test amount zero
    func testUpdateAmountZero() async {
        var inputProperties = ReasonEditor.InputProperties()
        inputProperties.inputProperties = [.reason: "reason", .amount: "0"]
        let inputBinding = Binding<ReasonEditor.InputProperties> { inputProperties} set: { inputProperties = $0 }
        let reasonId = FirebaseReasonTemplate.ID(rawValue: UUID(uuidString: "16805D21-5E8D-43E9-BB5C-7B4A790F0CE7")!)
        await ReasonEditor.handleReasonUpdate(clubId: clubId, reasonId: reasonId, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionStateDelete, .notStarted)
        XCTAssertEqual(inputProperties.connectionStateUpdate, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.amount: .amountZero])
        XCTAssertNil(inputProperties.functionCallErrorMessage)
    }

    /// Test update
    func testUpdate() async throws {
        var inputProperties = ReasonEditor.InputProperties()
        inputProperties.inputProperties = [.reason: "reason-1-1", .amount: "12,01"]
        inputProperties.importance = .high
        let inputBinding = Binding<ReasonEditor.InputProperties> { inputProperties} set: { inputProperties = $0 }
        let reasonId = FirebaseReasonTemplate.ID(rawValue: UUID(uuidString: "16805D21-5E8D-43E9-BB5C-7B4A790F0CE7")!)
        await ReasonEditor.handleReasonUpdate(clubId: clubId, reasonId: reasonId, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionStateDelete, .notStarted)
        XCTAssertEqual(inputProperties.connectionStateUpdate, .passed)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertNil(inputProperties.functionCallErrorMessage)

        let reasonList: [FirebaseReasonTemplate] = try await FirebaseFetcher.shared.fetchList(clubId: clubId)
        let reason = reasonList.first { $0.id == reasonId }
        XCTAssertNotNil(reason)
        XCTAssertEqual(reason?.reason, "reason-1-1")
        XCTAssertEqual(reason?.importance, .high)
        XCTAssertEqual(reason?.amount, Amount(12, subUnit: 1))
    }
}
