//
//  ConnectionState.swift
//  Strafen
//
//  Created by Steven on 13.05.21.
//

import Foundation

/// State of a connection
enum ConnectionState {
    
    /// Connection not started yet
    case notStarted
    
    /// Connetion still loading
    case loading
    
    /// Connection failed
    case failed
    
    /// Connection passed
    case passed
    
    /// Sets state to `.notStarted`
    mutating func reset() {
        self = .notStarted
    }
    
    /// Sets state to `.loading` if current state is `.notStarted`
    /// - Returns: `.passed` if current state is `.notStarted`
    @discardableResult mutating func start() -> OperationResult {
        guard self == .notStarted else { return .failed }
        self = .loading
        return .passed
    }
    
    /// Sets state to `.loading` if current state is not `.loading`
    /// - Returns: `.passed` if current state is not `.loading`
    @discardableResult mutating func restart() -> OperationResult {
        guard self != .loading else { return .failed }
        self = .loading
        return .passed
    }
    
    /// Sets state to `.failed`
    mutating func failed() {
        self = .failed
    }
    
    /// Sets state to `.failed`
    mutating func passed() {
        self = .passed
    }
}
