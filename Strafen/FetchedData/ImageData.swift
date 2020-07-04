//
//  ImageData.swift
//  Strafen
//
//  Created by Steven on 04.07.20.
//

import SwiftUI

/// Used to fetch Images from server
class ImageData: ObservableObject {
    
    /// Contains personId and associated image
    struct PersonImage {
        
        /// Person Id
        let personId: UUID
        
        /// Image
        let image: UIImage
    }
    
    /// Shared instance for singelton
    static let shared = ImageData()
    
    /// Private init for singleton
    private init() {}
    
    /// All person images
    @Published var personImage = [PersonImage]()
    
    /// Fetch Image from server
    func fetch(from clubUrl: URL? = nil, of personId: UUID, completionHandler: @escaping (UIImage) -> ()) {
        
        // Check if person image has already been loaded
        if let image = personImage.first(where: { $0.personId == personId })?.image {
            return completionHandler(image)
        }
        
        // Fetch image
        ImageFetcher.shared.fetch(from: clubUrl, of: personId) { image in
            DispatchQueue.main.async {
                if let image = image {
                    self.personImage.append(PersonImage(personId: personId, image: image))
                    completionHandler(image)
                }
            }
        }
    }
}
