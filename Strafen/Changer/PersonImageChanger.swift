//
//  PersonImageChanger.swift
//  Strafen
//
//  Created by Steven on 21.07.20.
//

import SwiftUI

/// Used to change a person image on server
struct PersonImageChanger {
    
    /// Change type of image change on server
    enum ChangeType {
        
        /// Add new image to server
        case add(image: UIImage, personId: UUID)
        
        /// Updates an existing image on server
        case update(image: UIImage, personId: UUID)
        
        /// Deletes an existing image on server
        case delete(personId: UUID)
        
        /// Image to upload
        var image: UIImage {
            switch self {
            case .add(image: let image, personId: _):
                return image
            case .update(image: let image, personId: _):
                return image
            case .delete(personId: _):
                return UIImage(systemName: "person")! // Never used
            }
        }
        
        /// Person Id
        var personId: UUID {
            switch self {
            case .add(image: _, personId: let personId):
                return personId
            case .update(image: _, personId: let personId):
                return personId
            case .delete(personId: let personId):
                return personId
            }
        }
        
        /// String for post method
        var string: String {
            switch self {
            case .add(image: _, personId: _):
                return "add"
            case .update(image: _, personId: _):
                return "update"
            case .delete(personId: _):
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
    
    /// Change server and cached person image
    func changeImage(_ changeType: ChangeType, completionHandler: @escaping (TaskState) -> ()) {
        changeImageServer(changeType) { taskState in
            if taskState == .passed {
                changeImageCached(changeType)
            }
            completionHandler(taskState)
        }
    }
    
    /// Change cached person image
    private func changeImageCached(_ changeType: ChangeType) {
        DispatchQueue.main.async {
            switch changeType {
            case .add(image: let image, personId: let personId) where !ImageData.shared.personImage.contains(where: { $0.personId == personId }):
                ImageData.shared.personImage.append(image: image, of: personId)
            case .update(image: let image, personId: let personId):
                ImageData.shared.personImage.updateImage(of: personId, new: image)
            case .delete(personId: let personId):
                ImageData.shared.personImage.deleteImage(of: personId)
            default:
                break
            }
        }
    }
    
    /// Change person image on server
    private func changeImageServer(_ changeType: ChangeType, completionHandler: @escaping (TaskState) -> ()) {
        
        // Scale image
        let image = changeType.image.scaledTo(PersonImageChanger.maxImageResolution)
        
        // Url request
        var request = URLRequest(url: AppUrls.shared.changer.personImage)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
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
            "id": changeType.personId,
            "clubId": Settings.shared.person!.clubId
        ]
        
        // Get data for parameters
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // get data for boundary / image
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(changeType.personId.uuidString)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        // Execute dataTask
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard error == nil else { return completionHandler(.failed) }
            guard let data = data else { return completionHandler(.failed) }
            completionHandler(String(data: data, encoding: .utf8) ?? "" == "success" ? .passed : .failed)
        }.resume()
    }
}
