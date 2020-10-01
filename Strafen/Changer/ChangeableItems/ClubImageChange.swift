//
//  ClubImageChange.swift
//  Strafen
//
//  Created by Steven on 9/19/20.
//

import SwiftUI

/// Club image change
struct ClubImageChange: Changeable {
    
    /// Max Resolution of an image
    static let maxImageResolution: CGFloat = 720
    
    /// Change type
    let changeType: ChangeType
    
    /// Image
    let image: UIImage?
    
    /// Club id
    let clubId: UUID
    
    /// Path from AppUrls to changer url
    var urlPath: KeyPath<AppUrls, URL> = \.changer.clubImage
    
    /// http body
    var body: Data? {
        let image = self.image?.scaledTo(ClubImageChange.maxImageResolution)
        let parameters = Parameters { parameters in
            parameters["change"] = changeType.rawValue
            parameters["id"] = clubId.uuidString
        }
        if let image = image {
            return image.body(parameters: parameters, boundaryId: boundaryId!, fileName: clubId.uuidString)
        }
        return parameters.encodedForImage(boundaryId: boundaryId!)
    }
    
    /// Boundary id
    let boundaryId: UUID? = UUID()
}
