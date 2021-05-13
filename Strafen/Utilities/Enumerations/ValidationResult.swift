//
//  ValidationResult.swift
//  Strafen
//
//  Created by Steven on 12.05.21.
//

import Foundation

/// Result of a validation
enum ValidationResult {
    
    /// Validation was valid
    case valid
    
    /// Validation was invalid
    case invalid
    
    /// Toggles the ValidationResult variable's value.
    ///
    /// Use this method to toggle a ValidationResult value from `.valid` to `.invalid` or from
    /// `.invalid` to `.valid`.
    mutating func toggle() {
        if self == .valid {
            return self = .invalid
        }
        self = .valid
    }
    
    /// Performs a logical AND operation on two ValidationResult values.
    ///
    /// The logical AND operator (`&&`) combines two ValidationResult values and returns
    /// `.valid` if both of the values are `.valid`. If either of the values is
    /// `.invalid`, the operator returns `.invalid`.
    ///
    /// - Parameters:
    ///   - lhs: left-hand side of the operation
    ///   - rhs: right-hand side of the operation
    /// - Throws: rethrows error
    /// - Returns: result of logical AND operation
    static func &&(lhs: ValidationResult, rhs: @autoclosure () throws -> ValidationResult) rethrows -> ValidationResult {
        if lhs == .invalid {
            return .invalid
        }
        return try rhs()
    }
    
    /// Performs a logical OR operation on two ValidationResult values.
    ///
    /// The logical OR operator (`||`) combines two ValidationResult values and returns
    /// `.valid` if at least one of the values is `.valid`. If both values are
    /// `.invalid`, the operator returns `.invalid`.
    ///
    /// - Parameters:
    ///   - lhs: left-hand side of the operation
    ///   - rhs: right-hand side of the operation
    /// - Throws: rethrows error
    /// - Returns: result of logical OR operation
    static func ||(lhs: ValidationResult, rhs: @autoclosure () throws -> ValidationResult) rethrows -> ValidationResult {
        if lhs == .valid {
            return .valid
        }
        return try rhs()
    }
    
    /// Performs a logical NOT operation on a ValidationResult value.
    ///
    /// The logical NOT operator (`!`) inverts a ValidationResult value. If the value is
    /// `.valid`, the result of the operation is `.invalid`; if the value is `.invalid`,
    /// the result is `.valid`.
    /// 
    /// - Parameter a: validation result value to negate
    /// - Returns: negated validation result
    static prefix func !(a: ValidationResult) -> ValidationResult {
        var b = a
        b.toggle()
        return b
    }
}

extension Collection where Element == ValidationResult {
    
    /// `.valid` if all elements are `.valid`, else `.invalid`
    var validateAll: ValidationResult {
        allSatisfy { validationResult in
            validationResult == .valid
        } ? .valid : .invalid
    }
}
extension Collection {
    
    /// `.valid` if validation of all elements are `.valid`, `.invalid` otherwise
    /// - Parameter validation: closure to validate element
    /// - Throws: rethrows error
    /// - Returns: validation result
    func validateAll(validation: (Element) throws -> ValidationResult) rethrows -> ValidationResult {
        try map(validation).validateAll
    }
}
