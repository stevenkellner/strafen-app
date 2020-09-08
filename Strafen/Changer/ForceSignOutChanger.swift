//
//  ForceSignOutChanger.swift
//  Strafen
//
//  Created by Steven on 9/7/20.
//

import Foundation

/// Used to force sign out a person
struct ForceSignOutChanger {
    
    /// Shared instance for singelton
    static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    /// Change force sign out of a person at server and local
    func change(of personId: UUID, completionHandler: @escaping (TaskState) -> Void) {
        changeServer(of: personId) { taskState in
            DispatchQueue.main.async {
                if taskState == .passed {
                    changeLocal(of: personId)
                }
                completionHandler(taskState)
            }
        }
    }
    
    /// Change force sign out of a person local
    private func changeLocal(of personId: UUID) {
        var club = ListData.club.list!.first(where: { $0.id == Settings.shared.person!.clubId })!
        club.allPersons.filtered({ $0.id != personId })
        ListData.club.list!.filtered({ $0.id != Settings.shared.person!.clubId })
        ListData.club.list!.append(club)
    }
    
    /// Change force sign out of a person at server
    private func changeServer(of personId: UUID, completionHandler: @escaping (TaskState) -> Void) {
        
        // Get POST parameters
        let parameters: [String : Any] = [
            "key": AppUrls.shared.key,
            "clubId": Settings.shared.person!.clubId.uuidString,
            "personId": personId.uuidString
        ]
        
        // Url Request
        var request = URLRequest(url: AppUrls.shared.changer.forceSignOut)
        request.setValue("Basic \(AppUrls.shared.loginString)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = parameters.percentEncoded
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        // Execute dataTask
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else { return completionHandler(.failed) }
            print(String(data: data, encoding: .utf8)!)
            completionHandler(String(data: data, encoding: .utf8) == "success" ? .passed : .failed)
        }.resume()
    }
}
