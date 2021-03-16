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

/// Extension of Text to configurate it with text color and given font size
extension Text {
    
    /// Configurate it with text color and given font size
    func configurate(size: CGFloat) -> some View {
        foregroundColor(.textColor).font(.text(size)).multilineTextAlignment(.center)
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

extension Text {
    init<Subject>(describing instance: Subject) {
        self.init(String(describing: instance))
    }
    
    init<Subject>(describing instance: Subject) where Subject : CustomStringConvertible {
        self.init(String(describing: instance))
    }
    
    init<Subject>(describing instance: Subject) where Subject : TextOutputStreamable {
        self.init(String(describing: instance))
    }
    
    init<Subject>(describing instance: Subject) where Subject : CustomStringConvertible, Subject : TextOutputStreamable {
        self.init(String(describing: instance))
    }
}

/// View modifer for plain foreground color
struct TextForegroudColor: ViewModifier {
    
    /// Color for plain style
    let color: Color?
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject private var settings = Settings.shared
    
    func body(content: Content) -> some View {
        content.foregroundColor(color == nil || settings.style == .default ? .textColor : color!)
    }
}

// Extension of View for custom foreground color
extension View {
    func foregroundColor(plain color: Color?) -> some View {
        ModifiedContent(content: self, modifier: TextForegroudColor(color: color))
    }
}

// Extension of URL to get path to club and person image files in server
extension URL {
    
    /// Path to club image file in server
    static func clubImage(with imageName: String) -> URL {
        URL(string: "images")!
            .appendingPathComponent("club")
            .appendingPathComponent(imageName)
    }
    
    /// Path to person image file in server
    static func personImage(with imageName: String, clubId: Club.ID) -> URL {
        URL(string: "images")!
            .appendingPathComponent("person")
            .appendingPathComponent(clubId.uuidString.uppercased())
            .appendingPathComponent(imageName)
    }
}

extension Bundle {
    var firebaseDebugEnabled: Bool {
        CommandLine.arguments.contains("-firebaseDebug")
    }
    
    var firebaseClubsComponent: String {
        firebaseDebugEnabled ? "debugClubs" : "clubs"
    }
}

#if TARGET_MAIN_APP
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
        UINavigationController.swipeBack && viewControllers.count > 1
    }
    
    static var swipeBack = true
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
        PersonName(firstName: givenName, lastName: familyName)
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

/// Protocol for an alert type
protocol AlertTypeProtocol: Identifiable {
    
    /// Alert of all alert types
    var alert: Alert { get }
    
}

// Extension of View to get an alert with AlertTypeProtocol
extension View {
    
    /// Get an alert with AlertTypeProtocol
    func alert<AlertType>(item: Binding<AlertType?>) -> some View where AlertType: AlertTypeProtocol {
        alert(item: item) { $0.alert }
    }
}

// Extension of Bool to confirm to Identifiable
extension Bool: Identifiable {
    public var id: Bool { self }
}

/// View modifier to set screen size
struct ScreenSizeModifier: ViewModifier {
    
    /// Deadline
    let deadline: Double
    
    /// Screen size
    @State var screenSize: CGSize?
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content.screenSize($screenSize, geometry: geometry, after: deadline)
        }
    }
}

#if canImport(HalfModal)
import HalfModal
struct HalfModalModifier<SheetContent>: ViewModifier where SheetContent: View {
    
    @Binding var isPresented: Bool
    
    let header: String
    
    let sheetContent: SheetContent
    
    init(isPresented: Binding<Bool>, header: String, @ViewBuilder content: () -> SheetContent) {
        self._isPresented = isPresented
        self.header = header
        self.sheetContent = content()
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                HalfModalView(content: AnyView(sheetContent), header: AnyView(Text(header).configurate(size: 20)), isPresented: $isPresented)
            }
        }
    }
}
extension View {
    func halfModal<Content>(isPresented: Binding<Bool>, header: String, @ViewBuilder content: () -> Content) -> some View where Content: View {
        ModifiedContent(content: self, modifier: HalfModalModifier(isPresented: isPresented, header: header, content: content))
    }
}
#endif

// Extension of View to set screen size
extension View {
    
    /// Sets screen size
    func screenSize(_ screenSize: Binding<CGSize?>, geometry: GeometryProxy, after deadline: Double = 0) -> some View {
        frame(size: screenSize.wrappedValue ?? geometry.size).onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + deadline) {
                screenSize.wrappedValue = geometry.size
            }
        }
    }
    
    /// Sets screen size
    var setScreenSize: some View {
        ModifiedContent(content: self, modifier: ScreenSizeModifier(deadline: 0))
    }
    
    /// Sets screen size
    func setScreenSize(after deadline: Double) -> some View {
        ModifiedContent(content: self, modifier: ScreenSizeModifier(deadline: deadline))
    }
}

/// Extension of Locale to get available language codes for english translation
extension Locale {

    /// Used to decode fetched data
    struct Dict: Decodable {
        struct Language: Decodable {
            let name: String
            let nativeName: String
            let dir: String
            let code: String
        }
        
        struct Translations: Decodable {
            let name: String
            let nativeName: String
            let dir: String
            let translations: [Language]
        }
        
        let dictionary: Dictionary<String, Translations>
    }

    /// Gets available languages
    static private func getAvailableTranslateLanguages(completion completionHandler: @escaping ([Dict.Language]?) -> Void) {
        let url = URL(string: "https://dev.microsofttranslator.com/languages?api-version=3.0&scope=dictionary")!
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return completionHandler(nil) }
            let decoder = JSONDecoder()
            let languages = try? decoder.decode(Dict.self, from: data).dictionary["en"]?.translations
            completionHandler(languages)
        }.resume()
    }
    
    /// Gets available language codes
    static func availableTranslateLanguageCodes(completion completionHandler: @escaping ([String]?) -> Void) {
        getAvailableTranslateLanguages { languages in
            let languageCodes = languages?.map { language in
                language.code
            }.filter { languageCode in
                Locale.current.localizedString(forLanguageCode: languageCode) != nil
            }
            completionHandler(languageCodes)
        }
    }
}

// Extension of Locale for available region codes
extension Locale {
    
    /// All available region codes with valid currency Symbol
    static var availableRegionCodes: [String] {
        availableIdentifiers.compactMap { identifier in
            guard let regionCode = Locale(identifier: identifier).regionCode else { return nil }
            let locale = Locale(identifier: Locale.identifier(fromComponents: ["kCFLocaleCountryCodeKey": regionCode]))
            guard locale.currencyCode != nil else { return nil }
            return regionCode
        }.unique.sorted { identifier in
            Locale.regionName(of: identifier)
        }
    }
}

// Extension of Locale to get region name
extension Locale {
    
    /// Region name
    static func regionName(of regionCode: String) -> String {
        let regionName = Locale.current.localizedString(forRegionCode: regionCode)
        return regionName ?? regionCode
    }
}

// Extension of View to toggle a boolean value on tap gesture
extension View {
    
    /// Toggle a boolean value on tap gesture
    func toggleOnTapGesture(_ binding: Binding<Bool>, animation: Animation? = nil) -> some View {
        onTapGesture {
            if let animation = animation {
                withAnimation(animation) {
                    binding.wrappedValue.toggle()
                }
            } else {
                binding.wrappedValue.toggle()
            }
        }
    }
    
    /// Set value on tap gesture
    func setOnTapGesture<T>(_ binding: Binding<T>, to value: T, animation: Animation? = nil) -> some View {
        onTapGesture {
            if let animation = animation {
                withAnimation(animation) {
                    binding.wrappedValue = value
                }
            } else {
                binding.wrappedValue = value
            }
        }
    }
}

// Extension of View to hide navigation bar title
extension View {
    
    /// Hide navigation bar title
    func hideNavigationBarTitle() -> some View {
        navigationBarTitle("Title").navigationBarHidden(true)
    }
}

// Extension of CGSize to init with same edge length
extension CGSize: _VectorMath {
    
    /// CGSize with same edge length
    static func square(_ edgeLength: CGFloat) -> CGSize {
        CGSize(width: edgeLength, height: edgeLength)
    }
}

// Extension of Date to get formatted strings
extension Date {
    
    /// Formatted with long style
    var formattedLong: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .long
        return formatter.string(from: self)
    }
}

/// Modifier to set dismiss handler
struct SetDismissHandlerModifier: ViewModifier {
    
    ///Dismiss handler
    @Binding var dismissHandler: DismissHandler
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                dismissHandler = {
                    presentationMode.wrappedValue.dismiss()
                }
            }
    }
}

extension View {
    
    /// Set dismiss handler
    func setDismissHandler(_ dismissHandler: Binding<DismissHandler>) -> some View {
        ModifiedContent(content: self, modifier: SetDismissHandlerModifier(dismissHandler: dismissHandler))
    }
    
    /// ignore all safe areas and set max frame to infinity
    var maxFrame: some View {
        edgesIgnoringSafeArea(.all).frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Precedencegroup for |!| - operator
precedencegroup LogicalDisjunctionBothPrecedence {
    higherThan: LogicalDisjunctionPrecedence
    associativity: left
    assignment: false
}

/// Works like || - operator (logical disjunction), but evalutates also the right side if left side is already true
infix operator |!|: LogicalDisjunctionBothPrecedence

// Extension of Bool to get |!| - operator
extension Bool {
    
    /// Works like || - operator (logical disjunction), but evalutates also the right side if left side is already true
    static func |!|(lhs: Bool, rhs: Bool) -> Bool {
        var isTrue = false
        isTrue = lhs || isTrue
        isTrue = rhs || isTrue
        return isTrue
    }
}

@dynamicMemberLookup struct PropertyListContent {
    private let content: [String: AnyObject]?
    
    init(path: String) {
        var format =  PropertyListSerialization.PropertyListFormat.xml
        let data = FileManager.default.contents(atPath: path)!
        content = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: &format) as? [String: AnyObject]
    }
    
    @inlinable subscript(dynamicMember key: String) -> AnyObject? {
        content?[key]
    }
    
    @inlinable subscript(_ key: String) -> AnyObject? {
        content?[key]
    }
}

extension Bundle {
    static var keysPropertyList: PropertyListContent {
        PropertyListContent(path: Bundle.main.path(forResource: "KeysInfo", ofType: "plist")!)
    }
}

import CryptoSwift
extension Array where Element == UInt8 {
    var encrypted: Array<UInt8>? {
        guard let cryptionKey = Bundle.keysPropertyList.cryptionKey as? String,
              let cryptionIV = Bundle.keysPropertyList.cryptionIV as? String else { return nil }
        let aes = try? AES(key: cryptionKey, iv: cryptionIV)
        return try? aes?.encrypt(self)
    }
    
    var decrypted: Array<UInt8>? {
        guard let cryptionKey = Bundle.keysPropertyList.cryptionKey as? String,
              let cryptionIV = Bundle.keysPropertyList.cryptionIV as? String else { return nil }
        let aes = try? AES(key: cryptionKey, iv: cryptionIV)
        return try? aes?.decrypt(self)
    }
    
    var isoLatin1String: String? {
        String(bytes: self, encoding: .isoLatin1)
    }
}

extension String {
    var isoLatin1ByteList: Array<UInt8>? {
        guard let data = data(using: .isoLatin1) else { return nil }
        return [UInt8](data)
    }
}
#endif
