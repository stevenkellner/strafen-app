//
//  Changer.swift
//  Strafen
//
//  Created by Steven on 9/18/20.
//

import Foundation

/// Changer
struct Changer {
    
    /// Shared instance for singelton
    static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    /// Change given item on server and local
    func change(_ item: Changeable, passedHandler: @escaping () -> Void, failedHandler: @escaping () -> Void) {
        let url = AppUrls.shared[keyPath: item.urlPath]
        let request = URLRequest(url: url, body: item.body, boundaryId: item.boundaryId)
        URLSession.shared.dataTask(with: request) { taskState in
            DispatchQueue.main.async {
                if taskState == .passed {
                    item.changeCached()
                    passedHandler()
                } else {
                    failedHandler()
                }
            }
        }
    }
}

/// Can be changed with Changer struct
protocol Changeable {
    
    /// Path from AppUrls to changer url
    var urlPath: KeyPath<AppUrls, URL> { get }
    
    /// http body
    var body: Data? { get }
    
    /// Boundary id
    var boundaryId: UUID? { get }
    
    /// Change cached
    func changeCached()
}

// Extension of Changeable for default boundaryId and change cached
extension Changeable {
    
    /// Boundary id
    var boundaryId: UUID? { nil }
    
    /// Change chached
    func changeCached() {}
}

/// Type of the change
enum ChangeType: String {
    
    /// Adds item
    case add
    
    /// Updates item
    case update
    
    /// Deletes item
    case delete
}

/// State of data task
enum TaskState {
    
    /// Data task passed
    case passed
    
    /// Data task failed
    case failed
}
