//
//  Extensions+Other.swift
//  Strafen
//
//  Created by Steven on 04.05.21.
//

import SwiftUI
import Hydra

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
    func appendingUrl(_ url: URL?) -> URL {
        guard let url = url else { return self }
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

extension Promise {
    
    /// Transforms value to Result.succes(value) and an error to Result.failure(error)
    /// - Parameter handler: code block to execute
    func thenResult(_ handler: @escaping (Result<Value, Error>) -> Void) {
        then { value in
            handler(.success(value))
        }.catch { error in
            handler(.failure(error))
        }
    }
}

extension Result {
    
    /// Optional error of the result
    var error: Failure? {
        guard case .failure(let error) = self else { return nil }
        return error
    }
}

extension CGPoint {
    
    /// <#Description#>
    /// - Parameters:
    ///   - lhs: <#lhs description#>
    ///   - rhs: <#rhs description#>
    /// - Returns: <#description#>
    public static func +(lhs: CGPoint, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - lhs: <#lhs description#>
    ///   - rhs: <#rhs description#>
    /// - Returns: <#description#>
    public static func -(lhs: CGPoint, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x - rhs.width, y: lhs.y - rhs.height)
    }
}
    
extension CGSize {
    
    /// <#Description#>
    /// - Parameters:
    ///   - lhs: <#lhs description#>
    ///   - rhs: <#rhs description#>
    /// - Returns: <#description#>
    public static func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
}

extension Color {
    
    /// Init with red, green and blue vue from 0 to 255
    /// - Parameters:
    ///   - red: red color
    ///   - green: green color
    ///   - blue: blue color
    init(red: Int, green: Int, blue: Int) {
        self.init(red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255)
    }
    
    /// Gray color of the background
    static let backgroundGray = Color(red: 47, green: 49, blue: 54)
    
    /// Gray color of the wave
    static let waveGray = Color(red: 70, green: 75, blue: 81)
    
    /// Gray color of buttons, textfields, etc.
    static let fieldGray = Color(red: 55, green: 57, blue: 63)
    
    /// Color of a text
    static let textColor = Color(red: 185, green: 187, blue: 190)
    
    /// Red color
    static let customRed = Color(red: 185, green: 83, blue: 79)
    
    /// Green color
    static let customGreen = Color(red: 95, green: 178, blue: 128)
}
