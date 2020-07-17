//
//  Settings.swift
//  Strafen
//
//  Created by Steven on 27.06.20.
//

import SwiftUI

/// Contains all settings of the app of this device
class Settings: ObservableObject {
    
    /// Used to en- / decode settings from json
    struct CodableSettings: Codable {
        
        /// Appearance of the app (light / dark / system)
        enum Appearance: String, Codable {
            
            /// Use system appearance
            case system
            
            /// Always use light appearance
            case light
            
            /// Always use dark appearance
            case dark
            
            /// UIUserInterfaceStyle for changing window style
            private var style: UIUserInterfaceStyle {
                switch self {
                case .system:
                    return .unspecified
                case .light:
                    return .light
                case .dark:
                    return .dark
                }
            }
            
            /// Apply the selected appearance
            func applySettings() {
                UIApplication.shared.windows.first!.overrideUserInterfaceStyle = style
            }
        }
        
        /// Style of the app (default / plain)
        enum Style: String, Codable, CaseIterable {
            
            /// Default style
            case `default`
            
            /// Plain style
            case plain
            
            /// Rounded Corners fillColor
            func fillColor(_ colorScheme: ColorScheme, defaultStyle: Color? = nil) -> Color {
                switch self {
                case .default:
                    if let defaultStyle = defaultStyle {
                        return defaultStyle
                    }
                    if colorScheme == .dark {
                        return Color.custom.darkGray
                    } else {
                        return .white
                    }
                case .plain:
                    return Color.plain.backgroundColor(colorScheme)
                }
            }
            
            /// Rounded Corners strokeColor
            func strokeColor(_ colorScheme: ColorScheme) -> Color {
                switch self {
                case .default:
                    return Color.custom.gray
                case .plain:
                    return Color.plain.strokeColor(colorScheme)
                }
            }
            
            /// Rounded Corners radius
            var radius: CGFloat {
                switch self {
                case .default:
                    return 10
                case .plain:
                    return 5
                }
            }
            
            /// Rounded Corners lineWWidth
            var lineWidth: CGFloat {
                switch self {
                case .default:
                    return 2
                case .plain:
                    return 0.5
                }
            }
         }
        
        /// Logged in person
        struct Person: Codable {
            
            /// Id of the person
            let id: UUID
            
            /// Name of the person
            let name: PersonName
            
            /// Id of the associated club
            let clubId: UUID
            
            /// Name of the associated club
            let clubName: String
            
            /// True if person is cashier of the club
            var isCashier: Bool
        }
        
        /// Appearance of the app (light / dark / system)
        let appearance: Appearance
        
        /// Style of the app (default / plain)
        let style: Style
        
        /// Person that is logged in
        let person: Person?
        
        /// Json data of this setting struct
        var jsonData: Data {
            let encoder = JSONEncoder()
            return try! encoder.encode(self)
        }
    }
    
    /// Appearance of the app (light / dark / system)
    @Published var appearance: CodableSettings.Appearance {
            didSet {
                appearance.applySettings()
                try! codableSettings.jsonData.write(to: AppUrls.shared.settingsUrl, options: .atomic)
            }
        }
    
    /// Style of the app (default / plain)
    @Published var style: CodableSettings.Style {
            didSet {
                try! codableSettings.jsonData.write(to: AppUrls.shared.settingsUrl, options: .atomic)
            }
        }
    
    /// Person that is logged in
    @Published var person: CodableSettings.Person? {
           didSet {
               try! codableSettings.jsonData.write(to: AppUrls.shared.settingsUrl, options: .atomic)
           }
       }
    
    /// Codable settings for encoding
    var codableSettings: CodableSettings {
        CodableSettings(appearance: appearance, style: style, person: person)
    }
    
    /// Deafulf setting for first apply
    static let `default` = CodableSettings(appearance: .system, style: CodableSettings.Style.allCases.randomElement()!, person: nil)
    
    /// Shared instance for singelton
    static let shared = Settings()
    
    /// Private init for singleton
    private init() {
        let decoder = JSONDecoder()
        let data = FileManager.default.contents(atPath: AppUrls.shared.settingsUrl.path)!
        let setting = try! decoder.decode(CodableSettings.self, from: data)
        appearance = setting.appearance
        style = .plain // TODO
        person = setting.person
    }
    
    /// Only use in preview
    init(style: CodableSettings.Style, isCashier: Bool) {
        appearance = .system
        self.style = style
        person = .init(id: UUID(), name: PersonName(firstName: "", lastName: ""), clubId: UUID(), clubName: "", isCashier: isCashier)
    }
    
    /// Apply settings
    func applySettings() {
        appearance.applySettings()
    }
}
