//
//  NewClubChanger.swift
//  Strafen
//
//  Created by Steven on 01.07.20.
//

import Foundation

/// Used to create a new club on server
struct NewClubChanger {
    
    /// Shared instance for singelton
    static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    /// Create new club on server
    func createNewClub(_ club: ChangerClub) {
        
        // Get POST parameters
        var parameters = club.parameters
        parameters["key"] = AppUrls.shared.key
        
        // Url Request
        var request = URLRequest(url: AppUrls.shared.changer.newClub)
        request.setValue("Basic \(AppUrls.shared.loginString)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = parameters.percentEncoded
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        // Execute dataTask
        URLSession.shared.dataTask(with: request) { _, _, _ in }.resume()
    }
}
