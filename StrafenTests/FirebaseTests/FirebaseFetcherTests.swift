//
//  FirebaseFetcherTests.swift
//  StrafenTests
//
//  Created by Steven on 05.05.21.
//

import XCTest
import FirebaseFunctions
import FirebaseAuth
@testable import Strafen

class FirebaseFetcherTests: XCTestCase {

    let clubId = Club.ID(rawValue: UUID(uuidString: "fb3f6718-8cc5-4d2e-aca1-398a15fc1be7")!)

    // MARK: set up

    @MainActor override func setUpWithError() throws {
        continueAfterFailure = false
        FirebaseFunctionCaller.shared.level = .testing
        FirebaseFetcher.shared.level = .testing

        waitExpectation(timeout: 60) { handler in
            async {

                // Sign test user in
                try await Auth.auth().signIn(withEmail: "app.demo@web.de", password: "Demopw12")

                // Delete old test club
                try await _setUpDeleteOldTestClub()

                // Create new test club
                try await _setUpCreateNewTestClub()

                // Check test club
                try await _setUpCheckTestClub()

                handler()
            }
        }
        try Task.checkCancellation()
    }

    /// Set up: deletes old test club
    func _setUpDeleteOldTestClub() async throws {
        let callItem = FFDeleteTestClubCall(clubId: clubId)
        try await FirebaseFunctionCaller.shared.call(callItem)
    }

    /// Set up: creates new test club
    func _setUpCreateNewTestClub() async throws {
        let callItem = FFNewTestClubCall(clubId: clubId, testClubType: .fetcherTestClub)
        try await FirebaseFunctionCaller.shared.call(callItem)
    }

    /// Set up: Check test club
    func _setUpCheckTestClub() async throws {
        let club = try await FirebaseFetcher.shared.fetchClub(clubId)
        XCTAssertEqual(club, TestClub.fetcherTestClub)
    }

    // MARK: tear down

    override func tearDownWithError() throws {

        // Delete created test club (same as delete old test club in setUp)
        waitExpectation { handler in
            async {
                try await _setUpDeleteOldTestClub()
                handler()
            }
        }
        try Task.checkCancellation()
    }

    // MARK: fetch list

    /// Test fetch list
    func testFetchList() async throws {

        // Fetch person list
        try await _testFetchListPerson()

        // Fetch fine list
        try await _testFetchListFine()

        // Fetch reason list
        try await _testFetchListReason()

        // Fetch transfer list
        try await _testFetchListTransaction()

        // Fetch non existing list
        try await _testFetchListNonExistsingList()

        // Fetch list with wrong type
        try await _testFetchListListWrongType()
    }

    /// Test fetch list: fetch person list
    func _testFetchListPerson() async throws {
        let personList = try await FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId).sorted { $0.id.uuidString < $1.id.uuidString }
        XCTAssertEqual(personList, TestClub.fetcherTestClub.persons)
    }

    /// Test fetch list: fetch fine list
    func _testFetchListFine() async throws {
        let fineList = try await FirebaseFetcher.shared.fetchList(FirebaseFine.self, clubId: clubId).sorted { $0.id.uuidString < $1.id.uuidString }
        XCTAssertEqual(fineList, TestClub.fetcherTestClub.fines)
    }

    /// Test fetch list: fetch reason list
    func _testFetchListReason() async throws {
        let reasonList = try await FirebaseFetcher.shared.fetchList(FirebaseReasonTemplate.self, clubId: clubId).sorted { $0.id.uuidString < $1.id.uuidString }
        XCTAssertEqual(reasonList, TestClub.fetcherTestClub.reasons)
    }

    /// Test fetch list: fetch transaction list
    func _testFetchListTransaction() async throws {
        let transactionList = try await FirebaseFetcher.shared.fetchList(FirebaseTransaction.self, clubId: clubId).sorted { $0.id < $1.id }
        XCTAssertEqual(transactionList, TestClub.fetcherTestClub.transactions)
    }

    /// Test fetch list: fetch non existing list
    func _testFetchListNonExistsingList() async throws {

        // Delete person list
        let callItem = FFDeleteTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "persons")!)
        try await FirebaseFunctionCaller.shared.call(callItem)

        // Try fetch non existing person list
        let personList = try await FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId).sorted { $0.id.uuidString < $1.id.uuidString }
        XCTAssertEqual(personList, [])
    }

    /// Test fetch list: fetch list wrong type
    func _testFetchListListWrongType() async throws {

        // Set non person list to person list
        let callItem = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "persons")!, property: ["id": ["test": "value"]])
        try await FirebaseFunctionCaller.shared.call(callItem)

        // Try fetch person list
        do {
            _ = try await FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId).sorted { $0.id.uuidString < $1.id.uuidString }
            XCTFail() // swiftlint:disable:this xctfail_message
        } catch {
            XCTAssertTrue(error is FirebaseDecoder.DecodingError || error is DecodingError)
        }
    }

    // MARK: fetch object

    /// Test fetch object
    func testFetchObject() async throws {

        // Fetch primitive type
        try await _testFetchObjectPrimitiveType()

        // Fetch non existing primitive type
        try await _testFetchObjectNonExistingPrimitiveType()

        // Fetch primitive type with wrong type
        try await _testFetchObjectWrongTypePrimitiveType()

        // Fetch object
        try await _testFetchObjectObject()

        // Fetch non existing object
        try await _testFetchObjectNonExistingObject()

        // Fetch object with wrong type
        try await _testFetchObjectWrongTypeObject()
    }

    /// Test fetch object: fetch primitive type
    func _testFetchObjectPrimitiveType() async throws {

        // Fetch string
        let stringValue = try await FirebaseFetcher.shared.fetch(String.self, url: URL(string: "identifier")!, clubId: clubId)
        XCTAssertEqual(stringValue, TestClub.fetcherTestClub.properties.identifier)

        // Fetch bool
        let boolValue = try await FirebaseFetcher.shared.fetch(Bool.self, url: URL(string: "inAppPaymentActive")!, clubId: clubId)
        XCTAssertEqual(boolValue, TestClub.fetcherTestClub.properties.inAppPaymentActive)

        // Fetch double
        let doubleValue = try await FirebaseFetcher.shared.fetch(Double.self, url: URL(string: "fines/02462A8B-107F-4BAE-A85B-EFF1F727C00F/date")!, clubId: clubId)
        let fine = TestClub.fetcherTestClub.fines.first { $0.id.uuidString == "02462A8B-107F-4BAE-A85B-EFF1F727C00F" }
        XCTAssertNotNil(fine)
        XCTAssertEqual(doubleValue, fine!.date.timeIntervalSinceReferenceDate)
    }

    /// Test fetch object: fetch non existing primitive type
    func _testFetchObjectNonExistingPrimitiveType() async throws {
        do {
            _ = try await FirebaseFetcher.shared.fetch(String.self, url: URL(string: "nonExsisting")!, clubId: clubId)
            XCTFail() // swiftlint:disable:this xctfail_message
        } catch {
            XCTAssertEqual(error as? FirebaseFetcher.FetchError, FirebaseFetcher.FetchError.noData)
        }
    }

    /// Test fetch object: fetch wrong type primitive type
    func _testFetchObjectWrongTypePrimitiveType() async throws {

        // Try fetch bool as string
        do {
            _ = try await FirebaseFetcher.shared.fetch(String.self, url: URL(string: "inAppPaymentActive")!, clubId: clubId)
            XCTFail() // swiftlint:disable:this xctfail_message
        } catch {
            XCTAssertTrue(error is FirebaseDecoder.DecodingError || error is DecodingError)
        }

        // Try fetch object as string
        do {
            _ = try await FirebaseFetcher.shared.fetch(String.self, url: URL(string: "fines/02462A8B-107F-4BAE-A85B-EFF1F727C00F")!, clubId: clubId)
            XCTFail() // swiftlint:disable:this xctfail_message
        } catch {
            XCTAssertTrue(error is FirebaseDecoder.DecodingError || error is DecodingError)
        }
    }

    /// Test fetch object: fetch object
    func _testFetchObjectObject() async throws {
        let result = try await FirebaseFetcher.shared.fetch(Dictionary<String, String>.self, url: URL(string: "personUserIds")!, clubId: clubId)
        let value = Dictionary(result.sorted { $0.key < $1.key }) { first, _ in first }
        XCTAssertEqual(value, TestClub.fetcherTestClub.properties.personUserIds)
    }

    /// Test fetch object: fetch non existing object
    func _testFetchObjectNonExistingObject() async throws {
        do {
            _ = try await FirebaseFetcher.shared.fetch(FirebasePerson.self, url: URL(string: "nonExsisting")!, clubId: clubId)
            XCTFail() // swiftlint:disable:this xctfail_message
        } catch {
            XCTAssertEqual(error as? FirebaseFetcher.FetchError, FirebaseFetcher.FetchError.noData)
        }
    }

    /// Test fetch object: fetch wrong type object
    func _testFetchObjectWrongTypeObject() async throws {

        // Try fetch string as object
        do {
            _ = try await FirebaseFetcher.shared.fetch(FirebasePerson.self, url: URL(string: "identifier")!, clubId: clubId)
            XCTFail() // swiftlint:disable:this xctfail_message
        } catch {
            XCTAssertTrue(error is FirebaseDecoder.DecodingError || error is DecodingError)
        }

        // Try fetch object as object
        do {
            _ = try await FirebaseFetcher.shared.fetch(FirebasePerson.self, url: URL(string: "fines/02462A8B-107F-4BAE-A85B-EFF1F727C00F")!, clubId: clubId)
            XCTFail() // swiftlint:disable:this xctfail_message
        } catch {
            XCTAssertTrue(error is FirebaseDecoder.DecodingError || error is DecodingError)
        }
    }
}
