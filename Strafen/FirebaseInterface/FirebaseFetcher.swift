//
//  FirebaseFetcher.swift
//  Strafen
//
//  Created by Steven on 04.05.21.
//

import Foundation
import FirebaseDatabase
import Hydra

/// Fetches data from firebase database
struct FirebaseFetcher {
    
    /// Shared instance for singelton
    static let shared = FirebaseFetcher()
    
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
    ///   - level: level of firebase function call
    ///   - clubId: id of club to fetch from
    /// - Returns: Promise of retrieved value
    func fetch<T>(_ type: T.Type, url urlFromClub: URL?, level: FirebaseDatabaseLevel, clubId: UUID) -> Promise<T> where T: Decodable {
        Promise<T>(in: .main) { resolve, reject, _ in
            let url = URL(string: level.clubComponent)!
                .appendingPathComponent(clubId.uuidString)
                .appendingUrl(urlFromClub)
            Database.database().reference(withPath: url.path).observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists(), let data = snapshot.value else { return reject(FetchError.noData) }
                do {
                    resolve(try FirebaseDecoder.shared.decodeOrThrow(type, data))
                } catch { reject(error) }
            }
        }
    }
    
    /// Fetches a list from firebase database
    /// - Parameter type: Type of the list element
    /// - Parameters:
    ///   - level: level of firebase function call
    ///   - clubId: id of club to fetch from
    /// - Returns: Promise of retrieved list
    func fetchList<ListType>(_ type: ListType.Type, level: FirebaseDatabaseLevel, clubId: UUID) -> Promise<[ListType]> where ListType: FirebaseListType {
        Promise<[ListType]>(in: .main) { resolve, reject, _ in
            let url = URL(string: level.clubComponent)!
                .appendingPathComponent(clubId.uuidString)
                .appendingUrl(ListType.urlFromClub)
            Database.database().reference(withPath: url.path).observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists(), let data = snapshot.value else { return reject(FetchError.noData) }
                do {
                    resolve(try FirebaseDecoder.shared.decodeListOrThrow(ListType.self, data))
                } catch { reject(error) }
            }
        }
    }
}
