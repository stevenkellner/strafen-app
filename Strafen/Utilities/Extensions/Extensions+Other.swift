//
//  Extensions+Other.swift
//  Strafen
//
//  Created by Steven on 04.05.21.
//

import SwiftUI

extension UISceneConfiguration {
    
    /// Default configuration of UISceneConfiguration.
    /// - Parameter session: UISceneSession for session role
    /// - Returns: the default configuration
    static func `default`(session: UISceneSession) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: session.role)
    }
}

extension URL {
    
    /// Appends given url and returns combinding url
    /// - Parameter url: url to append
    /// - Returns: combinding url
    func appendingUrl(_ url: URL) -> URL {
        var newUrl = self
        for component in url.pathComponents {
            newUrl.appendPathComponent(component)
        }
        return newUrl
    }
}
