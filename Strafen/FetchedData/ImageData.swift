//
//  ImageData.swift
//  Strafen
//
//  Created by Steven on 04.07.20.
//

import SwiftUI

/// Used to fetch Images from server
class ImageData: ObservableObject {
    
    /// Shared instance for singelton
    static let shared = ImageData()
    
    /// Private init for singleton
    private init() {}
    
    /// All person images
    @Published var personImage = PersonImages()
    
    /// Fetch Image from server
    func fetch(from clubUrl: URL? = nil, of personId: UUID, completionHandler: @escaping (UIImage) -> ()) {
        
        // Check if person image has already been loaded
        if let image = personImage.image(of: personId) {
            DispatchQueue.global(qos: .background).async {
                completionHandler(image)
            }
            return
        }
        
        // Fetch image
        ImageFetcher.shared.fetch(from: clubUrl, of: personId) { image in
            DispatchQueue.main.async {
                if let image = image {
                    self.personImage.append(image: image, of: personId)
                    completionHandler(image)
                }
            }
        }
    }
}

/// Contains all person images
struct PersonImages {
    
    /// Max number of cached images
    static let maxImages = 25
    
    /// Contains personId and associated image
    struct PersonImage {
        
        /// Person Id
        let personId: UUID
        
        /// Image
        let image: UIImage
        
        /// Time of image
        let time: TimeInterval
    }
    
    /// List of all person images
    var images = [PersonImage]() {
        didSet {
            print(images.count)
        }
    }
    
    /// Gets image with personId
    func image(of personId: UUID) -> UIImage? {
        images.first(where: { $0.personId == personId })?.image
    }
    
    /// Append to images
    mutating func append(image: UIImage, of personId: UUID) {
        while images.count >= Self.maxImages {
            removeEarliest()
        }
        images.append(.init(personId: personId, image: image, time: Date().timeIntervalSince1970))
    }
    
    /// Removes earliest image
    mutating func removeEarliest() {
        guard let earliestImage = images.min(by: { $0.time < $1.time }) else { return }
        images.filtered { $0.personId != earliestImage.personId }
    }
    
    /// Removes all images
    mutating func removeAll() {
        images = []
    }
    
    /// Updates image of given personId
    mutating func updateImage(of personId: UUID, new image: UIImage) {
        images.mapped { $0.personId == personId ? .init(personId: $0.personId, image: image, time: $0.time) : $0 }
    }
    
    /// Deletes image of given personId
    mutating func deleteImage(of personId: UUID) {
        images.filtered { $0.personId != personId }
    }
    
    /// Indicates if images contains an element that satisfies the given predicate.
    func contains(where predicate: (PersonImage) throws -> Bool) rethrows -> Bool {
        try images.contains(where: predicate)
    }
}
