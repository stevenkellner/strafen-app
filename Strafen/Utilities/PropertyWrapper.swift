//
//  PropertyWrapper.swift
//  Strafen
//
//  Created by Steven on 05.05.21.
//

import Foundation

/// Used to clamp a comparable value between lower and upper bound
@propertyWrapper struct Clamping<Value> where Value: Comparable {
    
    /// Value
    private var value: Value
    
    /// Range to be clamped
    private let range: ClosedRange<Value>
    
    /// Init with a value and range to wrap to
    /// - Parameters:
    ///   - value: value to wrap
    ///   - range: range to wrap to
    init(wrappedValue value: Value, _ range: ClosedRange<Value>) {
        self.value = range.clamp(value)
        self.range = range
    }
    
    /// Wrapped property value
    var wrappedValue: Value {
        get { value }
        set { value = range.clamp(newValue) }
    }
}

extension ClosedRange {
    
    /// Clamps value between lower and upper bound
    /// - Parameter value: value to clamp
    /// - Returns: clamps value
    func clamp(_ value: Bound) -> Bound {
        Swift.min(Swift.max(value, lowerBound), upperBound)
    }
}

/// Used to make a comparable number always non negative
@propertyWrapper struct NonNegative<Value> where Value: Comparable & AdditiveArithmetic {
    
    /// Value
    private var value: Value
    
    /// Init with a value
    /// - Parameter value: value to wrap
    init(wrappedValue value: Value) {
        self.value = Swift.max(.zero, value)
    }
    
    /// Wrapped property value
    var wrappedValue: Value {
        get { value }
        set { value = Swift.max(.zero, newValue)}
    }
}
