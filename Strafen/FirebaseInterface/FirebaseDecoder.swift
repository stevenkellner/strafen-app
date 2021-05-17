//
//  FirebaseDecoder.swift
//  Strafen
//
//  Created by Steven on 04.05.21.
//

import Foundation
import CodableFirebase

/// Decodes firebase database types
struct FirebaseDecoder {

    /// Shared instance for singelton
    static let shared = FirebaseDecoder()

    /// Private init for singleton
    private init() {}

    /// An error that occurs during the decoding of a value
    enum DecodingError: Error {

        /// Data can not be converted to Dictionary<String, Any>
        case noKeyedData

        /// Data can not be converted to Array<Any>
        case noList
    }

    /// Decodes given type from firebase database data and given key.
    /// Throws error if data can not be decoded.
    /// - Parameters:
    ///   - type: Type to decode to
    ///   - data: Data to decode from
    ///   - key: Key of the data
    /// - Throws: DecodingError and FirebaseDecoder.DecodingError if data can not be decoded.
    /// - Returns: Decoded data of given type
    func decodeOrThrow<T>(_ type: T.Type, _ data: Any, key: String) throws -> T where T: Decodable {
        guard var dict = data as? [String: Any] else { throw DecodingError.noKeyedData }
        dict["key"] = key
        let decoder = CodableFirebase.FirebaseDecoder()
        return try decoder.decode(type, from: dict)
    }

    /// Decodes given type from firebase database data and given key.
    /// Returns nil if data can not be decoded.
    /// - Parameters:
    ///   - type: Type to decode to
    ///   - data: Data to decode from
    ///   - key: Key of the data
    /// - Returns: Decoded data of given type or nil if data can not be decoded.
    func decode<T>(_ type: T.Type, _ data: Any, key: String) -> T? where T: Decodable {
        try? decodeOrThrow(type, data, key: key)
    }

    /// Decodes given type from firebase database data.
    /// Throws error if data can not be decoded.
    /// - Parameters:
    ///   - type: Type to decode to
    ///   - data: Data to decode from
    /// - Throws: DecodingError if data can not be decoded.
    /// - Returns: Decoded data of given type
    func decodeOrThrow<T>(_ type: T.Type, _ data: Any) throws -> T where T: Decodable {
        let decoder = CodableFirebase.FirebaseDecoder()
        return try decoder.decode(type, from: data)
    }

    /// Decodes given type from firebase database data.
    /// Returns nil if data can not be decoded.
    /// - Parameters:
    ///   - type: Type to decode to
    ///   - data: Data to decode from
    /// - Returns: Decoded data of given type or nil if data can not be decoded.
    func decode<T>(_ type: T.Type, _ data: Any) -> T? where T: Decodable {
        try? decodeOrThrow(type, data)
    }

    /// Decodes array of given type from firebase database data.
    /// Throws error if data can not be decoded.
    /// - Parameters:
    ///   - type: Element type to decode to
    ///   - data: Data to decode from
    /// - Throws: DecodingError and FirebaseDecoder.DecodingError if data can not be decoded.
    /// - Returns: Decoded data of array of given type
    func decodeListOrThrow<T>(_ type: T.Type, _ data: Any) throws -> [T] where T: Decodable {
        guard let dict = data as? [String: Any] else { throw DecodingError.noKeyedData }
        return try dict.map { key, value in
            try decodeOrThrow(type, value, key: key)
        }
    }

    /// Decodes array of given type from firebase database data.
    /// Returns nil if data can not be decoded.
    /// - Parameters:
    ///   - type: Element type to decode to
    ///   - data: Data to decode from
    /// - Returns: Decoded data of array of given type or nil if data can not be decoded.
    func decodeList<T>(_ type: T.Type, _ data: Any) -> [T]? where T: Decodable {
        try? decodeListOrThrow(type, data)
    }

    /// Decodes array of given unkeyed type from firebase database data.
    /// Throws error if data can not be decoded.
    /// - Parameters:
    ///   - type: Element type to decode to
    ///   - data: Data to decode from
    /// - Throws: DecodingError and FirebaseDecoder.DecodingError if data can not be decoded.
    /// - Returns: Decoded data of array of given primitive type
    func decodeUnkeyedListOrThrow<T>(_ type: T.Type, _ data: Any) throws -> [T] where T: Decodable {
        guard let list = data as? [Any] else { throw DecodingError.noList }
        return try list.map { value in
            try decodeOrThrow(type, value)
        }
    }

    /// Decodes array of given unkeyed type from firebase database data.
    /// Returns nil if data can not be decoded.
    /// - Parameters:
    ///   - type: Element type to decode to
    ///   - data: Data to decode from
    /// - Returns: Decoded data of array of given primitive type or nil if data can not be decoded.
    func decodeUnkeyedList<T>(_ type: T.Type, _ data: Any) -> [T]? where T: Decodable {
        try? decodeUnkeyedListOrThrow(type, data)
    }
}
