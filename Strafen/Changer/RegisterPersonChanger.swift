//
//  RegisterPersonChanger.swift
//  Strafen
//
//  Created by Steven on 04.07.20.
//

import Foundation

/// Used to register a new person on server
struct RegisterPersonChanger {
    
    /// Shared instance for singelton
    static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    /// Create new club on server
    func registerPerson(_ person: RegisterPerson) {
        
        // Get POST parameters
        var parameters = person.parameters
        parameters["key"] = AppUrls.shared.key
        
        // Url Request
        var request = URLRequest(url: AppUrls.shared.changer.registerPerson)
        request.setValue("Basic \(AppUrls.shared.loginString)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = parameters.percentEncoded
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        // Execute dataTask
        URLSession.shared.dataTask(with: request) { _, _, _ in }.resume()
    }
}
