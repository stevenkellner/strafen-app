//
//  PropertyWrapper.swift
//  Strafen
//
//  Created by Steven on 12/17/20.
//

import Foundation

/// Used to clamp a comparable value between lower and upper bound
@propertyWrapper struct Clamping<Value> where Value: Comparable {
    
    /// Value
    private var value: Value
    
    /// Range to be clamped
    private let range: ClosedRange<Value>

    init(wrappedValue value: Value, _ range: ClosedRange<Value>) {
        self.value = range.clamp(value)
        self.range = range
    }

    var wrappedValue: Value {
        get { value }
        set { value = range.clamp(newValue) }
    }
}

// Extension of ClosedRange to clamp a value between lower and upper bound
extension ClosedRange {
    
    /// Clamps value between lower and upper bound
    func clamp(_ value: Bound) -> Bound {
        Swift.min(Swift.max(value, lowerBound), upperBound)
    }
}

/// Used to make a comparable number always non negative
@propertyWrapper struct NonNegative<Value> where Value: Comparable & AdditiveArithmetic {
    
    /// Value
    private var value: Value
    
    init(wrappedValue value: Value) {
        self.value = Swift.max(.zero, value)
    }
    
    var wrappedValue: Value {
        get { value }
        set { value = Swift.max(.zero, newValue)}
    }
}
