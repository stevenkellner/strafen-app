//
//  ClubImageChanger.swift
//  Strafen
//
//  Created by Steven on 02.07.20.
//

import SwiftUI

/// Used to change a club image on server
struct ClubImageChanger {
    
    /// Change type of image change on server
    enum ChangeType {
        
        /// Add new image to server
        case add(image: UIImage, clubId: UUID)
        
        /// Updates an existing image on server
        case update(image: UIImage, clubId: UUID)
        
        /// Deletes an existing image on server
        case delete(clubId: UUID)
        
        /// Image to upload
        var image: UIImage {
            switch self {
            case .add(image: let image, clubId: _):
                return image
            case .update(image: let image, clubId: _):
                return image
            case .delete(clubId: _):
                return UIImage(systemName: "person")! // Never used
            }
        }
        
        /// Club Id
        var clubId: UUID {
            switch self {
            case .add(image: _, clubId: let clubId):
                return clubId
            case .update(image: _, clubId: let clubId):
                return clubId
            case .delete(clubId: let clubId):
                return clubId
            }
        }
        
        /// String for post method
        var string: String {
            switch self {
            case .add(image: _, clubId: _):
                return "add"
            case .update(image: _, clubId: _):
                return "update"
            case .delete(clubId: _):
                return "delete"
            }
        }
    }
    
    /// Shared instance for singelton
    static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    /// Max Resolution of an image
    static let maxImageResolution: CGFloat = 720
    
    /// Create new club on server
    func changeImage(_ changeType: ChangeType) {
        
        // Scale image
        let image = changeType.image.scaledTo(ClubImageChanger.maxImageResolution)
        
        // Url request
        var request = URLRequest(url: AppUrls.shared.changer.clubImage)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("Basic \(AppUrls.shared.loginString)", forHTTPHeaderField: "Authorization")
        
        // Set boundary
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Init data
        let imageData = image.pngData()!
        var body = Data()
        let parameters: [String : Any] = [
            "key": AppUrls.shared.key,
            "change": changeType.string,
            "id": changeType.clubId
        ]
        
        // Get data for parameters
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // get data for boundary / image
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(changeType.clubId.uuidString)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        // Execute dataTask
        URLSession.shared.dataTask(with: request) { _, _, _ in }.resume()
    }
}
