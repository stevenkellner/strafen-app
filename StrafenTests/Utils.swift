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
    ///   - handler: handles task return
    /// - Throws: TimeoutError or rethrowed error
    /// - Returns: return value of the task
    func waitExpectation<ReturnValue>(timeout: TimeInterval = 60, _ handler: (@escaping (ReturnValue) -> Void) throws -> Void) throws -> ReturnValue {
        let expectation = self.expectation(description: "expecation")
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
    ///   - handler: handles task return
    /// - Throws: rethrows error
    func waitExpectation(timeout: TimeInterval = 60, _ handler: (@escaping () -> Void) throws -> Void) rethrows {
        let expectation = self.expectation(description: "expectation")
        try handler { expectation.fulfill() }
        waitForExpectations(timeout: timeout)
    }
}

extension FirebaseFetcher {
    
    /// Fetches a testable club from firebase database
    /// - Parameter clubId: id of the club
    /// - Returns: promise of the club
    func fetchClub(_ clubId: UUID) -> Promise<TestClub> {
        let properties = fetch(TestClub.Properties.self, url: nil, level: .testing, clubId: clubId)
        let persons = fetchList(FirebasePerson.self, level: .testing, clubId: clubId)
        let fines = fetchList(FirebaseFine.self, level: .testing, clubId: clubId)
        let reasons = fetchList(FirebaseReasonTemplate.self, level: .testing, clubId: clubId)
        let transactions = fetchList(FirebaseTransaction.self, level: .testing, clubId: clubId)
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
