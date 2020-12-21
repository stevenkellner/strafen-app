//
//  Settings.swift
//  Strafen
//
//  Created by Steven on 27.06.20.
//

import SwiftUI
import WidgetKit

/// Contains all properies of the settings of the app of this device
@dynamicMemberLookup class Settings: ObservableObject {
    
    /// Shared instance for singelton
    static let shared = Settings()

    /// Private init for singleton
    private init() {
        if let propertiesData = FileManager.default.contents(atPath: Self.settingsUrl.path) {
            let decoder = JSONDecoder()
            properties = try! decoder.decode(SettingProperties.self, from: propertiesData)
        } else {
            properties = SettingProperties()
        }
    }
    
    #if TARGET_MAIN_APP
    /// All settings properties
    @Published public var properties: SettingProperties {
        didSet {
            applySettings()
            saveProperties()
        }
    }
    
    /// For dynamic member lookup
    subscript<T>(dynamicMember keyPath: WritableKeyPath<SettingProperties, T>) -> T {
        get {
            properties[keyPath: keyPath]
        }
        set {
            properties[keyPath: keyPath] = newValue
        }
    }
    #else
    /// All settings properties
    @Published public var properties: SettingProperties
    
    /// For dynamic member lookup
    subscript<T>(dynamicMember keyPath: WritableKeyPath<SettingProperties, T>) -> T {
        get {
            properties[keyPath: keyPath]
        }
    }
    #endif
    
    #if TARGET_MAIN_APP
    /// Saves properties to file
    private func saveProperties() {
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(properties)
        if FileManager.default.fileExists(atPath: Self.settingsUrl.path) {
            try! jsonData.write(to: Self.settingsUrl, options: .atomic)
        } else {
            FileManager.default.createFile(atPath: Self.settingsUrl.path, contents: jsonData)
        }
    }
    
    /// Apply settings
    public func applySettings() {
        properties.applySettings()
    }
    #endif
    
    /// Url for settings file
    static private var settingsUrl: URL {
        FileManager.default.sharedContainerUrl
            .appendingPathComponent("settings_v2")
            .appendingPathExtension("json")
    }
    
    /// Reload settings
    func reload() {
        if let propertiesData = FileManager.default.contents(atPath: Self.settingsUrl.path) {
            let decoder = JSONDecoder()
            properties = try! decoder.decode(SettingProperties.self, from: propertiesData)
        }
    }
}

/// Contains all settings of the app of this device
struct SettingProperties {
    
    #if TARGET_MAIN_APP
    /// Appearance of the app (light / dark / system)
    @SettingProperty(default: .system) public var appearance: Settings.Appearance
    #endif
    
    /// Style of the app (default / plain)
    @SettingProperty(default: .plain) public var style: Settings.Style
    
    /// Person that is logged in
    @SettingProperty(default: nil) public var person: Settings.Person?
    
    /// Late payment interest
    @SettingProperty(default: nil) public var latePaymentInterest: Settings.LatePaymentInterest?
    
    #if TARGET_MAIN_APP
    /// Apply settings
    func applySettings() {
        appearance.applySettings()
    }
    #endif
}
 
// Extension of SettingProperties to confirm to Codable
extension SettingProperties: Codable {
    
    /// Coding keys for codable
    private enum CodingKeys: CodingKey {
        
        #if TARGET_MAIN_APP
        /// For appearance
        case appearance
        #endif
        
        /// For stype
        case style
        
        /// For person
        case person
        
        /// For late payment interest
        case latePaymentInterest
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        func decode<Value>(_ type: Value.Type, with key: CodingKeys) throws -> Value? where Value: Decodable {
            if let value = try container.decodeIfPresent(Value?.self, forKey: key) {
                return value
            }
            return nil
        }
        #if TARGET_MAIN_APP
        if let appearance = try decode(Settings.Appearance.self, with: .appearance) {
            self.appearance = appearance
        }
        #endif
        if let style = try decode(Settings.Style.self, with: .style) {
            self.style = style
        }
        if let person = try decode(Settings.Person?.self, with: .person) {
            self.person = person
        }
        if let latePaymentInterest = try decode(Settings.LatePaymentInterest?.self, with: .latePaymentInterest) {
            self.latePaymentInterest = latePaymentInterest
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        #if TARGET_MAIN_APP
        try container.encode(_appearance.value, forKey: .appearance)
        #endif
        try container.encode(_style.value, forKey: .style)
        try container.encode(_person.value, forKey: .person)
        try container.encode(_latePaymentInterest.value, forKey: .latePaymentInterest)
    }
}

/// A Property of settings
@propertyWrapper struct SettingProperty<Value> {
    
    /// Value
    public var value: Value?
    
    /// Default value
    private let defaultValue: Value
    
    /// Indicates if widget shiuld be reloaded when value is set
    private let reloadWidget: Bool
    
    public init(wrappedValue: Value? = nil, default defaultValue: Value, reloadWidget: Bool = true) {
        self.value = wrappedValue
        self.defaultValue = defaultValue
        self.reloadWidget = reloadWidget
    }
    
    /// Wrapped value
    public var wrappedValue: Value {
        get {
            value ?? defaultValue
        }
        set {
            value = newValue
            #if TARGET_MAIN_APP
            if reloadWidget {
                WidgetCenter.shared.reloadTimelines(ofKind: "StrafenWidget")
            }
            #endif
        }
    }
}

// Extension of FileManager to get shared container Url
extension FileManager {
    
    /// Url of shared container
    var sharedContainerUrl: URL {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.stevenkellner.Strafen.settings")!
    }
}
