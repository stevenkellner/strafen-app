//
//  Utils.swift
//  StrafenTests
//
//  Created by Steven on 05.05.21.
//

import XCTest
@testable import Strafen

extension XCTestCase {

    /// An error that occurs during waiting for tasks
    enum TimeoutError: Error {

        /// Data task expired error
        case dataTaskExpired
    }

    /// Wait for synchronous tasks
    /// - Parameters:
    ///   - timeout: time to wait for task
    ///   - description: expectation description
    ///   - handler: handles task return
    /// - Throws: TimeoutError or rethrowed error
    /// - Returns: return value of the task
    func waitExpectation<ReturnValue>(timeout: TimeInterval = 30, description: String = "expecation", _ handler: (@escaping (ReturnValue) -> Void) throws -> Void) throws -> ReturnValue {
        let expectation = self.expectation(description: description)
        var result: ReturnValue?
        try handler { value in
            if result == nil {
                result = value
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        guard let unwrappedResult = result else { throw TimeoutError.dataTaskExpired }
        return unwrappedResult
    }

    /// Wait for synchronous tasks
    /// - Parameters:
    ///   - timeout: time to wait for task
    ///   - description: expectation description
    ///   - handler: handles task return
    /// - Throws: TimeoutError or rethrowed error
    /// - Returns: return value of the task
    func waitExpectation<ReturnValue>(timeout: TimeInterval = 30, description: String = "expecation", _ handler: (@escaping (ReturnValue) -> Void) async throws -> Void) async throws -> ReturnValue {
        let expectation = self.expectation(description: description)
        var result: ReturnValue?
        try await handler { value in
            if result == nil {
                result = value
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        guard let unwrappedResult = result else { throw TimeoutError.dataTaskExpired }
        return unwrappedResult
    }

    /// Wait for synchronous tasks
    /// - Parameters:
    ///   - timeout: time to wait for task
    ///   - description: expectation description
    ///   - handler: handles task return
    /// - Throws: rethrows error
    func waitExpectation(timeout: TimeInterval = 30, description: String = "expecation", _ handler: (@escaping () -> Void) throws -> Void) rethrows {
        let expectation = self.expectation(description: description)
        try handler { expectation.fulfill() }
        waitForExpectations(timeout: timeout)
    }

    /// Wait for synchronous tasks
    /// - Parameters:
    ///   - timeout: time to wait for task
    ///   - description: expectation description
    ///   - handler: handles task return
    /// - Throws: rethrows error
    func waitExpectation(timeout: TimeInterval = 30, description: String = "expecation", _ handler: (@escaping () -> Void) async throws -> Void) async rethrows {
        let expectation = self.expectation(description: description)
        try await handler { expectation.fulfill() }
        waitForExpectations(timeout: timeout)
    }

    /// Wait timeout and expects no value
    /// - Parameters:
    ///   - timeout: time to wait for task
    ///   - description: expectation description
    ///   - handler: handles task return
    /// - Throws: rethrows error
    func waitNoData(timeout: TimeInterval, description: String = "expectation", file: StaticString = #file, line: UInt = #line, _ handler: (@escaping (Any?) -> Void) throws -> Void) rethrows {
        let expectation = self.expectation(description: description)
        try handler { _ in XCTAssertTrue(false, "No data expected, but got data", file: file, line: line) }
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) { expectation.fulfill() }
        waitForExpectations(timeout: timeout + 1)
    }

    /// Wait timeout and expects no value
    /// - Parameters:
    ///   - timeout: time to wait for task
    ///   - description: expectation description
    ///   - handler: handles task return
    /// - Throws: rethrows error
    func waitNoData(timeout: TimeInterval, description: String = "expectation", file: StaticString = #file, line: UInt = #line, _ handler: (@escaping () -> Void) throws -> Void) rethrows {
        let expectation = self.expectation(description: description)
        try handler { XCTAssertTrue(false, "No data expected, but got data", file: file, line: line) }
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) { expectation.fulfill() }
        waitForExpectations(timeout: timeout + 1)
    }

    /// Waits for given timeinterval
    /// - Parameter timeout: timeintval to wait
    func wait(_ timeout: TimeInterval) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
                continuation.resume()
            }
        }
    }
}

extension FirebaseFetcher {

    /// Fetches a testable club from firebase database
    /// - Parameter clubId: id of the club
    /// - Returns: promise of the club
    func fetchClub(_ clubId: Club.ID) async throws -> TestClub {
        async let properties = fetch(TestClub.Properties.self, url: nil, clubId: clubId)
        async let persons = fetchList(FirebasePerson.self, clubId: clubId)
        async let fines = fetchList(FirebaseFine.self, clubId: clubId)
        async let reasons = fetchList(FirebaseReasonTemplate.self, clubId: clubId)
        async let transactions = fetchList(FirebaseTransaction.self, clubId: clubId)
        return try await TestClub(properties: properties, persons: persons, fines: fines, reasons: reasons, transactions: transactions)
    }
}

extension Club: Equatable {
    public static func == (lhs: Club, rhs: Club) -> Bool {
        lhs.id == rhs.id &&
            lhs.identifier == rhs.identifier &&
            lhs.name == rhs.name &&
            lhs.regionCode == rhs.regionCode &&
            lhs.inAppPaymentActive == rhs.inAppPaymentActive
    }
}
