//
//  DataTypeList.swift
//  Strafen
//
//  Created by Steven on 11/7/20.
//

import Foundation

/// Used to fetch list from database of the different list types.
class DataTypeList<Type>: ObservableObject where Type: ListType {
    
    /// List if fetch is already successful executed
    @Published var list: [Type]?
    
    /// Fetch list from database
    func fetch(passedHandler: @escaping () -> Void, failedHandler: @escaping () -> Void) {
        Fetcher.shared.fetch(from: Type.url) { [weak self] (fetchedList: [Type]?) in
            DispatchQueue.main.async {
                if let fetchedList = fetchedList {
                    self?.list = fetchedList
                    passedHandler()
                } else {
                    failedHandler()
                }
            }
        }
    }
    
    #if TARGET_MAIN_APP
    /// Observe a list on database
    func observe() {
        Fetcher.shared.observe(of: Type.url) { [weak self] in
            self?.list
        } onChange: { [weak self] changedList in
            DispatchQueue.main.async {
                self?.list = changedList
            }
        }
    }
    #endif
}
