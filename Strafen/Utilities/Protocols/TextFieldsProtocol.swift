//
//  TextFieldsProtocol.swift
//  Strafen
//
//  Created by Steven on 13.05.21.
//

import Foundation

/// Protocol for text fields
protocol TextFieldsProtocol: CaseIterable, Comparable, Hashable {

    /// Init with rawValue
    /// - Parameter rawValue: raw value
    init?(rawValue: Int)

    /// Raw value
    var rawValue: Int { get }
}

extension TextFieldsProtocol {

    /// Next textfield after this textfield
    var next: Self {
        Self.init(rawValue: (rawValue + 1) % Self.allCases.count)!
    }
}

extension TextFieldsProtocol {
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// Default textfields
enum DefaultTextFields: Int, TextFieldsProtocol {
    case textField
}
