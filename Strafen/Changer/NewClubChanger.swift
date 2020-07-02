//
//  NewClubChanger.swift
//  Strafen
//
//  Created by Steven on 01.07.20.
//

import Foundation

/// Used to create a new club on server
struct NewClubChanger {
    
    /// Contains all properties for a new club
    struct Club {
        
        /// Id of the club
        let clubId: UUID
        
        /// Name of the club
        let clubName: String
        
        /// Id of the person
        let personId: UUID
        
        /// Name of the person
        let personName: PersonName
        
        /// Contains all properties for the login
        let login: PersonLogin
        
        /// POST parameters
        var parameters: [String : Any] {
            var parameters: [String : Any] = [
                "clubId": clubId,
                "clubName": clubName,
                "personId": personId
            ]
            parameters.merge(personName.parameters) { firstValue, _ in firstValue }
            parameters.merge(login.parameters) { firstValue, _ in firstValue }
            return parameters
        }
    }
    
    /// Shared instance for singelton
    static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    /// Create new club on server
    func createNewClub(_ club: Club) {
        
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

/// Contains all properties for the login
protocol PersonLogin {
    
    /// POST parameters
    var parameters: [String : Any] { get }
}

/// Contains all properties for the login with apple
struct PersonLoginApple: PersonLogin {
    
    /// Idetifier from apple
    let appleIdentifier: String
    
    /// POST parameters
    var parameters: [String : Any] {
        ["apple": appleIdentifier]
    }
}

/// Contains all properties for the login with email
struct PersonLoginEmail: PersonLogin {
    
    /// Email
    let email: String
    
    /// Password
    let password: String
    
    /// POST parameters
    var parameters: [String : Any] {
        [
            "email": email,
            "password": password.encrypted
        ]
    }
}
