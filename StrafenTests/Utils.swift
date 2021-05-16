//
//  Utils.swift
//  StrafenTests
//
//  Created by Steven on 05.05.21.
//

import XCTest
import Hydra
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
    func waitExpectation<ReturnValue>(timeout: TimeInterval = 60, description: String = "expecation", _ handler: (@escaping (ReturnValue) -> Void) throws -> Void) throws -> ReturnValue {
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
    /// - Throws: rethrows error
    func waitExpectation(timeout: TimeInterval = 60, description: String = "expecation", _ handler: (@escaping () -> Void) throws -> Void) rethrows {
        let expectation = self.expectation(description: description)
        try handler { expectation.fulfill() }
        waitForExpectations(timeout: timeout)
    }
    
    /// Wait timeout and expects no value
    /// - Parameters:
    ///   - timeout: time to wait for task
    ///   - description: expectation description
    ///   - handler: handles task return
    /// - Throws: rethrows error
    func waitNoData(timeout: TimeInterval, description: String = "expectation", _ handler: (@escaping (Any?) -> Void) throws -> Void) rethrows {
        let expectation = self.expectation(description: description)
        try handler { _ in XCTAssertTrue(false, "No data expected, but got data") }
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) { expectation.fulfill() }
        waitForExpectations(timeout: timeout + 1)
    }
    
    /// Wait timeout and expects no value
    /// - Parameters:
    ///   - timeout: time to wait for task
    ///   - description: expectation description
    ///   - handler: handles task return
    /// - Throws: rethrows error
    func waitNoData(timeout: TimeInterval, description: String = "expectation", _ handler: (@escaping () -> Void) throws -> Void) rethrows {
        let expectation = self.expectation(description: description)
        try handler { XCTAssertTrue(false, "No data expected, but got data") }
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) { expectation.fulfill() }
        waitForExpectations(timeout: timeout + 1)
    }
    
    /// Waits for given timeinterval
    /// - Parameter timeout: timeintval to wait
    func wait(_ timeout: TimeInterval) {
        let expectation = self.expectation(description: "waitExpectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) { expectation.fulfill() }
        waitForExpectations(timeout: timeout + 1)
    }
}

extension FirebaseFetcher {
    
    /// Fetches a testable club from firebase database
    /// - Parameter clubId: id of the club
    /// - Returns: promise of the club
    func fetchClub(_ clubId: UUID) -> Promise<TestClub> {
        let properties = fetch(TestClub.Properties.self, url: nil, clubId: clubId)
        let persons = fetchList(FirebasePerson.self, clubId: clubId)
        let fines = fetchList(FirebaseFine.self, clubId: clubId)
        let reasons = fetchList(FirebaseReasonTemplate.self, clubId: clubId)
        let transactions = fetchList(FirebaseTransaction.self, clubId: clubId)
        return zip(a: properties, b: persons, c: fines, d: reasons, e: transactions).then { properties, persons, fines, reasons, transactions in
            return TestClub(properties: properties, persons: persons, fines: fines, reasons: reasons, transactions: transactions)
        }
    }
}

/// Join two promises and return a tuple with the results of both (promises will be resolved in parallel in `background` QoS queue).
/// Rejects as soon one promise reject.
///
/// - Parameters:
///   - context: context queue to report the result (if not specified `background` queue is used instead)
///   - a: promise a
///   - b: promise b
///   - c: promsie c
///   - d: promise d
///   - e: promise e
/// - Returns: joined promise of type Promise<(A,B)>
public func zip<A, B, C, D, E>(in context: Context? = nil, a: Promise<A>, b: Promise<B>, c: Promise<C>, d: Promise<D>, e: Promise<E>) -> Promise<(A, B, C, D, E)> {
    zip(in: context, zip(in: context, a: a, b: b, c: c, d: d), e).then { tuple, e in
        return (tuple.0, tuple.1, tuple.2, tuple.3, e)
    }
}
