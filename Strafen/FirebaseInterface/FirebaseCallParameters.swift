//
//  FirebaseCallParameters.swift
//  Strafen
//
//  Created by Steven on 05.05.21.
//

import SwiftUI

/// Set of parameters that can be used as a parameter in a firebase function call.
struct FirebaseCallParameterSet {
    
    /// Dicticionary of parameters that can be used as a parameter in a firebase function call.
    private(set) var parameters: [String : FirebaseParameterable]
    
    /// Inits parameter set with old parameters and a closure to add more parameters
    /// - Parameters:
    ///   - parameters: old parameters to append to this set
    ///   - adding: closure to add more parameters
    init(_ parameters: FirebaseCallParameterSet? = nil, _ adding: ((inout [String : FirebaseParameterable]) -> Void)? = nil) {
        self.parameters = parameters?.parameters ?? [:]
        if let adding = adding {
            adding(&self.parameters)
        }
    }
    
    /// Add a single parameter with given key to the parameter set
    /// - Parameters:
    ///   - value: the new parameter
    ///   - key: key of the parameter
    mutating func add(_ value: FirebaseParameterable, for key: String) {
        parameters[key] = value
    }
    
    /// Adds parameters of given set to this parameter set
    /// - Parameter moreParameters: parameters to append to this set
    mutating func add(_ moreParameters: FirebaseCallParameterSet) {
        add(moreParameters.parameters)
    }
    
    /// Adds parameters of given set to this parameter set
    /// - Parameter moreParameters: parameters to append to this set
    mutating func add(_ moreParameters: [String : FirebaseParameterable]) {
        parameters.merge(moreParameters) { firstValue, _ in firstValue}
    }
    
    /// Sets and gets parameter with given key
    /// - Parameters:
    ///   - key: key of the parameter
    /// - Returns: the parameter associated with key, nil if key wasn't found
    subscript(_ key: String) -> FirebaseParameterable? {
        get { parameters[key] }
        set { parameters[key] = newValue }
    }
    
    /// Transformed parameters as Dictionaray of [String : FirebasePrimordialParameterable]
    /// that can be used as a parameter in a firebase function call.
    var primordialParameter: [String: FirebasePrimordialParameterable] {
        parameters.mapValues { value in
            value.primordialParameter
        }
    }
}

// -MARK: Firebase Primordial Parameterable

/// All types that can be used as a parameter in a firebase function call.
protocol FirebasePrimordialParameterable {}

// -MARK: Conformance of necessary types to FirebasePrimordialParameterable

extension Bool: FirebasePrimordialParameterable {}
extension Int: FirebasePrimordialParameterable {}
extension Double: FirebasePrimordialParameterable {}
extension CGFloat: FirebasePrimordialParameterable {}
extension String: FirebasePrimordialParameterable {}
extension Array: FirebasePrimordialParameterable where Element == FirebasePrimordialParameterable {}
extension Optional: FirebasePrimordialParameterable where Wrapped == FirebasePrimordialParameterable {}
extension Dictionary: FirebasePrimordialParameterable where Key == String, Value == FirebasePrimordialParameterable {}

// -MARK: Firebase Parameterable

/// All types that can be transformed to FirebasePrimordialParameterable
/// that can be used as a parameter in a firebase function call.
protocol FirebaseParameterable {
    
    /// Transformed parameters as FirebasePrimordialParameterable
    /// that can be used as a parameter in a firebase function call.
    var primordialParameter: FirebasePrimordialParameterable { get }
}

// -MARK: Conformance of common types to FirebaseParameterable

extension FirebaseParameterable where Self: FirebasePrimordialParameterable {
    var primordialParameter: FirebasePrimordialParameterable { self }
}

extension Bool: FirebaseParameterable {}
extension Int: FirebaseParameterable {}
extension Double: FirebaseParameterable {}
extension CGFloat: FirebaseParameterable {}
extension String: FirebaseParameterable {}

extension Array: FirebaseParameterable where Element: FirebaseParameterable {
    var primordialParameter: FirebasePrimordialParameterable {
        map { $0.primordialParameter }
    }
}

extension Optional: FirebaseParameterable where Wrapped: FirebaseParameterable {
    var primordialParameter: FirebasePrimordialParameterable {
        map { $0.primordialParameter }
    }
}

extension Dictionary: FirebaseParameterable where Key == String, Value: FirebaseParameterable {
    var primordialParameter: FirebasePrimordialParameterable {
        mapValues { $0.primordialParameter }
    }
}

extension UUID: FirebaseParameterable {
    var primordialParameter: FirebasePrimordialParameterable {
        uuidString
    }
}

extension Date: FirebaseParameterable {
    var primordialParameter: FirebasePrimordialParameterable {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(self)
        return Double(String(data: data, encoding: .utf8)!)!
    }
}

extension URL: FirebaseParameterable {
    var primordialParameter: FirebasePrimordialParameterable {
        path
    }
}

extension Tagged: FirebaseParameterable where RawValue: FirebaseParameterable {
    var primordialParameter: FirebasePrimordialParameterable {
        rawValue.primordialParameter
    }
}
