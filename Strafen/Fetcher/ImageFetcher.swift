//
//  ImageFetcher.swift
//  Strafen
//
//  Created by Steven on 04.07.20.
//

import SwiftUI

/// Fetches an image from server
@available(*, deprecated, message: "Use Image Storage instead.")
struct ImageFetcher {
    
    /// Shared instance for singelton
    static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    /// Fetches the  list and execute the completionHandler if no error appear.
    func fetch(from url: URL? = nil, of personId: UUID, _ completionHandler: @escaping (UIImage?) -> ()) {
        
        // Get request
        guard var url = url ?? AppUrls.shared.imagesDirUrl else { return completionHandler(nil) }
        url = url.appendingPathComponent(personId.uuidString).appendingPathExtension("png")
        var request = URLRequest(url: url)
        request.setValue("Basic \(AppUrls.shared.loginString)", forHTTPHeaderField: "Authorization")
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        // Execute data task to fetch data from Url.
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard error == nil else { return completionHandler(nil) }
            completionHandler(UIImage(data: data))
        }.resume()
    }
}
