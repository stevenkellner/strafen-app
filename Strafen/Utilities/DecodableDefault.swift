//
//  DecodableDefault.swift
//  Strafen
//
//  Created by Steven on 25.05.21.
//

import Foundation

/// Source of default value for decoding
protocol DecodableDefaultSource {

    /// Type of value to decode
    associatedtype Value: Decodable

    /// Default value for decoding
    static var defaultValue: Value { get }
}

/// Used for multiple decoding defaults
enum DecodableDefault {}

extension DecodableDefault {

    /// Wrapper to decode value with default value
    @propertyWrapper struct Wrapper<Source>: Decodable where Source: DecodableDefaultSource {

        typealias Value = Source.Value

        /// Wrapped value, can be decoded value or the default value
        var wrappedValue: Value

        /// Init with default value
        init() {
            self.wrappedValue = Source.defaultValue
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.wrappedValue = try container.decode(Value.self)
        }
    }
}

extension DecodableDefault.Wrapper: Encodable where Value: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

extension DecodableDefault {

    /// Used for multiple decoding default sources
    enum Sources {

        /// For Bool is default value `true`
        enum True: DecodableDefaultSource {
            static var defaultValue: Bool { true }
        }

        /// For Bool is default value `false`
        enum False: DecodableDefaultSource {
            static var defaultValue: Bool { false }
        }

        /// For String is default value `""`
        enum EmptyString: DecodableDefaultSource {
            static var defaultValue: String { "" }
        }

        /// For Array is default value `[]`
        enum EmptyList<T>: DecodableDefaultSource where T: Decodable & ExpressibleByArrayLiteral {
            static var defaultValue: T { [] }
        }

        /// For Dictionary is default value `[:]`
        enum EmptyDict<T>: DecodableDefaultSource where T: Decodable & ExpressibleByDictionaryLiteral {
            static var defaultValue: T { [:] }
        }
    }
}

extension DecodableDefault {

    /// For Bool is default value `true`
    typealias True = Wrapper<Sources.True>

    /// For Bool is default value `false`
    typealias False = Wrapper<Sources.False>

    /// For String is default value `""`
    typealias EmptyString = Wrapper<Sources.EmptyString>

    /// For Array is default value `[]`
    typealias EmptyList<T> = Wrapper<Sources.EmptyList<T>> where T: Decodable & ExpressibleByArrayLiteral

    /// For Dictionary is default value `[:]`
    typealias EmptyDict<T> = Wrapper<Sources.EmptyDict<T>> where T: Decodable & ExpressibleByDictionaryLiteral
}

extension DecodableDefault.Wrapper: Equatable where Value: Equatable {}
extension DecodableDefault.Wrapper: Hashable where Value: Hashable {}

extension KeyedDecodingContainer {

    /// Decode with default decable wrapper
    func decode<T>(_ type: DecodableDefault.Wrapper<T>.Type, forKey key: Key) throws -> DecodableDefault.Wrapper<T> {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }
}
