//
//  ListData.swift
//  Strafen
//
//  Created by Steven on 02.07.20.
//

import Foundation


/// Used to fetch List from server of the different list types.
class ListDataAppType<AppType>: ObservableObject where AppType: AppTypes {
    
    /// Cached list if fetch is already successful executed
    @Published var list: [AppType]?
    
    /// Dispatch Group to check if task is finished
    var dispatchGroup = DispatchGroup()
    
    /// Init to enter dispatch group
    init() {
        dispatchGroup.enter()
    }
    
    /// Fetch list from server.
    func fetch(from url: URL? = nil, _ failedHandler: @escaping () -> ()) {
        if list != nil { return }
        
        // Fetch list from server
        ListFetcher.shared.fetch(from: url) { (fetchedList: [AppType]?)  in
            if let fetchedList = fetchedList {
                DispatchQueue.main.async {
                    if self.list == nil {
                        self.list = fetchedList
                        self.dispatchGroup.leave()
                    }
                }
            } else {
                failedHandler()
            }
        }
    }
    
    /// Fetches list from server and handle completion 
    func getList(_ completionHandler: @escaping ([AppType]?) -> ()) {
        fetch {
            completionHandler(nil)
        }
        dispatchGroup.notify(queue: .main) {
            completionHandler(self.list)
        }
    }
}

/// Data of all list types
struct ListData {
    
    /// List data of ClubMappedClub list
    static let clubMappedClub = ListDataAppType<ClubMappedClub>()
    
    /// List data of person list
    static let person = ListDataAppType<Person>()

    /// Private init for singleton
    private init() {}
}
