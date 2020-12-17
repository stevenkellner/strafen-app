//
//  DataTypeList.swift
//  Strafen
//
//  Created by Steven on 11/7/20.
//

import Foundation

/// Used to fetch list from database of the different list types.
class DataTypeList<DataListType>: ObservableObject where DataListType: ListType {
    
    /// List if fetch is already successful executed
    @Published var list: [DataListType]?
    
    /// Fetch list from database
    func fetch(passedHandler: @escaping () -> Void, failedHandler: @escaping () -> Void) {
        guard list == nil else { return passedHandler() }
        Fetcher.shared.fetch(from: DataListType.url) { [weak self] (fetchedList: [DataListType]?) in
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
        Fetcher.shared.observe(of: DataListType.url) { [weak self] in
            self?.list
        } onChange: { [weak self] changedList in
            DispatchQueue.main.async {
                self?.list = changedList
            }
        }
    }
}
