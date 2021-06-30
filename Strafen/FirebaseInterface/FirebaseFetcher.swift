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

        /// Path couldn't be converted to an url
        case invalidPath
    }

    /// Fetches data from firebase database
    /// - Parameters:
    ///   - urlFromClub: url from club to value in firebase database
    ///   - clubId: id of club to fetch from
    /// - Returns: Retrived data
    private func fetch(url urlFromClub: URL?, clubId: Club.ID) async throws -> Any {
        let url = URL(string: level.clubComponent)!
            .appendingPathComponent(clubId.uuidString)
            .appendingUrl(urlFromClub)
        return try await withCheckedThrowingContinuation { contination in
            Database.database().reference(withPath: url.path).observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists(), let data = snapshot.value else {
                    return contination.resume(throwing: FetchError.noData)
                }
                contination.resume(returning: data)
            }
        }
    }

    /// Fetches given type from firebase database
    /// - Parameters:
    ///   - type: type of fetched value
    ///   - urlFromClub: url from club to value in firebase database
    ///   - clubId: id of club to fetch from
    /// - Returns: Retrieved value
    func fetch<T>(_ type: T.Type = T.self, url urlFromClub: URL?, clubId: Club.ID) async throws -> T where T: Decodable {
        let data = try await fetch(url: urlFromClub, clubId: clubId)
        return try FirebaseDecoder.shared.decodeOrThrow(type, data)
    }

    /// Fetches given type from firebase database
    /// - Parameters:
    ///   - type: type of fetched value
    ///   - pathFromClub: path from club to value in firebase database
    ///   - clubId: id of club to fetch from
    /// - Returns: Retrieved value
    func fetch<T>(_ type: T.Type = T.self, path pathFromClub: String, clubId: Club.ID) async throws -> T where T: Decodable {
        guard let urlFromClub = URL(string: pathFromClub) else { throw FetchError.invalidPath }
        let data = try await fetch(url: urlFromClub, clubId: clubId)
        return try FirebaseDecoder.shared.decodeOrThrow(type, data)
    }

    /// Fetches a list from firebase database
    /// - Parameters:
    ///   - type: type of the list element
    ///   - clubId: id of club to fetch from
    /// - Returns: Retrieved list
    func fetchList<ListType>(_ type: ListType.Type = ListType.self, clubId: Club.ID) async throws -> [ListType] where ListType: FirebaseListType {
        do {
            let data = try await fetch(url: ListType.urlFromClub, clubId: clubId)
            return try FirebaseDecoder.shared.decodeListOrThrow(type, data)
        } catch FetchError.noData { return [] }
    }

    /// Fetches a list of statistic with max specified number from firebase database
    /// - Parameters:
    ///   - clubId: id of the club to fetch from
    ///   - beforeStartValue: fetches only statistics with timestamp older than specified value
    ///   - numberQuery: maximum number of element in fetched list
    /// - Returns: Retrieved statistics list
    func fetchStatistics(clubId: Club.ID, before beforeStartValue: FirebaseStatistic?, number numberQuery: UInt) async throws -> [FirebaseStatistic] {
        let url = URL(string: level.clubComponent)!
            .appendingPathComponent(clubId.uuidString)
            .appendingUrl(FirebaseStatistic.urlFromClub)
        return try await withCheckedThrowingContinuation { continuation in
            Database.database().reference(withPath: url.path)
                .queryOrdered(byChild: "timestamp")
                .queryEnding(beforeValue: (beforeStartValue?.timestamp ?? Date()).timeIntervalSince1970 * 1000 - 1, childKey: "timestamp")
                .queryLimited(toLast: numberQuery)
                .observeSingleEvent(of: .value) { snapshot in
                    guard snapshot.exists(), let data = snapshot.value else { return continuation.resume(returning: []) }
                    do {
                        let list = try FirebaseDecoder.shared.decodeListOrThrow(FirebaseStatistic.self, data).sorted(order: .descanding, by: \.timestamp)
                        continuation.resume(returning: list)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}
