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
    
    let clubUrl = URL(string: "debugClubs/041D157B-2312-484F-BB49-C1CC0DE7992F")! // TODO
    
    /// Fetches given type from firebase database
    /// - Parameters:
    ///   - type: Type of fetched value
    ///   - urlFromClub: Url from club to value in firebase database
    /// - Returns: Promise of retrieved value
    func fetch<T>(_ type: T.Type, url urlFromClub: URL) -> Promise<T> where T: Decodable {
        Promise<T> { resolve, reject, _ in
            let url = clubUrl.appendingUrl(urlFromClub)
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
    /// - Returns: Promise of retrieved list
    func fetchList<ListType>(_ type: ListType.Type) -> Promise<[ListType]> where ListType: FirebaseListType {
        Promise<[ListType]> { resolve, reject, _ in
            let url = clubUrl.appendingUrl(ListType.urlFromClub)
            Database.database().reference(withPath: url.path).observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists(), let data = snapshot.value else { return reject(FetchError.noData) }
                do {
                    resolve(try FirebaseDecoder.shared.decodeListOrThrow(ListType.self, data))
                } catch { reject(error) }
            }
        }
    }
}
