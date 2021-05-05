//
//  FirebaseObserver.swift
//  Strafen
//
//  Created by Steven on 04.05.21.
//

import Foundation
import FirebaseDatabase

/// Observers data from firebase database
struct FirebaseObserver {
    
    /// Shared instance for singelton
    static let shared = FirebaseObserver()
    
    /// Private init for singleton
    private init() {}
    
    let clubUrl = URL(string: "debugClubs/041D157B-2312-484F-BB49-C1CC0DE7992F")! // TODO
    
    /// Observes given type at firebase database
    /// - Parameters:
    ///   - type: Type of observed value
    ///   - urlFromClub: Url from club to value in firebase database
    ///   - newDataHandler: Handles new data income
    func observe<T>(_ type: T.Type, url urlFromClub: URL, handler newDataHandler: @escaping (T) -> Void) where T: Decodable {
        let url = clubUrl.appendingUrl(urlFromClub)
        Database.database().reference(withPath: url.path).observe(.value) { snapshot in
            guard snapshot.exists(),
                  let data = snapshot.value,
                  let value = FirebaseDecoder.shared.decode(type, data) else { return }
            newDataHandler(value)
        }
    }
    
    /// Observes a list at firebase database
    /// - Parameters:
    ///   - type: Type of the list element
    ///   - newDataHandler: Handles new data income
    func observeList<ListType>(_ type: ListType.Type, event: DataEventType, handler newDataHandler: @escaping (ListType) -> Void) where ListType: FirebaseListType {
        let url = clubUrl.appendingUrl(ListType.urlFromClub)
        Database.database().reference(withPath: url.path).observe(event) { snapshot in
            guard snapshot.exists(),
                  let data = snapshot.value,
                  let value = FirebaseDecoder.shared.decode(ListType.self, data, key: snapshot.key) else { return }
            newDataHandler(value)
        }
    }
    
    /// Observes a list at firebase database
    /// - Parameters:
    ///   - type: Type of the list element
    ///   - changeListHandler: Handles the change of given list
    func observeList<ListType>(_ type: ListType.Type, handler changeListHandler: @escaping ((inout Array<ListType>) -> Void) -> Void) where ListType: FirebaseListType {
        
        // Observes if a child was added
        observeList(type, event: .childAdded) { newChild in
            changeListHandler {
                guard !$0.contains(where: { $0.id == newChild.id }) else { return }
                $0.append(newChild)
            }
        }
        
        // Observes if a child was changed
        observeList(type, event: .childChanged) { changedChild in
            changeListHandler {
                $0.mapped { $0.id == changedChild.id ? changedChild : $0 }
            }
        }
        
        // Observes if a child was removed
        observeList(type, event: .childRemoved) { removedChild in
            changeListHandler {
                $0.filtered { $0.id != removedChild.id }
            }
        }
    }
}
