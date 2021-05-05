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

extension Bundle {
    
    /// Contains content of a property list
    @dynamicMemberLookup struct PropertyListContent {
        
        /// Content of a property list
        private let content: [String: AnyObject]?
        
        /// Init content by the path to the property list
        /// - Parameter path: path to the property list
        init(path: String) {
            var format =  PropertyListSerialization.PropertyListFormat.xml
            let data = FileManager.default.contents(atPath: path)!
            content = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: &format) as? [String: AnyObject]
        }
        
        /// Init content by the name of the property list
        /// - Parameter name: name of the property list in the bundle
        init?(name: String) {
            guard let path = Bundle.main.path(forResource: name, ofType: "plist") else { return nil }
            self.init(path: path)
        }
        
        /// Gets the content with given key
        /// - Parameter key: key of content
        /// - Returns: value of given key
        @inlinable subscript(dynamicMember key: String) -> AnyObject? {
            content?[key]
        }
    }
    
    /// Content of `KeysInfo` property list
    static var keysPropertyList: PropertyListContent {
        PropertyListContent(name: "KeysInfo")!
    }
}
