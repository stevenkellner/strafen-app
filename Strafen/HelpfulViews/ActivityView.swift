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
    func makeUIViewController(context: Context) -> ActivityViewController { activityViewController }
    
    /// update view
    func updateUIViewController(_ uiViewController: ActivityViewController, context: Context) {}
    
    /// share image
    func shareImage(_ image: UIImage, title: String) {
        activityViewController.shareImage(image, title: title)
    }
    
    /// share text
    func shareText(_ text: String) {
        activityViewController.shareText(text)
    }
}

/// Activity View Controller
class ActivityViewController: UIViewController, UIActivityItemSource {
    
    enum ShareType {
        case image(image: UIImage, title: String)
        case text
    }
    
    var shareType: ShareType?
    
    /// share image
    func shareImage(_ image: UIImage, title: String) {
        shareType = .image(image: image, title: title)
        let vc = UIActivityViewController(activityItems: [image, self], applicationActivities: nil)
        present(vc, animated: true, completion: nil)
        vc.popoverPresentationController?.sourceView = view
    }
    
    /// share text
    func shareText(_ text: String) {
        shareType = .text
        let vc = UIActivityViewController(activityItems: [text, self], applicationActivities: nil)
        present(vc, animated: true, completion: nil)
        vc.popoverPresentationController?.sourceView = view
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any { "" }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? { nil }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        guard let shareType = shareType else {
            return metadata
        }
        switch shareType {
        case .image(image: let image, title: let title):
            let imageProvider = NSItemProvider(object: image)
            metadata.imageProvider = imageProvider
            metadata.iconProvider = imageProvider
            metadata.title = title
        case .text:
            break
        }
        return metadata
    }
}
