//
//  ListChanger.swift
//  Strafen
//
//  Created by Steven on 21.07.20.
//

import SwiftUI

/// Changes server lists (person, reason, fine)
struct ListChanger {
    
    /// State of data task
    enum TaskState {
        
        /// Data task passed
        case passed
        
        /// Data task failed
        case failed
    }
    
    /// Type ot the change
    enum ChangeType: String {
        
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
    
    /// Change cached and server list
    func change<ListType>(_ changeType: ChangeType, item: ListType, completionHandler: @escaping (TaskState) -> ()) where ListType: ListTypes {
        changeServer(changeType, item: item) { taskState in
            if taskState == .passed {
                changeCached(changeType, item: item)
            }
            completionHandler(taskState)
        }
    }
    
    /// Change cached list
    private func changeCached<ListType>(_ changeType: ChangeType, item: ListType) where ListType: ListTypes {
        DispatchQueue.main.async {
            withAnimation {
                switch changeType {
                case .add where !ListType.listData.list!.contains(where: { $0.id == item.id }):
                    ListType.listData.list!.append(item)
                case .update:
                    ListType.listData.list!.mapped { $0.id == item.id ? item : $0 }
                case .delete:
                    ListType.listData.list!.filtered { $0.id != item.id }
                default:
                    break
                }
            }
        }
    }
    
    /// Change server list
    private func changeServer<ListType>(_ changeType: ChangeType, item: ListType, completionHandler: @escaping (TaskState) -> ()) where ListType: ListTypes {
        
        // Get POST parameters
        guard var parameters = item.postParameters, let changerUrlPath = ListType.changerUrl else {
            fatalError("\(ListType.self) can't be changed")
        }
        parameters["key"] = AppUrls.shared.key
        parameters["change"] = changeType.rawValue
        parameters["clubId"] = Settings.shared.person!.clubId
        
        // Create Url request
        var request = URLRequest(url: AppUrls.shared[keyPath: changerUrlPath])
        request.setValue("Basic \(AppUrls.shared.loginString)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = parameters.percentEncoded
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        // Execute data task
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard error == nil else { return completionHandler(.failed) }
            guard let data = data else { return completionHandler(.failed) }
            completionHandler(String(data: data, encoding: .utf8) ?? "" == "success" ? .passed : .failed)
        }.resume()
    }
}
