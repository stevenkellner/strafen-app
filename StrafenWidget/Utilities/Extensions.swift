//
//  Extensions.swift
//  StrafenWidgetExtension
//
//  Created by Steven on 25.07.20.
//

import Foundation

// Extension of FileManager to get shared container Url
extension FileManager {
    
    /// Url of shared container
    var sharedContainerUrl: URL {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.stevenkellner.Strafen.settings")!
    }
}
