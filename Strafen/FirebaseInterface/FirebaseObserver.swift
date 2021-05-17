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

    /// Level of a firebase database observe
    public var level: FirebaseDatabaseLevel = .defaultValue

    /// Shared instance for singelton
    static var shared = FirebaseObserver()

    /// Private init for singleton
    private init() {}

    /// Observes given type at firebase database
    /// - Parameters:
    ///   - type: Type of observed value
    ///   - urlFromClub: Url from club to value in firebase database
    ///   - clubId: id of club to fetch from
    ///   - changeHandler: handles data change
    ///   - removeHandler: handles data remove
    /// - Returns: Closure to remove the observer
    @discardableResult func observe<T>(_ type: T.Type, url urlFromClub: URL?, clubId: UUID, onChange changeHandler: ((T) -> Void)? = nil, onRemove removeHandler: (() -> Void)? = nil) -> () -> Void where T: Decodable {
        let url = URL(string: level.clubComponent)!
            .appendingPathComponent(clubId.uuidString)
            .appendingUrl(urlFromClub)
        let observerHandle = Database.database().reference(withPath: url.path).observe(.value) { snapshot in
            guard snapshot.exists(), let data = snapshot.value else {
                if let removeHandler = removeHandler { removeHandler() }
                return
            }
            guard let value = FirebaseDecoder.shared.decode(type, data) else { return }
            if let changeHandler = changeHandler { changeHandler(value) }
        }
        return { Database.database().reference(withPath: url.path).removeObserver(withHandle: observerHandle) }
    }

    /// Observes a list at firebase database
    /// - Parameters:
    ///   - type: Type of the list element
    ///   - event: event to observe
    ///   - clubId: id of club to fetch from
    ///   - newDataHandler: Handles new data income
    /// - Returns: Closure to remove the observer
    @discardableResult func observeList<ListType>(_ type: ListType.Type, event: DataEventType, clubId: UUID, handler newDataHandler: @escaping (ListType) -> Void) -> () -> Void where ListType: FirebaseListType {
        let url = URL(string: level.clubComponent)!
            .appendingPathComponent(clubId.uuidString)
            .appendingUrl(ListType.urlFromClub)
        let observerHandle = Database.database().reference(withPath: url.path).observe(event) { snapshot in
            guard snapshot.exists(),
                  let data = snapshot.value,
                  let value = FirebaseDecoder.shared.decode(ListType.self, data, key: snapshot.key) else { return }
            newDataHandler(value)
        }
        return { Database.database().reference(withPath: url.path).removeObserver(withHandle: observerHandle) }
    }

    /// Observes a list at firebase database
    /// - Parameters:
    ///   - type: Type of the list element
    ///   - clubId: id of club to fetch from
    ///   - changeListHandler: Handles the change of given list
    /// - Returns: Closure to remove the observer
    @discardableResult func observeList<ListType>(_ type: ListType.Type, clubId: UUID, handler changeListHandler: @escaping ((inout [ListType]) -> Void) -> Void) -> () -> Void where ListType: FirebaseListType {

        // Observes if a child was added
        let removeAddObserver = observeList(type, event: .childAdded, clubId: clubId) { newChild in
            changeListHandler {
                guard !$0.contains(where: { $0.id == newChild.id }) else { return }
                $0.append(newChild)
            }
        }

        // Observes if a child was changed
        let removeChangeObserver = observeList(type, event: .childChanged, clubId: clubId) { changedChild in
            changeListHandler {
                $0.mapped { $0.id == changedChild.id ? changedChild : $0 }
            }
        }

        // Observes if a child was removed
        let removeRemoveObserver = observeList(type, event: .childRemoved, clubId: clubId) { removedChild in
            changeListHandler {
                $0.filtered { $0.id != removedChild.id }
            }
        }

        return {
            removeAddObserver()
            removeChangeObserver()
            removeRemoveObserver()
        }
    }
}
