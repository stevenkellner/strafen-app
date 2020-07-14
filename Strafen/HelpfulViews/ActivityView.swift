//
//  ActivityView.swift
//  Strafen
//
//  Created by Steven on 14.07.20.
//

import SwiftUI

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
    func shareImage(_ image: UIImage) {
        activityViewController.shareImage(image)
    }
}

/// Activity View Controller
class ActivityViewController: UIViewController {
    
    /// share image
    func shareImage(_ image: UIImage) {
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
        vc.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo
        ]
        present(vc, animated: true, completion: nil)
        vc.popoverPresentationController?.sourceView = view
    }
}
