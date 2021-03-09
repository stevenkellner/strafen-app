//
//  Parameters.swift
//  Strafen
//
//  Created by Steven on 11/8/20.
//

import SwiftUI

/// Parameters for change
struct Parameters {
    
    /// Parameters
    var parameters: [String : ParameterableObject]
    
    init(_ parameters: Parameters? = nil, _ adding: ((inout [String : ParameterableObject]) -> Void)? = nil) {
        self.parameters = parameters?.parameters ?? [:]
        if let adding = adding {
            adding(&self.parameters)
        }
    }
    
    /// Add single value
    mutating func add(_ value: ParameterableObject, for key: String) {
        parameters[key] = value
    }
    
    /// Add more values
    mutating func add(_ moreParameters: [String : ParameterableObject]) {
        parameters.merge(moreParameters) { firstValue, _ in firstValue}
    }
    
    /// Object call with Firebase function as Parameter
    var parameterableObject: [String: _ParameterableObject] {
        parameters.mapValues { value in
            value.parameterableObject
        }
    }
}

/// Object call with Firebase function as Parameter
protocol _ParameterableObject {}

/// Object call with Firebase function as Parameter
protocol ParameterableObject {
    
    /// Object call with Firebase function as Parameter
    var parameterableObject: _ParameterableObject { get }
}

// Extension of ParameterableObject to get default parameterableObject
extension ParameterableObject where Self: _ParameterableObject {
    
    /// Object call with Firebase function as Parameter
    var parameterableObject: _ParameterableObject { self }
}

// Extension for valid _ParameterableObjects
extension Bool: _ParameterableObject, ParameterableObject {}
extension Int: _ParameterableObject, ParameterableObject {}
extension Double: _ParameterableObject, ParameterableObject {}
extension CGFloat: _ParameterableObject, ParameterableObject {}
extension String: _ParameterableObject, ParameterableObject {}
extension Array: _ParameterableObject where Element == _ParameterableObject {}
extension Optional: _ParameterableObject where Wrapped == _ParameterableObject {}
extension Dictionary: _ParameterableObject where Value == _ParameterableObject {}

// Extension of Array to confirm to ParameterableObject
extension Array: ParameterableObject where Element == ParameterableObject {
    var parameterableObject: _ParameterableObject {
        map { $0.parameterableObject }
    }
}

// Extension of Optional to confirm to ParameterableObject
extension Optional: ParameterableObject where Wrapped: ParameterableObject {
    var parameterableObject: _ParameterableObject {
        map { $0.parameterableObject }
    }
}

// Extension of Dictionary to confirm to ParameterableObject
extension Dictionary: ParameterableObject where Value == ParameterableObject {
    var parameterableObject: _ParameterableObject {
        mapValues { $0.parameterableObject }
    }
}

// Extension of UUID to confirm to ParameterableObject
extension UUID: ParameterableObject {
    
    /// Object call with Firebase function as Parameter
    var parameterableObject: _ParameterableObject {
        uuidString
    }
}

// Extension of Date to confirm to ParameterableObject
extension Date: ParameterableObject {
    
    /// Object call with Firebase function as Parameter
    var parameterableObject: _ParameterableObject {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(self)
        return Double(String(data: data, encoding: .utf8)!)!
    }
}

// Extension of Tagged to confirm to ParameterableObject
extension Tagged: ParameterableObject where RawValue: ParameterableObject {
    
    /// Object call with Firebase function as Parameter
    var parameterableObject: _ParameterableObject {
        rawValue.parameterableObject
    }
}
