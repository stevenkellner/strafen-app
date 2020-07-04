//
//  ListFetcher.swift
//  Strafen
//
//  Created by Steven on 02.07.20.
//

import Foundation

/// Fetches list of app types from server
struct ListFetcher {
    
    /// Shared instance for singelton
    static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    /// Fetches the  list and execute the completionHandler if no error appear.
    func fetch<AppType>(from url: URL? = nil, _ completionHandler: @escaping ([AppType]?) -> ()) where AppType: AppTypes {
        
        // Get request
        guard let url = url ?? AppUrls.shared[keyPath: AppType.serverListUrl] else { return completionHandler(nil) }
        var request = URLRequest(url: url)
        request.setValue("Basic \(AppUrls.shared.loginString)", forHTTPHeaderField: "Authorization")
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        // Execute data task to fetch data from Url.
        URLSession.shared.dataTask(with: request) { data, _, error in
            
            // Check if no error appeared.
            guard error == nil else { return completionHandler(nil) }
            
            // Check if it gets data.
            guard let data = data else { return completionHandler(nil) }
            
            // Decode Json
            let decoder = JSONDecoder()
            let list = try? decoder.decode([AppType].self, from: data)
            completionHandler(list)
        }.resume()
    }
}
