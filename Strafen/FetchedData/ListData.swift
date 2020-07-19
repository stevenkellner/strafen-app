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
    
    /// Dispatch Group to check if task is finished
    var dispatchGroup = DispatchGroup()
    
    /// Number dispathGroup enterned
    var numberDispathes = 1
    
    /// Init to enter dispatch group
    init() {
        dispatchGroup.enter()
    }
    
    /// Fetch list from server.
    func fetch(from url: URL? = nil, completionHandler: (() -> ())? = nil, failedHandler: @escaping () -> ()) {
        if list != nil {
            if let completionHandler = completionHandler { completionHandler() }
            return
        }
        if numberDispathes == 0 {
            dispatchGroup.enter()
            numberDispathes += 1
        }
        
        // Fetch list from server
        ListFetcher.shared.fetch(from: url) { [self] (fetchedList: [ListType]?)  in
            if let fetchedList = fetchedList {
                DispatchQueue.main.async {
                    if list == nil {
                        list = fetchedList
                        dispatchGroup.leave()
                        numberDispathes -= 1
                        if let completionHandler = completionHandler { completionHandler() }
                    }
                }
            } else {
                failedHandler()
            }
        }
    }
    
    /// Fetches list from server and handle completion 
    func getList(_ completionHandler: @escaping ([ListType]?) -> ()) {
        fetch {
            completionHandler(nil)
        }
        dispatchGroup.notify(queue: .main) {
            completionHandler(self.list)
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
