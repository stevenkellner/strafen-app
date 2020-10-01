//
//  PersonImageChange.swift
//  Strafen
//
//  Created by Steven on 9/19/20.
//

import SwiftUI

/// Person image change
struct PersonImageChange: Changeable {
    
    /// Max Resolution of an image
    static let maxImageResolution: CGFloat = 720
    
    /// Change type
    let changeType: ChangeType
    
    /// Image
    let image: UIImage?
    
    /// Person id
    let personId: UUID
    
    /// Club id
    let clubId: UUID
    
    init(changeType: ChangeType, image: UIImage?, personId: UUID, clubId: UUID? = nil) {
        self.changeType = changeType
        self.image = image
        self.personId = personId
        self.clubId = clubId ?? Settings.shared.person!.clubId
    }
    
    /// Path from AppUrls to changer url
    var urlPath: KeyPath<AppUrls, URL> = \.changer.personImage
    
    /// http body
    var body: Data? {
        let image = self.image?.scaledTo(PersonImageChange.maxImageResolution)
        let parameters = Parameters { parameters in
            parameters["change"] = changeType.rawValue
            parameters["id"] = personId.uuidString
            parameters["clubId"] = clubId.uuidString
        }
        if let image = image {
            return image.body(parameters: parameters, boundaryId: boundaryId!, fileName: personId.uuidString)
        }
        return parameters.encodedForImage(boundaryId: boundaryId!)
    }
    
    /// Boundary id
    let boundaryId: UUID? = UUID()
    
    /// Change cached
    func changeCached() {
        let image = { self.image!.scaledTo(PersonImageChange.maxImageResolution) }
        switch changeType {
        case .add where !ImageData.shared.personImage.contains(where: { $0.personId == personId }):
            ImageData.shared.personImage.append(image: image(), of: personId)
        case .update:
            ImageData.shared.personImage.updateImage(of: personId, new: image())
        case .delete:
            ImageData.shared.personImage.deleteImage(of: personId)
        default:
            break
        }
    }
}

