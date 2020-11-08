//
//  DataTypeList.swift
//  Strafen
//
//  Created by Steven on 11/7/20.
//

import Foundation

/// Used to fetch list from database of the different list types.
class DataTypeList<ListType>: ObservableObject where ListType: NewListType {
    
    /// List if fetch is already successful executed
    @Published var list: [ListType]?
    
    /// Fetch list from database
    func fetch(passedHandler: @escaping () -> Void, failedHandler: @escaping () -> Void) {
        guard list == nil else { return passedHandler() }
        NewFetcher.shared.fetch(from: ListType.url) { [weak self] (fetchedList: [ListType]?) in
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
    
    /// Observe a list on database
    func observe() {
        NewFetcher.shared.observe(of: ListType.url) { [weak self] in
            self?.list
        } onChange: { [weak self] changedList in
            DispatchQueue.main.async {
                self?.list = changedList
            }
        }
    }
}
