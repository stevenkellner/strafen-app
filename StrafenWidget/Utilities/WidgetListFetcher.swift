//
//  WidgetListFetcher.swift
//  Strafen
//
//  Created by Steven on 25.07.20.
//

import Foundation

/// Fetches list of widget types from server
struct WidgetListFetcher {
    
    /// Shared instance for singelton
    static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    /// Fetches the list and execute the completionHandler if no error appear.
    func fetch<ListType>(of clubId: UUID, _ completionHandler: @escaping ([ListType]?) -> ()) where ListType: WidgetListTypes {
        
        // Get request
        let url = WidgetUrls.shared.listTypesUrls(of: clubId)[keyPath: ListType.serverListUrl]
        var request = URLRequest(url: url)
        request.setValue("Basic \(WidgetUrls.shared.loginString)", forHTTPHeaderField: "Authorization")
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        // Execute data task to fetch data from Url.
        URLSession.shared.dataTask(with: request) { data, _, error in
            
            // Check if no error appeared.
            guard error == nil else { return completionHandler(nil) }
            
            // Check if it gets data.
            guard let data = data else { return completionHandler(nil) }
            
            // Decode Json
            let decoder = JSONDecoder()
            let list = try? decoder.decode([ListType].self, from: data)
            completionHandler(list)
        }.resume()
    }
}
