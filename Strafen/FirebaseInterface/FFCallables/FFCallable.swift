//
//  FFCallable.swift
//  Strafen
//
//  Created by Steven on 05.05.21.
//

import Foundation

/// Type that can be called with the Firebase Function Caller
protocol FFCallable {

    /// Name of the firebase function
    var functionName: String { get }

    /// Parameters of the firebase function call
    var parameters: FirebaseCallParameterSet { get }

    /// Handler called after firebase function call was successful
    func successHandler()

    /// Handler called after firebase function call has failed
    func failedHandler()
}

extension FFCallable {
    func successHandler() {}
    func failedHandler() {}
}

/// Firebase function call that has a decodable result
protocol FFCallResult {

    /// Type of the firebase function call result
    associatedtype CallResult: Decodable
}
