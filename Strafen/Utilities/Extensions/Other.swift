//
//  Other.swift
//  Strafen
//
//  Created by Steven on 28.06.20.
//

import SwiftUI

// Extension of Font for custom Text Font
extension Font {
    
    /// Custom text font of Futura-Medium
    static func text(_ size: CGFloat) -> Font {
        .custom("Futura-Medium", size: size)
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

// Extension of Optioanl Euro to confirm to CustomStringConvertible
extension Optional where Wrapped == Euro {
    
    /// Description
    var text: String {
        switch self {
        case .none:
            return ",-€"
        case .some(let amount):
            return amount.description
        }
    }
}

// Extension of CGSize for Multiplication with CGFloat
extension CGSize {
    
    /// Multiplies by a CGFloat
    static func *(lhs: CGFloat, rhs: CGSize) -> CGSize {
        CGSize(width: lhs * rhs.width, height: lhs * rhs.height)
    }
}

// Extension of path to make it intuitive
extension Path {
    
    /// Add arc starting on top
    mutating func addArc(center: CGPoint,_ radius: CGFloat, startAngle: Angle, endAngle: Angle, clockwise: Bool) {
        let rotationAdjustment = Angle.degrees(90)
        let modifiedStart = startAngle - rotationAdjustment
        let modifiedEnd = endAngle - rotationAdjustment
        addArc(center: center, radius: radius, startAngle: modifiedStart, endAngle: modifiedEnd, clockwise: clockwise)
    }
}

// Extension of Date to get formatted date
extension Date {
    
    /// Formatted date struct
    var formattedDate: FormattedDate {
        FormattedDate(date: self)
    }
}

// Extension of FileManager to get shared container Url
extension FileManager {
    
    /// Url of shared container
    var sharedContainerUrl: URL {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.stevenkellner.Strafen.settings")!
    }
}

// Extension of View to set frame from CGSize
extension View {
    
    /// Sets frame from CGSize
    func frame(size: CGSize, alignment: Alignment = .center) -> some View {
        frame(width: size.width, height: size.height, alignment: alignment)
    }
}

// Extension of UIApplication to dismiss keyboard
extension UIApplication {
    
    /// Dismisses keyboard
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// Extension of UINavigationController to swipe back in NavigationViews
extension UINavigationController: UIGestureRecognizerDelegate {
    
    // Override viewDidLoad
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    // Override gestureRecognizerShouldBegin
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}

extension PersonNameComponents {
    var personName: PersonName? {
        guard let givenName = givenName, let familyName = familyName else {
            return nil
        }
        return PersonName(firstName: givenName, lastName: familyName)
    }
}
