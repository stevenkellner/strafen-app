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
