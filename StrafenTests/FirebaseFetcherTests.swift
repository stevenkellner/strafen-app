//
//  FirebaseFetcherTests.swift
//  StrafenTests
//
//  Created by Steven on 05.05.21.
//

import XCTest
@testable import Strafen

// swiftlint:disable identifier_name
class FirebaseFetcherTests: XCTestCase {

    let clubId = UUID(uuidString: "fb3f6718-8cc5-4d2e-aca1-398a15fc1be7")!

    // MARK: set up

    override func setUpWithError() throws {
        continueAfterFailure = false
        FirebaseFunctionCaller.shared.level = .testing
        FirebaseFetcher.shared.level = .testing

        // Delete old test club
        _setUpDeleteOldTestClub()

        // Create new test club
        _setUpCreateNewTestClub()

        // Check test club
        try _setUpCheckTestClub()
    }

    /// Set up: deletes old test club
    func _setUpDeleteOldTestClub() {
        waitExpectation { handler in
            let callItem = FFDeleteTestClubCall(clubId: clubId)
            FirebaseFunctionCaller.shared.call(callItem).thenResult { result in
                XCTAssertNoThrow { try result.get() }
                handler()
            }
        }
    }

    /// Set up: creates new test club
    func _setUpCreateNewTestClub() {
        waitExpectation { handler in
            let callItem = FFNewTestClubCall(clubId: clubId, testClubType: .fetcherTestClub)
            FirebaseFunctionCaller.shared.call(callItem).thenResult { result in
                XCTAssertNoThrow { try result.get() }
                handler()
            }
        }
    }

    /// Set up: Check test club
    func _setUpCheckTestClub() throws {
        let result: Result<TestClub, Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchClub(clubId).thenResult { result in
                handler(result)
            }
        }
        let club = try result.get()
        XCTAssertEqual(club, TestClub.fetcherTestClub)
    }

    // MARK: tear down

    override func tearDown() {

        // Delete created test club (same as delete old test club in setUp)
        _setUpDeleteOldTestClub()
    }

    // MARK: fetch list

    /// Test fetch list
    func testFetchList() throws {

        // Fetch person list
        try _testFetchListPerson()

        // Fetch fine list
        try _testFetchListFine()

        // Fetch reason list
        try _testFetchListReason()

        // Fetch transfer list
        try _testFetchListTransaction()

        // Fetch non existing list
        try _testFetchListNonExistsingList()

        // Fetch list with wrong type
        try _testFetchListListWrongType()
    }

    /// Test fetch list: fetch person list
    func _testFetchListPerson() throws {
        let result: Result<[FirebasePerson], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId).thenResult(handler)
        }
        let personList = try result.get().sorted { $0.id.uuidString < $1.id.uuidString }
        XCTAssertEqual(personList, TestClub.fetcherTestClub.persons)
    }

    /// Test fetch list: fetch fine list
    func _testFetchListFine() throws {
        let result: Result<[FirebaseFine], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebaseFine.self, clubId: clubId).thenResult(handler)
        }
        let fineList = try result.get().sorted { $0.id.uuidString < $1.id.uuidString }
        XCTAssertEqual(fineList, TestClub.fetcherTestClub.fines)
    }

    /// Test fetch list: fetch reason list
    func _testFetchListReason() throws {
        let result: Result<[FirebaseReasonTemplate], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebaseReasonTemplate.self, clubId: clubId).thenResult(handler)
        }
        let reasonList = try result.get().sorted { $0.id.uuidString < $1.id.uuidString }
        XCTAssertEqual(reasonList, TestClub.fetcherTestClub.reasons)
    }

    /// Test fetch list: fetch transaction list
    func _testFetchListTransaction() throws {
        let result: Result<[FirebaseTransaction], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebaseTransaction.self, clubId: clubId).thenResult(handler)
        }
        let transactionList = try result.get().sorted { $0.id < $1.id }
        XCTAssertEqual(transactionList, TestClub.fetcherTestClub.transactions)
    }

    /// Test fetch list: fetch non existing list
    func _testFetchListNonExistsingList() throws {

        // Delete person list
        waitExpectation { handler in
            let callItem = FFDeleteTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "persons")!)
            FirebaseFunctionCaller.shared.call(callItem).thenResult { result in
                XCTAssertNoThrow { try result.get() }
                handler()
            }
        }

        // Try fetch non existing person list
        let result: Result<[FirebasePerson], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId).thenResult(handler)
        }
        XCTAssertEqual(result.error as? FirebaseFetcher.FetchError, FirebaseFetcher.FetchError.noData)
    }

    /// Test fetch list: fetch list wrong type
    func _testFetchListListWrongType() throws {

        // Set non person list to person list
        waitExpectation { handler in
            let callItem = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "persons")!, property: ["id": ["test": "value"]])
            FirebaseFunctionCaller.shared.call(callItem).thenResult { result in
                XCTAssertNoThrow { try result.get() }
                handler()
            }
        }

        // Try fetch person list
        let result: Result<[FirebasePerson], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId).thenResult(handler)
        }
        XCTAssertTrue(result.error is FirebaseDecoder.DecodingError || result.error is DecodingError)
    }

    // MARK: fetch object

    /// Test fetch object
    func testFetchObject() throws {

        // Fetch primitive type
        try _testFetchObjectPrimitiveType()

        // Fetch non existing primitive type
        try _testFetchObjectNonExistingPrimitiveType()

        // Fetch primitive type with wrong type
        try _testFetchObjectWrongTypePrimitiveType()

        // Fetch object
        try _testFetchObjectObject()

        // Fetch non existing object
        try _testFetchObjectNonExistingObject()

        // Fetch object with wrong type
        try _testFetchObjectWrongTypeObject()
    }

    /// Test fetch object: fetch primitive type
    func _testFetchObjectPrimitiveType() throws {

        // Fetch string
        let stringResult: Result<String, Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetch(String.self, url: URL(string: "identifier")!, clubId: clubId).thenResult(handler)
        }
        let stringValue = try stringResult.get()
        XCTAssertEqual(stringValue, TestClub.fetcherTestClub.properties.identifier)

        // Fetch bool
        let boolResult: Result<Bool, Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetch(Bool.self, url: URL(string: "inAppPaymentActive")!, clubId: clubId).thenResult(handler)
        }
        let boolValue = try boolResult.get()
        XCTAssertEqual(boolValue, TestClub.fetcherTestClub.properties.inAppPaymentActive)

        // Fetch double
        let doubleResult: Result<Double, Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetch(Double.self, url: URL(string: "fines/02462A8B-107F-4BAE-A85B-EFF1F727C00F/date")!, clubId: clubId).thenResult(handler)
        }
        let doubleValue = try doubleResult.get()
        let fine = TestClub.fetcherTestClub.fines.first { $0.id.uuidString == "02462A8B-107F-4BAE-A85B-EFF1F727C00F" }
        XCTAssertNotNil(fine)
        XCTAssertEqual(doubleValue, fine!.date.timeIntervalSinceReferenceDate)
    }

    /// Test fetch object: fetch non existing primitive type
    func _testFetchObjectNonExistingPrimitiveType() throws {
        let result: Result<String, Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetch(String.self, url: URL(string: "nonExsisting")!, clubId: clubId).thenResult(handler)
        }
        XCTAssertEqual(result.error as? FirebaseFetcher.FetchError, FirebaseFetcher.FetchError.noData)
    }

    /// Test fetch object: fetch wrong type primitive type
    func _testFetchObjectWrongTypePrimitiveType() throws {

        // Try fetch bool as string
        let result1: Result<String, Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetch(String.self, url: URL(string: "inAppPaymentActive")!, clubId: clubId).thenResult(handler)
        }
        XCTAssertTrue(result1.error is FirebaseDecoder.DecodingError || result1.error is DecodingError)

        // Try fetch object as string
        let result2: Result<String, Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetch(String.self, url: URL(string: "fines/02462A8B-107F-4BAE-A85B-EFF1F727C00F")!, clubId: clubId).thenResult(handler)
        }
        XCTAssertTrue(result2.error is FirebaseDecoder.DecodingError || result2.error is DecodingError)
    }

    /// Test fetch object: fetch object
    func _testFetchObjectObject() throws {
        let result: Result<[String: String], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetch(Dictionary<String, String>.self, url: URL(string: "personUserIds")!, clubId: clubId).thenResult(handler)
        }
        let value = Dictionary(try result.get().sorted { $0.key < $1.key }) { first, _ in first }
        XCTAssertEqual(value, TestClub.fetcherTestClub.properties.personUserIds)
    }

    /// Test fetch object: fetch non existing object
    func _testFetchObjectNonExistingObject() throws {
        let result: Result<FirebasePerson, Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetch(FirebasePerson.self, url: URL(string: "nonExsisting")!, clubId: clubId).thenResult(handler)
        }
        XCTAssertEqual(result.error as? FirebaseFetcher.FetchError, FirebaseFetcher.FetchError.noData)
    }

    /// Test fetch object: fetch wrong type object
    func _testFetchObjectWrongTypeObject() throws {

        // Try fetch string as object
        let result1: Result<FirebasePerson, Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetch(FirebasePerson.self, url: URL(string: "identifier")!, clubId: clubId).thenResult(handler)
        }
        XCTAssertTrue(result1.error is FirebaseDecoder.DecodingError || result1.error is DecodingError)

        // Try fetch object as object
        let result2: Result<FirebasePerson, Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetch(FirebasePerson.self, url: URL(string: "fines/02462A8B-107F-4BAE-A85B-EFF1F727C00F")!, clubId: clubId).thenResult(handler)
        }
        XCTAssertTrue(result2.error is FirebaseDecoder.DecodingError || result2.error is DecodingError)
    }
}
