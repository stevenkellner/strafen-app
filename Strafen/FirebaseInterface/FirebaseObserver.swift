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
    
    /// Observes given type at firebase database
    /// - Parameters:
    ///   - type: Type of observed value
    ///   - urlFromClub: Url from club to value in firebase database
    ///   - level: level of firebase function call
    ///   - clubId: id of club to fetch from
    ///   - newDataHandler: Handles new data income
    func observe<T>(_ type: T.Type, url urlFromClub: URL?, level: FirebaseDatabaseLevel, clubId: UUID, handler newDataHandler: @escaping (T) -> Void) where T: Decodable {
        let url = URL(string: level.clubComponent)!
            .appendingPathComponent(clubId.uuidString)
            .appendingUrl(urlFromClub)
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
    ///   - event: event to observe
    ///   - level: level of firebase function call
    ///   - clubId: id of club to fetch from
    ///   - newDataHandler: Handles new data income
    func observeList<ListType>(_ type: ListType.Type, event: DataEventType, level: FirebaseDatabaseLevel, clubId: UUID, handler newDataHandler: @escaping (ListType) -> Void) where ListType: FirebaseListType {
        let url = URL(string: level.clubComponent)!
            .appendingPathComponent(clubId.uuidString)
            .appendingUrl(ListType.urlFromClub)
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
    ///   - level: level of firebase function call
    ///   - clubId: id of club to fetch from
    ///   - changeListHandler: Handles the change of given list
    func observeList<ListType>(_ type: ListType.Type, level: FirebaseDatabaseLevel, clubId: UUID, handler changeListHandler: @escaping ((inout Array<ListType>) -> Void) -> Void) where ListType: FirebaseListType {
        
        // Observes if a child was added
        observeList(type, event: .childAdded, level: level, clubId: clubId) { newChild in
            changeListHandler {
                guard !$0.contains(where: { $0.id == newChild.id }) else { return }
                $0.append(newChild)
            }
        }
        
        // Observes if a child was changed
        observeList(type, event: .childChanged, level: level, clubId: clubId) { changedChild in
            changeListHandler {
                $0.mapped { $0.id == changedChild.id ? changedChild : $0 }
            }
        }
        
        // Observes if a child was removed
        observeList(type, event: .childRemoved, level: level, clubId: clubId) { removedChild in
            changeListHandler {
                $0.filtered { $0.id != removedChild.id }
            }
        }
    }
}
