//
//  OperationResult.swift
//  Strafen
//
//  Created by Steven on 13.05.21.
//

import Foundation

/// Result of a check
enum OperationResult {

    /// Operation is passed
    case passed

    /// Operation is failed
    case failed

    /// Toggles the ValidationResult OperationResult's value.
    ///
    /// Use this method to toggle a OperationResult value from `.passed` to `.failed` or from
    /// `.failed` to `.passed`.
    mutating func toggle() {
        if self == .passed {
            return self = .failed
        }
        self = .passed
    }

    /// Performs a logical AND operation on two OperationResult values.
    ///
    /// The logical AND operator (`&&`) combines two OperationResult values and returns
    /// `.passed` if both of the values are `.passed`. If either of the values is
    /// `.failed`, the operator returns `.failed`.
    ///
    /// - Parameters:
    ///   - lhs: left-hand side of the operation
    ///   - rhs: right-hand side of the operation
    /// - Throws: rethrows error
    /// - Returns: result of logical AND operation
    static func && (lhs: OperationResult, rhs: @autoclosure () throws -> OperationResult) rethrows -> OperationResult {
        if lhs == .failed {
            return .failed
        }
        return try rhs()
    }

    /// Performs a logical OR operation on two OperationResult values.
    ///
    /// The logical OR operator (`||`) combines two OperationResult values and returns
    /// `.passed` if at least one of the values is `.passed`. If both values are
    /// `.failed`, the operator returns `.failed`.
    ///
    /// - Parameters:
    ///   - lhs: left-hand side of the operation
    ///   - rhs: right-hand side of the operation
    /// - Throws: rethrows error
    /// - Returns: result of logical OR operation
    static func || (lhs: OperationResult, rhs: @autoclosure () throws -> OperationResult) rethrows -> OperationResult {
        if lhs == .passed {
            return .passed
        }
        return try rhs()
    }

    /// Performs a logical NOT operation on a OperationResult value.
    ///
    /// The logical NOT operator (`!`) inverts a OperationResult value. If the value is
    /// `.passed`, the result of the operation is `.failed`; if the value is `.failed`,
    /// the result is `.passed`.
    ///
    /// - Parameter rhs: validation result value to negate
    /// - Returns: negated validation result
    static prefix func ! (rhs: OperationResult) -> OperationResult {
        var result = rhs
        result.toggle()
        return result
    }
}

extension Collection where Element == OperationResult {

    /// `.passed` if all elements are `.passed`, else `.failed`
    var allPassed: OperationResult {
        allSatisfy { checkResult in
            checkResult == .passed
        } ? .passed : .failed
    }
}
extension Collection {

    /// `.passed` if check of all elements are `.passed`, `.failed` otherwise
    /// - Parameter passed: closure to check if element is passed
    /// - Throws: rethrows error
    /// - Returns: check result
    func validateAll(passed: (Element) throws -> OperationResult) rethrows -> OperationResult {
        try map(passed).allPassed
    }
}
