//
//  ActivityView.swift
//  Strafen
//
//  Created by Steven on 14.07.20.
//

import SwiftUI
import LinkPresentation

/// Activity View
struct ActivityView: UIViewControllerRepresentable {
    
    /// Shared instance for singelton
    static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    /// Controller
    let activityViewController = ActivityViewController()
    
    /// make view
    func makeUIViewController(context: Context) -> ActivityViewController {
        activityViewController
    }
    
    /// update view
    func updateUIViewController(_ uiViewController: ActivityViewController, context: Context) {}
    
    /// share image
    func shareImage(_ image: UIImage, title: String) {
        activityViewController.shareImage(image, title: title)
    }
}

/// Activity View Controller
class ActivityViewController: UIViewController, UIActivityItemSource {
    
    /// Image
    var image: UIImage? = nil
    
    /// Person name
    var imageTitle: String? = nil
    
    /// share image
    func shareImage(_ image: UIImage, title: String) {
        self.image = image
        imageTitle = title
        let vc = UIActivityViewController(activityItems: [image, self], applicationActivities: nil)
        present(vc, animated: true, completion: nil)
        vc.popoverPresentationController?.sourceView = view
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any { "" }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? { nil }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        if let image = image {
            let imageProvider = NSItemProvider(object: image)
            metadata.imageProvider = imageProvider
            metadata.iconProvider = imageProvider
        }
        if let imageTitle = imageTitle {
            metadata.title = imageTitle
        }
        return metadata
    }
}
