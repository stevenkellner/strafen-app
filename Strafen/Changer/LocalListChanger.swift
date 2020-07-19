//
//  LocalListChanger.swift
//  Strafen
//
//  Created by Steven on 19.07.20.
//

import Foundation

/// Changes local lists (notes)
struct LocalListChanger {
    
    /// Type ot the change
    enum ChangeType {
        
        /// Add a new element to the list
        case add
        
        /// Updates an existing element in the list
        case update
        
        /// Deletes an existing element in the list
        case delete
    }
    
    /// Shared instance for singelton
    static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    /// Change cached and local list
    func change<LocalListType>(_ changeType: ChangeType, item: LocalListType) where LocalListType: LocalListTypes {
        changeCached(changeType, item: item)
        changeLocal(changeType, item: item)
    }
    
    /// Change cached list
    private func changeCached<LocalListType>(_ changeType: ChangeType, item: LocalListType) where LocalListType: LocalListTypes {
        switch changeType {
        case .add:
            LocalListType.listData.list!.append(item)
        case .update:
            LocalListType.listData.list!.mapped { $0.id == item.id ? item : $0 }
        case .delete:
            LocalListType.listData.list!.filtered { $0.id != item.id }
        }
    }
    
    /// Change local list
    private func changeLocal<LocalListType>(_ changeType: ChangeType, item: LocalListType) where LocalListType: LocalListTypes {
        
        /// Get file content
        var list: [LocalListType]!
        ListFetcher.shared.fetchLocal { (fetchedList: [LocalListType]) in
            list = fetchedList
        }
        
        /// Change list
        switch changeType {
        case .add:
            list.append(item)
        case .update:
            list.mapped { $0.id == item.id ? item : $0 }
        case .delete:
            list.filtered { $0.id != item.id }
        }
        
        /// Encode to Json and write to file
        let encoder = JSONEncoder()
        let data = try! encoder.encode(list!)
        try! data.write(to: AppUrls.shared[keyPath: LocalListType.localListUrl], options: .atomic)
    }
}
