//
//  FunctionCallable.swift
//  Strafen
//
//  Created by Steven on 11/8/20.
//

import Foundation

/// Can be call with Firebase functions
protocol FunctionCallable {
    
    /// Https callable function name
    var functionName: String { get }
    
    /// Change parametes
    var parameters: Parameters { get }
    
    /// Handler called after function call is succeded
    func successHandler()
    
    /// Handler called after function call is failed
    func failedHandler()
}

/// Function call has a decodable result
protocol FunctionCallResult {
    
    /// Type of call result data
    associatedtype CallResult: Decodable
}

// Extension of FunctionCallable to get default handler
extension FunctionCallable {
    
    /// Handler called after function call is succeded
    func successHandler() {}
    
    /// Handler called after function call is failed
    func failedHandler() {}
}
