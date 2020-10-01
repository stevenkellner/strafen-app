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

// Extension of Int to confirm to Identifiable
extension Int: Identifiable {
    public var id: Int {
        self
    }
}

// Extension of Double to get string value
extension Double {
    
    /// String value
    var stringValue: String {
        if Double(Int(self)) == self {
            return String(Int(self))
        }
        return String(self).replacingOccurrences(of: ".", with: ",")
    }
}

// Extension of UISceneConfiguration to get a default configuration
extension UISceneConfiguration {
    
    /// Default configuration
    static func `default`(session: UISceneSession) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: session.role)
    }
}

// Extension of PersonNameComponents to formatt it to PersonName
extension PersonNameComponents {
    
    /// Formatted as PersonName
    ///
    /// Is nil, if PersonNameComponents has no given or family name
    var personName: PersonName? {
        guard let givenName = givenName, let familyName = familyName else {
            return nil
        }
        return PersonName(firstName: givenName, lastName: familyName)
    }
}

// Extension of URLRequest to init for url and http body
extension URLRequest {
    
    /// URLRequest for url and http body
    init(url: URL, body: Data?, boundaryId: UUID?) {
        self.init(url: url)
        setValue("Basic \(AppUrls.shared.loginString)", forHTTPHeaderField: "Authorization")
        if let boundaryId = boundaryId {
            setValue("multipart/form-data; boundary=Boundary-\(boundaryId.uuidString)", forHTTPHeaderField: "Content-Type")
        }
        cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        httpMethod = "POST"
        httpBody = body
    }
}

// Extension of URLSession to execute a data task with task state completion
extension URLSession {
    
    /// Data task with task state completion
    func dataTask(with request: URLRequest, completionHandler: @escaping (TaskState) -> Void) {
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                return completionHandler(.failed)
            }
            let success = data == "success".data(using: .utf8)
            let taskState: TaskState = success ? .passed : .failed
            completionHandler(taskState)
        }.resume()
    }
}

// Extension of UIImage to get http body with parameters, boundaryId and fileName
extension UIImage {
    
    /// http body with parameters, boundaryId and fileName
    func body(parameters: Parameters, boundaryId: UUID, fileName: String) -> Data {
        var data = parameters.encodedForImage(boundaryId: boundaryId)
        data.append("--Boundary-\(boundaryId.uuidString)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(pngData()!)
        data.append("\r\n".data(using: .utf8)!)
        data.append("--Boundary-\(boundaryId.uuidString)--\r\n".data(using: .utf8)!)
        return data
    }
}

// Extension of Dictionary to encode it for image
extension Dictionary where Key == String {
    
    /// Encode it for image
    func encodedForImage(boundaryId: UUID) -> Data {
        reduce(into: Data()) { data, element in
            data.append("--Boundary-\(boundaryId.uuidString)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(element.key)\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(element.value)\r\n".data(using: .utf8)!)
        }
    }
}
