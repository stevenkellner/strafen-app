//
//  FirebaseFetcher.swift
//  Strafen
//
//  Created by Steven on 04.05.21.
//

import Foundation
import FirebaseDatabase

/// Fetches data from firebase database
@MainActor struct FirebaseFetcher {

    /// Level of a firebase database fetch
    public var level: FirebaseDatabaseLevel = .defaultValue

    /// Shared instance for singelton
    static var shared = FirebaseFetcher()

    /// Private init for singleton
    private init() {}

    /// An error that occurs during fetching
    enum FetchError: Error {

        /// No data exists in retrieving snapshot
        case noData
    }

    /// Fetches given type from firebase database
    /// - Parameters:
    ///   - type: Type of fetched value
    ///   - urlFromClub: Url from club to value in firebase database
    ///   - clubId: id of club to fetch from
    /// - Returns: Retrieved value
    func fetch<T>(_ type: T.Type, url urlFromClub: URL?, clubId: Club.ID) async throws -> T where T: Decodable {
        let url = URL(string: level.clubComponent)!
            .appendingPathComponent(clubId.uuidString)
            .appendingUrl(urlFromClub)
        return try await withCheckedThrowingContinuation { contination in
            Database.database().reference(withPath: url.path).observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists(), let data = snapshot.value else {
                    return contination.resume(throwing: FetchError.noData)
                }
                let decodedResult = FirebaseDecoder.shared.decodeResult(type, data)
                contination.resume(with: decodedResult)
            }
        }
    }

    /// Fetches a list from firebase database
    /// - Parameter type: Type of the list element
    /// - Parameters:
    ///   - clubId: id of club to fetch from
    /// - Returns: Retrieved list
    func fetchList<ListType>(_ type: ListType.Type, clubId: Club.ID) async throws -> [ListType] where ListType: FirebaseListType {
        let url = URL(string: level.clubComponent)!
            .appendingPathComponent(clubId.uuidString)
            .appendingUrl(ListType.urlFromClub)
        return try await withCheckedThrowingContinuation { contination in
            Database.database().reference(withPath: url.path).observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists(), let data = snapshot.value else {
                    return contination.resume(returning: [])
                }
                let decodedResult = FirebaseDecoder.shared.decodeListResult(type, data)
                contination.resume(with: decodedResult)
            }
        }
    }
}
