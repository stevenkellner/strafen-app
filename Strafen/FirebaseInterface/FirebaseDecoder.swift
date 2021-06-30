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
    ///
    /// Decodes data like this:
    /// ```json
    /// {
    ///     "firstProperty": "value",
    ///     "secondProperty": 12.5
    /// }
    /// ```
    /// to a type like this:
    /// ```swift
    /// struct DecodedType: Decodable {
    ///     let key: String
    ///     let firstProperty: String
    ///     let secondProperty: Double
    /// }
    /// ```
    /// - Parameters:
    ///   - type: The type of the value to decode.
    ///   - data: The data to decode from.
    ///   - key: The key of the data.
    /// - Throws: DecodingError and FirebaseDecoder.DecodingError if data can not be decoded.
    /// - Returns: Decoded data of given type
    func decodeOrThrow<T>(_ type: T.Type, _ data: Any, key: String) throws -> T where T: Decodable {
        guard var dict = data as? [String: Any] else { throw DecodingError.noKeyedData }
        dict["id"] = key
        let decoder = CodableFirebase.FirebaseDecoder()
        return try decoder.decode(type, from: dict)
    }

    /// Decodes given type from firebase database data and given key.
    /// Returns `.failure(_)` if data can not be decoded.
    ///
    /// Decodes data like this:
    /// ```json
    /// {
    ///     "firstProperty": "value",
    ///     "secondProperty": 12.5
    /// }
    /// ```
    /// to a type like this:
    /// ```swift
    /// struct DecodedType: Decodable {
    ///     let key: String
    ///     let firstProperty: String
    ///     let secondProperty: Double
    /// }
    /// ```
    /// - Parameters:
    ///   - type: The type of the value to decode.
    ///   - data: The data to decode from.
    ///   - key: The key of the data.
    /// - Returns: Result of decoded data of given type or `.failure(_)` if data can not be decoded.
    func decodeResult<T>(_ type: T.Type, _ data: Any, key: String) -> Result<T, Error> where T: Decodable {
        Result { try decodeOrThrow(type, data, key: key) }
    }

    /// Decodes given type from firebase database data and given key.
    /// Returns nil if data can not be decoded.
    ///
    /// Decodes data like this:
    /// ```json
    /// {
    ///     "firstProperty": "value",
    ///     "secondProperty": 12.5
    /// }
    /// ```
    /// to a type like this:
    /// ```swift
    /// struct DecodedType: Decodable {
    ///     let key: String
    ///     let firstProperty: String
    ///     let secondProperty: Double
    /// }
    /// ```
    /// - Parameters:
    ///   - type: The type of the value to decode.
    ///   - data: The data to decode from.
    ///   - key: The key of the data.
    /// - Returns: Decoded data of given type or nil if data can not be decoded.
    func decode<T>(_ type: T.Type, _ data: Any, key: String) -> T? where T: Decodable {
        try? decodeOrThrow(type, data, key: key)
    }

    /// Decodes given type from firebase database data.
    /// Throws error if data can not be decoded.
    ///
    /// Decodes data like this:
    /// ```json
    /// {
    ///     "firstProperty": "value",
    ///     "secondProperty": 12.5
    /// }
    /// ```
    /// to a type like this:
    /// ```swift
    /// struct DecodedType: Decodable {
    ///     let firstProperty: String
    ///     let secondProperty: Double
    /// }
    /// ```
    /// - Parameters:
    ///   - type: The type of the value to decode.
    ///   - data: The data to decode from.
    /// - Throws: DecodingError if data can not be decoded.
    /// - Returns: Decoded data of given type
    func decodeOrThrow<T>(_ type: T.Type, _ data: Any) throws -> T where T: Decodable {
        let decoder = CodableFirebase.FirebaseDecoder()
        return try decoder.decode(type, from: data)
    }

    /// Decodes given type from firebase database data.
    /// Returns `.failure(_)` if data can not be decoded.
    ///
    /// Decodes data like this:
    /// ```json
    /// {
    ///     "firstProperty": "value",
    ///     "secondProperty": 12.5
    /// }
    /// ```
    /// to a type like this:
    /// ```swift
    /// struct DecodedType: Decodable {
    ///     let firstProperty: String
    ///     let secondProperty: Double
    /// }
    /// ```
    /// - Parameters:
    ///   - type: The type of the value to decode.
    ///   - data: The data to decode from.
    /// - Returns: Result of decoded data of given type orr`.failure(_)` if data can not be decoded.
    func decodeResult<T>(_ type: T.Type, _ data: Any) -> Result<T, Error> where T: Decodable {
        Result { try decodeOrThrow(type, data) }
    }

    /// Decodes given type from firebase database data.
    /// Returns nil if data can not be decoded.
    ///
    /// Decodes data like this:
    /// ```json
    /// {
    ///     "firstProperty": "value",
    ///     "secondProperty": 12.5
    /// }
    /// ```
    /// to a type like this:
    /// ```swift
    /// struct DecodedType: Decodable {
    ///     let firstProperty: String
    ///     let secondProperty: Double
    /// }
    /// ```
    /// - Parameters:
    ///   - type: The type of the value to decode.
    ///   - data: The data to decode from.
    /// - Returns: Decoded data of given type or nil if data can not be decoded.
    func decode<T>(_ type: T.Type, _ data: Any) -> T? where T: Decodable {
        try? decodeOrThrow(type, data)
    }

    /// Decodes array of given type from firebase database data.
    /// Throws error if data can not be decoded.
    ///
    /// Decodes data like this:
    /// ```json
    /// {
    ///     "firstKey": {
    ///         "firstProperty": "value",
    ///         "secondProperty": 12.5
    ///     },
    ///     ...
    /// }
    /// ```
    /// to a list with elements of type like this:
    /// ```swift
    /// struct DecodedElement: Decodable {
    ///     let key: String
    ///     let firstProperty: String
    ///     let secondProperty: Double
    /// }
    /// ```
    /// - Parameters:
    ///   - type: The type of the element to decode.
    ///   - data: The data to decode from.
    /// - Throws: DecodingError and FirebaseDecoder.DecodingError if data can not be decoded.
    /// - Returns: Decoded data of array of given type
    func decodeListOrThrow<T>(_ type: T.Type, _ data: Any) throws -> [T] where T: Decodable {
        guard let dict = data as? [String: Any] else { throw DecodingError.noKeyedData }
        return try dict.map { key, value in
            try decodeOrThrow(type, value, key: key)
        }
    }

    /// Decodes array of given type from firebase database data.
    /// Returns `.failure(_)` if data can not be decoded.
    ///
    /// Decodes data like this:
    /// ```json
    /// {
    ///     "firstKey": {
    ///         "firstProperty": "value",
    ///         "secondProperty": 12.5
    ///     },
    ///     ...
    /// }
    /// ```
    /// to a list with elements of type like this:
    /// ```swift
    /// struct DecodedElement: Decodable {
    ///     let key: String
    ///     let firstProperty: String
    ///     let secondProperty: Double
    /// }
    /// ```
    /// - Parameters:
    ///   - type: The type of the element to decode.
    ///   - data: The data to decode from.
    /// - Returns: Result of decoded data of array of given type or `.failure(_)` if data can not be decoded.
    func decodeListResult<T>(_ type: T.Type, _ data: Any) -> Result<[T], Error> where T: Decodable {
        Result { try decodeListOrThrow(type, data) }
    }

    /// Decodes array of given type from firebase database data.
    /// Returns nil if data can not be decoded.
    ///
    /// Decodes data like this:
    /// ```json
    /// {
    ///     "firstKey": {
    ///         "firstProperty": "value",
    ///         "secondProperty": 12.5
    ///     },
    ///     ...
    /// }
    /// ```
    /// to a list with elements of type like this:
    /// ```swift
    /// struct DecodedElement: Decodable {
    ///     let key: String
    ///     let firstProperty: String
    ///     let secondProperty: Double
    /// }
    /// ```
    /// - Parameters:
    ///   - type: The type of the element to decode.
    ///   - data: The data to decode from.
    /// - Returns: Decoded data of array of given type or nil if data can not be decoded.
    func decodeList<T>(_ type: T.Type, _ data: Any) -> [T]? where T: Decodable {
        try? decodeListOrThrow(type, data)
    }

    /// Decodes array of given unkeyed type from firebase database data.
    /// Throws error if data can not be decoded.
    ///
    /// Decodes data like this:
    /// ```json
    /// [
    ///     {
    ///         "firstProperty": "value",
    ///         "secondProperty": 12.5
    ///     },
    ///     ...
    /// ]
    /// ```
    /// to a list with elements of type like this:
    /// ```swift
    /// struct DecodedElement: Decodable {
    ///     let firstProperty: String
    ///     let secondProperty: Double
    /// }
    /// ```
    /// - Parameters:
    ///   - type: The type of the element to decode.
    ///   - data: The data to decode from.
    /// - Throws: DecodingError and FirebaseDecoder.DecodingError if data can not be decoded.
    /// - Returns: Decoded data of array of given primitive type
    func decodeUnkeyedListOrThrow<T>(_ type: T.Type, _ data: Any) throws -> [T] where T: Decodable {
        guard let list = data as? [Any] else { throw DecodingError.noList }
        return try list.map { value in
            try decodeOrThrow(type, value)
        }
    }

    /// Decodes array of given unkeyed type from firebase database data.
    /// Returns `.failure(_)` if data can not be decoded.
    ///
    /// Decodes data like this:
    /// ```json
    /// [
    ///     {
    ///         "firstProperty": "value",
    ///         "secondProperty": 12.5
    ///     },
    ///     ...
    /// ]
    /// ```
    /// to a list with elements of type like this:
    /// ```swift
    /// struct DecodedElement: Decodable {
    ///     let firstProperty: String
    ///     let secondProperty: Double
    /// }
    /// ```
    /// - Parameters:
    ///   - type: The type of the element to decode.
    ///   - data: The data to decode from.
    /// - Returns: Result of decoded data of array of given primitive type or `.failure(_)` if data can not be decoded.
    func decodeUnkeyedListResult<T>(_ type: T.Type, _ data: Any) -> Result<[T], Error> where T: Decodable {
        Result { try decodeUnkeyedListOrThrow(type, data) }
    }

    /// Decodes array of given unkeyed type from firebase database data.
    /// Returns nil if data can not be decoded.
    ///
    /// Decodes data like this:
    /// ```json
    /// [
    ///     {
    ///         "firstProperty": "value",
    ///         "secondProperty": 12.5
    ///     },
    ///     ...
    /// ]
    /// ```
    /// to a list with elements of type like this:
    /// ```swift
    /// struct DecodedElement: Decodable {
    ///     let firstProperty: String
    ///     let secondProperty: Double
    /// }
    /// ```
    /// - Parameters:
    ///   - type: The type of the element to decode.
    ///   - data: The data to decode from.
    /// - Returns: Decoded data of array of given primitive type or nil if data can not be decoded.
    func decodeUnkeyedList<T>(_ type: T.Type, _ data: Any) -> [T]? where T: Decodable {
        try? decodeUnkeyedListOrThrow(type, data)
    }
}
