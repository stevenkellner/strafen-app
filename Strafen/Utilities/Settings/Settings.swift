//
//  Settings.swift
//  Strafen
//
//  Created by Steven on 27.06.20.
//

import SwiftUI
import WidgetKit

/// Contains all settings of the app of this device
class Settings: ObservableObject {
    
    /// Deafulf setting for first apply
    static let `default` = CodableSettings(appearance: .system, style: .plain, person: nil, latePaymentInterest: nil)
    
    /// Shared instance for singelton
    static let shared = Settings()
    
    /// Private init for singleton
    private init() {
        let decoder = JSONDecoder()
        let data = FileManager.default.contents(atPath: AppUrls.shared.settingsUrl.path)!
        let setting = try! decoder.decode(CodableSettings.self, from: data)
        appearance = setting.appearance
        style = setting.style
        person = setting.person
    }
    
    /// Appearance of the app (light / dark / system)
    @Published var appearance: Appearance {
            didSet {
                appearance.applySettings()
                try! codableSettings.jsonData.write(to: AppUrls.shared.settingsUrl, options: .atomic)
            }
        }
    
    /// Style of the app (default / plain)
    @Published var style: Style {
            didSet {
                try! codableSettings.jsonData.write(to: AppUrls.shared.settingsUrl, options: .atomic)
                WidgetCenter.shared.reloadTimelines(ofKind: "StrafenWidget")
            }
        }
    
    /// Person that is logged in
    @Published var person: Person? {
           didSet {
               try! codableSettings.jsonData.write(to: AppUrls.shared.settingsUrl, options: .atomic)
                WidgetCenter.shared.reloadTimelines(ofKind: "StrafenWidget")
           }
       }
    
    /// Late payment interest
    @Published var latePaymentInterest: LatePaymentInterest? {
        didSet {
            try! codableSettings.jsonData.write(to: AppUrls.shared.settingsUrl, options: .atomic)
            WidgetCenter.shared.reloadTimelines(ofKind: "StrafenWidget")
        }
    }
    
    /// Codable settings for encoding
    var codableSettings: CodableSettings {
        CodableSettings(appearance: appearance, style: style, person: person, latePaymentInterest: latePaymentInterest)
    }
    
    /// Apply settings
    func applySettings() {
        appearance.applySettings()
    }
}

/// Contains all properies of the settings of the app of this device
class NewSettings: ObservableObject {
    
    /// Shared instance for singelton
    static let shared = NewSettings()
    
    /// Private init for singleton
    private init() {
        if let propertiesData = FileManager.default.contents(atPath: Self.settingsUrl.path) {
            let decoder = JSONDecoder()
            properties = try! decoder.decode(SettingProperties.self, from: propertiesData)
        } else {
            properties = SettingProperties()
        }
    }
    
    /// All settings properties
    @Published public var properties: SettingProperties {
        didSet {
            applySettings()
            saveProperties()
        }
    }
    
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
    
    /// Url for settings file
    static private var settingsUrl: URL {
        FileManager.default.sharedContainerUrl
            .appendingPathComponent("settings_v2")
            .appendingPathExtension("json")
    }
}

/// Contains all settings of the app of this device
struct SettingProperties: Codable {
    
    /// Appearance of the app (light / dark / system)
    @SettingProperty(default: .system) public var appearance: Settings.Appearance
    
    /// Style of the app (default / plain)
    @SettingProperty(default: .plain) public var style: Settings.Style
    
    /// Person that is logged in
    @SettingProperty(default: nil) public var person: Settings.Person?
    
    /// Late payment interest
    @SettingProperty(default: nil) public var latePaymentInterest: Settings.LatePaymentInterest?
    
    /// Apply settings
    func applySettings() {
        appearance.applySettings()
    }
}

/// A Property of settings
@propertyWrapper struct SettingProperty<Value>: Codable where Value: Codable {
    
    /// Value
    private var value: Value?
    
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
            if reloadWidget {
                WidgetCenter.shared.reloadTimelines(ofKind: "StrafenWidget")
            }
        }
    }
}
