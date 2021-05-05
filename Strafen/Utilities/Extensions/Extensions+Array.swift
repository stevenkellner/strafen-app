//
//  Extensions+Array.swift
//  Strafen
//
//  Created by Steven on 05.05.21.
//

import Foundation

extension Array {
    
    /// Map this array containing the results of mapping the given closure over the sequence’s elements.
    /// - Parameter transform: A mapping closure.
    ///   Transform accepts an element of this sequence as its parameter.
    /// - Throws: Rethrows transform error.
    mutating func mapped(_ transform: (Element) throws -> Element) rethrows {
        self = try map(transform)
    }
    
    /// Filter this array given result of closure over the sequence's elements.
    /// - Parameter isIncluded: A isIncluded closure.
    ///     It takes an element if this sequence and returns true if element should retain in this sequence.
    /// - Throws: Rethrows isincluded error.
    mutating func filtered(_ isIncluded: (Element) throws -> Bool) rethrows {
        self = try filter(isIncluded)
    }
}
