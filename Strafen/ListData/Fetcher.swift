//
//  Fetcher.swift
//  Strafen
//
//  Created by Steven on 11/7/20.
//

import SwiftUI
import FirebaseDatabase
import CodableFirebase

/// Fetches list from database
struct Fetcher {
    
    #if TARGET_MAIN_APP
    /// Data event type set with childAdded, childChanged, childRemoved
    struct DataEventTypeSet: OptionSet {
        
        /// Raw value
        let rawValue: Int

        /// Child was addedy
        static let childAdded = DataEventTypeSet(rawValue: 1 << 0)
        
        /// Child was changed
        static let childChanged = DataEventTypeSet(rawValue: 1 << 1)
        
        /// Child was removed
        static let childRemoved = DataEventTypeSet(rawValue: 1 << 2)
        
        /// All
        static let all: DataEventTypeSet = [.childAdded, .childChanged, .childRemoved]
    }
    #endif
    
    /// Shared instance for singelton
    static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    /// Fetches a list of list type from database
    func fetch<Type>(from url: URL = Type.url, wait waitingTime: Double? = nil, completion completionHandler: @escaping ([Type]?) -> Void) where Type: ListTypeGet {
        
        /// Indicates if task should be executed
        var executeTask = true
        
        // Set execute task to false after waiting time is expired
        if let waitingTime = waitingTime {
            DispatchQueue.main.asyncAfter(deadline: .now() + waitingTime) {
                executeTask = false
                completionHandler(nil)
            }
        }
        
        // Fetch data from database
        Database.database().reference(withPath: url.path).observeSingleEvent(of: .value) { snapshot in
            guard executeTask else { return }
            guard snapshot.exists(), let data = snapshot.value else { return completionHandler([]) }
            let list: [Type]? = decodeFetchedList(from: data)
            completionHandler(list)
        }
        
    }
    
    /// Decodes fetched data from database to list
    private func decodeFetchedList<Type>(from data: Any) -> [Type]? where Type: ListTypeGet {
        let decoder = FirebaseDecoder()
        let dictionary = try? decoder.decode(Dictionary<String, Type.CodableSelf>.self, from: data)
        let list = dictionary.map { dictionary in
            dictionary.map { idString, item -> Type in
                let id = Type.ID(rawId: idString)
                return Type.init(with: id, codableSelf: item)
            }
        }
        return list
    }
    
    #if TARGET_MAIN_APP
    /// Observe a list of database and change local list if database list changed
    func observe<Type>(of url: URL, eventTypes: DataEventTypeSet = .all, list listBinding: Binding<[Type]?>) where Type: ListType {
        observeChildAdded(of: url) {
            listBinding.wrappedValue
        } onChange: { changedList in
            listBinding.wrappedValue = changedList
        }
    }
    
    /// Observe a list of database and change local list if database list changed
    func observe<Type>(of url: URL, eventTypes: DataEventTypeSet = .all, getList: @escaping () -> [Type]?, onChange changeHandler: @escaping ([Type]?) -> Void) where Type: ListType {
        if eventTypes.contains(.childAdded) {
            observeChildAdded(of: url, getList: getList, onChange: changeHandler)
        }
        if eventTypes.contains(.childChanged) {
            observeChildChanged(of: url, getList: getList, onChange: changeHandler)
        }
        if eventTypes.contains(.childRemoved) {
            observeChildRemove(of: url, getList: getList, onChange: changeHandler)
        }
    }
    
    /// Observe a list of database if a child was added and change local list
    private func observeChildAdded<Type>(of url: URL, getList: @escaping () -> [Type]?, onChange changeHandler: @escaping ([Type]?) -> Void) where Type: ListType {
        Database.database().reference(withPath: url.path).observe(.childAdded) { snapshot in
            guard let data = snapshot.value else { return }
            if let item: Type = decodeFetchedItem(from: data, key: snapshot.key) {
                guard var list = getList() else { return }
                if list.contains(where: { $0.id == item.id }) {
                    list.mapped { $0.id == item.id ? item : $0 }
                } else {
                    list.append(item)
                }
                changeHandler(list)
            }
        }
    }
    
    /// Observe a list of database if a child was changed and change local list
    private func observeChildChanged<Type>(of url: URL, getList: @escaping () -> [Type]?, onChange changeHandler: @escaping ([Type]?) -> Void) where Type: ListType {
        Database.database().reference(withPath: url.path).observe(.childChanged) { snapshot in
            guard let data = snapshot.value else { return }
            if let item: Type = decodeFetchedItem(from: data, key: snapshot.key) {
                var list = getList()
                list?.mapped { $0.id == item.id ? item : $0 }
                changeHandler(list)
            }
        }
    }
    
    /// Observe a list of database if a child was removed and change local list
    private func observeChildRemove<Type>(of url: URL, getList: @escaping () -> [Type]?, onChange changeHandler: @escaping ([Type]?) -> Void) where Type: ListType {
        Database.database().reference(withPath: url.path).observe(.childRemoved) { snapshot in
            var list = getList()
            let id = Type.ID(rawId: snapshot.key)
            list?.filtered { $0.id != id }
            changeHandler(list)
        }
    }
    
    /// Decodes fetched data from database to list type item
    private func decodeFetchedItem<Type>(from data: Any, key: String) -> Type? where Type: ListType {
        let decoder = FirebaseDecoder()
        guard let item = try? decoder.decode(Type.CodableSelf.self, from: data) else { return nil }
        let id = Type.ID(rawId: key)
        return Type.init(with: id, codableSelf: item)
    }
    #endif
}
