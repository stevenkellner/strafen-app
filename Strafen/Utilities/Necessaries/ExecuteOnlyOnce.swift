//
//  ExecuteOnlyOnce.swift
//  Strafen
//
//  Created by Steven on 9/6/20.
//

import Foundation

/// Used to execute a task exactly one time, regardless of whether the app is closed in between.
///
/// You can't access the init function directly, instead create a static value with the identifier you want in a extension:
///
///     extension ExecuteOnlyOnce {
///
///         /// A static value for "createFile" identifer
///         static let createFile = ExecuteOnlyOnce(with: "createFile")
///     }
///
/// And use this static value to execute a task only once:
///
///     for _ in 0..<5 {
///         ExecuteOnlyOnce.createFile.execute {
///             FileManager.default.createFile(atPath: `yourFilePath`, contents: `yourContents`, attributes: `yourAttributes)
///             print("New file created")
///         }
///     }
///     // Prints only once: "New file created"
struct ExecuteOnlyOnce {
    
    /// Name of file to save if task with given identifier is already executed
    static private let fileName = "executeOnlyOnce.json"
    
    /// Identifier to differentiate tasks to execute
    private let identifier: String
    
    /// Init struct with given identifier and create file at url if not existed
    ///
    /// - Parameters:
    ///     - identifier: Identifier of task
    private init(with identifier: String) {
        self.identifier = identifier
        if !FileManager.default.fileExists(atPath: Self.url.path) {
            FileManager.default.createFile(atPath: Self.url.path, contents: "{}".data(using: .utf8))
        }
    }
    
    /// Url of file to save if task with given identifier is already executed
    static private var url: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(Self.fileName)
    }
    
    /// Gets the content from file and format it to a dictionary of String : Bool
    private var contentAsDictionary: [String : Bool] {
        let fileData = FileManager.default.contents(atPath: Self.url.path)!
        return try! JSONSerialization.jsonObject(with: fileData) as! [String : Bool]
    }
    
    /// Saves the dictionary as json in file
    ///
    /// - Parameters:
    ///     - dictionary: Dictionary to save in file
    private func saveDictionary(_ dictionary: [String : Bool]) {
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(dictionary)
        try! jsonData.write(to: Self.url, options: .atomic)
    }
    
    /// Execute the given completion only if task with this identifer is already executed and mark it as already executed
    ///
    /// - Parameters:
    ///     - completion: Completion of task to execute
    func execute(_ completion: () -> ()) {
        var contentDictionary = contentAsDictionary
        if !(contentDictionary[identifier] ?? false) {
            contentDictionary[identifier] = true
            saveDictionary(contentDictionary)
            completion()
        }
    }
    
    /// Resets task with this identifier to execute it again
    func reset() {
        var contentDictionary = contentAsDictionary
        contentDictionary[identifier] = false
        saveDictionary(contentDictionary)
    }
    
    /// Resets all task
    static func resetAll() {
        try? "{}".write(to: url, atomically: true, encoding: .utf8)
    }
}

/// Extension of ExecuteOnlyOnce to get a static value for `dailyPushNotification` identifer
extension ExecuteOnlyOnce {
    
    /// A static value for "dailyPushNotification" identifer
    static let dailyPushNotification = ExecuteOnlyOnce(with: "dailyPushNotification")
}
