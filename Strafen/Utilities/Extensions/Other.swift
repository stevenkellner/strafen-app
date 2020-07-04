//
//  Other.swift
//  Strafen
//
//  Created by Steven on 28.06.20.
//

import SwiftUI
import CryptoSwift

// Extension of Font for custom Text Font
extension Font {
    
    /// Custom text font of Futura-Medium
    static func text(_ size: CGFloat) -> Font {
        .custom("Futura-Medium", size: size)
    }
}

// Extension of String to validate if string is an email
extension String {
    
    /// Check if string is valid emial
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}

// Extension of String to de- / encrypt it
extension String {
    
    /// Encrypted String with base 64 cipher
    var encrypted: String {
        let base64cipher = try! Rabbit(key: AppUrls.shared.cipherKey)
        return try! encryptToBase64(cipher: base64cipher)!
    }
    
    /// Encrypted String with base 64 cipher
    ///
    /// nil if error in decrypting
    var decrypted: String? {
        let base64cipher = try! Rabbit(key: AppUrls.shared.cipherKey)
        return try? decryptBase64ToString(cipher: base64cipher)
    }
}

// Extension of ColorScheme to get the background color
extension ColorScheme {
    
    /// Background color of the app
    var backgroundColor: Color {
        self == .dark ? Color.custom.darkGray : .white
    }
}

// Extension of Dictionary for encoding parameters for post method
extension Dictionary where Key == String {
    
    /// Encoding parameters for post method
    var percentEncoded: Data? {
        map { key, value in
            let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return "\(escapedKey)=\(escapedValue)"
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

// Extension of CharacterSet to encoding parameters for post method
extension CharacterSet {
    
    /// Used to encoding parameters for post method
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

// Extension of UIImage to scale it to given resolution
extension UIImage {
    
    /// Scale image with given scale
    func scaledWith(_ scale: CGFloat) -> UIImage {
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        UIGraphicsBeginImageContext(newSize)
        draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// Scaled image to given resolution
    func scaledTo(_ maxResolution: CGFloat) -> UIImage {
        let maxSide = max(size.width, size.height)
        if maxSide > maxResolution {
            return scaledWith(maxResolution / maxSide)
        }
        return self
    }
}

// Extension of UIImage to init from optioal data
extension UIImage {
    
    /// Init UIImage from optional data
    convenience init?(data: Data?) {
        guard let data = data else { return nil }
        self.init(data: data)
    }
}
