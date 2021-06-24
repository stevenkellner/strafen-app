//
//  SettingsLatePaymentInterestChangerTests.swift
//  StrafenTests
//
//  Created by Steven on 22.06.21.
//

import XCTest
import SwiftUI
import FirebaseFunctions
import FirebaseAuth
@testable import Strafen

class SettingsLatePaymentInterestChangerTests: XCTestCase {
    let clubId = Club.ID(rawValue: UUID(uuidString: "73d63ed5-f1bc-4a7b-898c-850c88f54765")!)

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

    /// Test interest free period empty value
    func testInterestFreePeriodEmptyValue() async {
        var inputProperties = SettingsLatePaymentInterestChanger.InputProperties()
        inputProperties.interestsActive = true
        inputProperties.interestFreePeriod.unit = .year
        inputProperties.interestPeriod.unit = .day
        inputProperties.inputProperties = [.interestRate: "0.05", .interestPeriod: "2"]
        let inputBinding = Binding<SettingsLatePaymentInterestChanger.InputProperties> { inputProperties } set: { inputProperties = $0 }
        await SettingsLatePaymentInterestChanger.handleSave(clubId: clubId, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertEqual(inputProperties.connectionState, .passed)
        XCTAssertNil(inputProperties.functionCallErrorMessage)
    }

    /// Test interest period value zero
    func testInterestPeriodEmptyValue() async {
        var inputProperties = SettingsLatePaymentInterestChanger.InputProperties()
        inputProperties.interestsActive = true
        inputProperties.interestFreePeriod.unit = .year
        inputProperties.interestPeriod.unit = .day
        inputProperties.inputProperties = [.interestRate: "0.05", .interestFreePeriod: "2"]
        let inputBinding = Binding<SettingsLatePaymentInterestChanger.InputProperties> { inputProperties } set: { inputProperties = $0 }
        await SettingsLatePaymentInterestChanger.handleSave(clubId: clubId, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.errorMessages, [.interestPeriod: .periodIsZero])
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertNil(inputProperties.functionCallErrorMessage)
    }

    /// Test interest period value zero
    func testInterestPeriodValueZero() async {
        var inputProperties = SettingsLatePaymentInterestChanger.InputProperties()
        inputProperties.interestsActive = true
        inputProperties.interestFreePeriod.unit = .year
        inputProperties.interestPeriod.unit = .day
        inputProperties.inputProperties = [.interestRate: "0.05", .interestFreePeriod: "2", .interestPeriod: "0"]
        let inputBinding = Binding<SettingsLatePaymentInterestChanger.InputProperties> { inputProperties } set: { inputProperties = $0 }
        await SettingsLatePaymentInterestChanger.handleSave(clubId: clubId, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.errorMessages, [.interestPeriod: .periodIsZero])
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertNil(inputProperties.functionCallErrorMessage)
    }

    /// Test interest rate empty
    func testInterestRateEmpty() async {
        var inputProperties = SettingsLatePaymentInterestChanger.InputProperties()
        inputProperties.interestsActive = true
        inputProperties.interestFreePeriod.unit = .year
        inputProperties.interestPeriod.unit = .day
        inputProperties.inputProperties = [.interestFreePeriod: "2", .interestPeriod: "3"]
        let inputBinding = Binding<SettingsLatePaymentInterestChanger.InputProperties> { inputProperties } set: { inputProperties = $0 }
        await SettingsLatePaymentInterestChanger.handleSave(clubId: clubId, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.errorMessages, [.interestRate: .rateIsZero])
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertNil(inputProperties.functionCallErrorMessage)
    }

    /// Test interest rate zero
    func testInterestRateZero() async {
        var inputProperties = SettingsLatePaymentInterestChanger.InputProperties()
        inputProperties.interestsActive = true
        inputProperties.interestFreePeriod.unit = .year
        inputProperties.interestPeriod.unit = .day
        inputProperties.inputProperties = [.interestRate: "0", .interestFreePeriod: "2", .interestPeriod: "3"]
        let inputBinding = Binding<SettingsLatePaymentInterestChanger.InputProperties> { inputProperties } set: { inputProperties = $0 }
        await SettingsLatePaymentInterestChanger.handleSave(clubId: clubId, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.errorMessages, [.interestRate: .rateIsZero])
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertNil(inputProperties.functionCallErrorMessage)
    }

    /// Test interest not active with error message
    func testRemoveInterest() async throws {

        // Set late payment interest
        let latePaymentInterest1 = LatePaymentInterest(interestFreePeriod: LatePaymentInterest.TimePeriod(value: 1, unit: .day), interestRate: 0.2, interestPeriod: LatePaymentInterest.TimePeriod(value: 2, unit: .month), compoundInterest: false)
        let callItem = FFChangeLatePaymentInterestCall(clubId: clubId, interest: latePaymentInterest1)
        try await FirebaseFunctionCaller.shared.call(callItem)

        // Check late payment interest
        let latePaymentInterest2: LatePaymentInterest? = try await FirebaseFetcher.shared.fetch(path: "latePaymentInterest", clubId: clubId)
        XCTAssertEqual(latePaymentInterest1, latePaymentInterest2)

        // Test remove interest
        var inputProperties = SettingsLatePaymentInterestChanger.InputProperties()
        inputProperties.interestsActive = false
        inputProperties.interestFreePeriod.unit = .year
        inputProperties.interestPeriod.unit = .day
        inputProperties.inputProperties = [.interestRate: "0", .interestFreePeriod: "2", .interestPeriod: "3"]
        let inputBinding = Binding<SettingsLatePaymentInterestChanger.InputProperties> { inputProperties } set: { inputProperties = $0 }
        await SettingsLatePaymentInterestChanger.handleSave(clubId: clubId, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertEqual(inputProperties.connectionState, .passed)
        XCTAssertNil(inputProperties.functionCallErrorMessage)

        // Check removed interest
        do {
            let _: LatePaymentInterest? = try await FirebaseFetcher.shared.fetch(path: "latePaymentInterest", clubId: clubId)
            XCTFail() // swiftlint:disable:this xctfail_message
        } catch {
            XCTAssertEqual(error as? FirebaseFetcher.FetchError, .noData)
        }
    }

    /// Test update interest
    func testUpdateInterest() async throws {
        var inputProperties = SettingsLatePaymentInterestChanger.InputProperties()
        inputProperties.interestsActive = true
        inputProperties.compoundInterest = true
        inputProperties.interestFreePeriod.unit = .year
        inputProperties.interestPeriod.unit = .day
        inputProperties.inputProperties = [.interestRate: "22", .interestFreePeriod: "2", .interestPeriod: "3"]
        let inputBinding = Binding<SettingsLatePaymentInterestChanger.InputProperties> { inputProperties } set: { inputProperties = $0 }
        await SettingsLatePaymentInterestChanger.handleSave(clubId: clubId, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertEqual(inputProperties.connectionState, .passed)
        XCTAssertNil(inputProperties.functionCallErrorMessage)

        let latePaymentInterest: LatePaymentInterest? = try await FirebaseFetcher.shared.fetch(path: "latePaymentInterest", clubId: clubId)
        XCTAssertNotNil(latePaymentInterest)
        XCTAssertEqual(latePaymentInterest?.interestRate, 0.22)
        XCTAssertEqual(latePaymentInterest?.interestFreePeriod, LatePaymentInterest.TimePeriod(value: 2, unit: .year))
        XCTAssertEqual(latePaymentInterest?.interestPeriod, LatePaymentInterest.TimePeriod(value: 3, unit: .day))
        XCTAssertEqual(latePaymentInterest?.compoundInterest, true)
    }
}
