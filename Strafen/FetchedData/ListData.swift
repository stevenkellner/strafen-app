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
            DispatchQueue.main.async {
                if let fetchedList = fetchedList {
                    if list == nil {
                        list = fetchedList
                        if let completionHandler = completionHandler { completionHandler() }
                    }
                } else {
                    failedHandler()
                }
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
class ListData: ObservableObject {
    
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
    
    /// Shared instace for singleton
    static let shared = ListData()

    /// Private init for singleton
    private init() {}
    
    /// Connection state for list fetching
    @Published var connectionState: ConnectionState = .loading
    
    /// Person is force signed out
    @Published var forceSignedOut = false
    
    /// Fetch all list data
    func fetchLists() {
        
        connectionState = .loading
        
        // Reset lists
        ListData.person.list = nil
        ListData.reason.list = nil
        ListData.fine.list = nil
        ListData.club.list = nil
        
        // Enter DispathGroup
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        dispatchGroup.enter()
        dispatchGroup.enter()
        dispatchGroup.enter()
        
        // Fetch person list
        ListData.person.fetch {
            dispatchGroup.leave()
        } failedHandler: {
            self.connectionState = .failed
        }
        
        // Fetch reason list
        ListData.reason.fetch {
            dispatchGroup.leave()
        } failedHandler: {
            self.connectionState = .failed
        }
        
        // Fetch fine list
        ListData.fine.fetch {
            dispatchGroup.leave()
        } failedHandler: {
            self.connectionState = .failed
        }
        
        // Fetch club list
        ListData.club.fetch {
            dispatchGroup.leave()
        } failedHandler: {
            self.connectionState = .failed
        }
        
        // Notify dispath group
        dispatchGroup.notify(queue: .main) {
            let person = Settings.shared.person
            guard ListData.club.list!.first(where: { $0.id == person?.clubId })?.allPersons.contains(where: { $0.id == person?.id }) ?? false else {
                return self.forceSignedOut = true
            }
            Settings.shared.latePaymentInterest = ListData.club.list?.first(where: { club in
                Settings.shared.person?.clubId == club.id
            })?.latePaymentInterest
            self.connectionState = .passed
        }
    }
}

/// State of internet connection
enum ConnectionState {
    
    /// Still loading
    case loading
    
    /// No connection
    case failed
    
    /// All loaded
    case passed
}

/// State of data task
enum TaskState {
    
    /// Data task passed
    case passed
    
    /// Data task failed
    case failed
}
