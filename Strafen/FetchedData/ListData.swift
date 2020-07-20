//
//  ListData.swift
//  Strafen
//
//  Created by Steven on 02.07.20.
//

import Foundation

/// Used to fetch List from server of the different list types.
class ListDataListType<ListType>: ObservableObject where ListType: ListTypes {
    
    /// Cached list if fetch is already successful executed
    @Published var list: [ListType]?
    
    /// Fetch list from server.
    func fetch(from url: URL? = nil, completionHandler: (() -> ())? = nil, failedHandler: @escaping () -> ()) {
        if list != nil {
            if let completionHandler = completionHandler { completionHandler() }
            return
        }
        
        // Fetch list from server
        ListFetcher.shared.fetch(from: url) { [self] (fetchedList: [ListType]?)  in
            if let fetchedList = fetchedList {
                DispatchQueue.main.async {
                    if list == nil {
                        list = fetchedList
                        if let completionHandler = completionHandler { completionHandler() }
                    }
                }
            } else {
                failedHandler()
            }
        }
    }
}

/// Used to fetch List from local of the different local list types.
class ListDataLocalListType<LocalListType>: ObservableObject where LocalListType: LocalListTypes {
    
    /// Cached list if fetch is already successful executed
    @Published var list: [LocalListType]?
    
    /// Fetch list from local
    func fetch(completionHandler: (() -> ())? = nil) {
        if list != nil {
            if let completionHandler = completionHandler { completionHandler() }
            return
        }
        ListFetcher.shared.fetchLocal { (fetchedList: [LocalListType]) in
            DispatchQueue.main.async {
                self.list = fetchedList
                if let completionHandler = completionHandler { completionHandler() }
            }
        }
    }
}

/// Data of all list types
struct ListData {
    
    /// List data of club list
    static let club = ListDataListType<Club>()
    
    /// List data of person list
    static let person = ListDataListType<Person>()
    
    /// List data of reason list
    static let reason = ListDataListType<Reason>()
    
    /// List data of fine list
    static let fine = ListDataListType<Fine>()
    
    /// List data of notes list
    static let note = ListDataLocalListType<Note>()

    /// Private init for singleton
    private init() {}
}
