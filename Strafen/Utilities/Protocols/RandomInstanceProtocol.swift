//
//  RandomInstanceProtocol.swift
//  Strafen
//
//  Created by Steven on 20.05.21.
//

import Foundation

/// Protocol used to create a random instance of the type
protocol RandomInstanceProtocol {

    /// Returns a random instace of the type
    /// - Parameter generator: random number generator
    /// - Returns: random instance of the type
    static func random<T>(using generator: inout T) -> Self where T: RandomNumberGenerator
}

extension RandomInstanceProtocol {

    /// Returns a random instace of the type
    /// - Returns: random instance of the type
    static func random() -> Self {
        var generator = SystemRandomNumberGenerator()
        return random(using: &generator)
    }
}

extension Array where Element: RandomInstanceProtocol {

    /// Generates a random list of given length
    /// - Parameter length: length of the list
    /// - Parameter generator: generator: random number generator
    /// - Returns: random list
    static func randomList<T>(of length: UInt, using generator: inout T) -> [Element] where T: RandomNumberGenerator {
        (0..<length).map { _ in Element.random(using: &generator) }
    }

    /// Generates a random list of given length
    /// - Parameter length: length of the list
    /// - Returns: random list
    static func randomList(of length: UInt) -> [Element] {
        var generator = SystemRandomNumberGenerator()
        return randomList(of: length, using: &generator)
    }

    /// Generates a random list of given length
    /// - Parameter lengthRange: length of the list
    /// - Returns: random list
    static func randomList(in lengthRange: ClosedRange<UInt>) -> [Element] {
        var generator = SystemRandomNumberGenerator()
        guard let length = lengthRange.randomElement(using: &generator) else { return [] }
        return randomList(of: length, using: &generator)
    }
}
