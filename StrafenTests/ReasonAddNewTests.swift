//
//  ReasonAddNewTests.swift
//  StrafenTests
//
//  Created by Steven on 17.06.21.
//

import XCTest
import SwiftUI
import FirebaseFunctions
import FirebaseAuth
@testable import Strafen

class ReasonAddNewTests: XCTestCase {
    let clubId = Club.ID(rawValue: UUID(uuidString: "44d63ed5-f1bc-4a7b-898c-850c88f54765")!)

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

    /// Test empty reason
    func testSaveEmptyReason() async {
        var inputProperties = ReasonAddNew.InputProperties()
        inputProperties.inputProperties = [.amount: "12,50"]
        let inputBinding = Binding<ReasonAddNew.InputProperties> { inputProperties} set: { inputProperties = $0 }
        await ReasonAddNew.handleReasonSave(clubId: clubId, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.reason: .emptyField])
        XCTAssertNil(inputProperties.functionCallErrorMessage)
    }

    /// Test empty amount
    func testSaveEmptyAmount() async {
        var inputProperties = ReasonAddNew.InputProperties()
        inputProperties.inputProperties = [.reason: "reason"]
        let inputBinding = Binding<ReasonAddNew.InputProperties> { inputProperties} set: { inputProperties = $0 }
        await ReasonAddNew.handleReasonSave(clubId: clubId, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.amount: .emptyField])
        XCTAssertNil(inputProperties.functionCallErrorMessage)
    }

    /// Test amount zero
    func testSaveAmountZero() async {
        var inputProperties = ReasonAddNew.InputProperties()
        inputProperties.inputProperties = [.reason: "reason", .amount: "0"]
        let inputBinding = Binding<ReasonAddNew.InputProperties> { inputProperties} set: { inputProperties = $0 }
        await ReasonAddNew.handleReasonSave(clubId: clubId, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.amount: .amountZero])
        XCTAssertNil(inputProperties.functionCallErrorMessage)
    }

    /// Test save
    func testSave() async throws {
        var inputProperties = ReasonAddNew.InputProperties()
        inputProperties.inputProperties = [.reason: "reason-23", .amount: "60,89"]
        inputProperties.importance = .low
        let inputBinding = Binding<ReasonAddNew.InputProperties> { inputProperties} set: { inputProperties = $0 }
        let reasonId = await ReasonAddNew.handleReasonSave(clubId: clubId, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .passed)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertNil(inputProperties.functionCallErrorMessage)
        XCTAssertNotNil(reasonId)

        let reasonList: [FirebaseReasonTemplate] = try await FirebaseFetcher.shared.fetchList(clubId: clubId)
        let reason = reasonList.first { $0.id == reasonId }
        XCTAssertNotNil(reason)
        XCTAssertEqual(reason?.reason, "reason-23")
        XCTAssertEqual(reason?.amount, Amount(60, subUnit: 89))
        XCTAssertEqual(reason?.importance, .low)
    }
}
