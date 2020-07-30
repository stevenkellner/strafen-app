//
//  WidgetUrls.swift
//  StrafenWidgetExtension
//
//  Created by Steven on 24.07.20.
//

import SwiftUI

/// Contains all urls for the widget
struct WidgetUrls {
    
    /// Urls of the different app types
    struct ListTypesUrls {
        
        /// for person
        let person: URL
        
        /// for fine
        let fine: URL
        
        /// for reason
        let reason: URL
    }
    
    /// Shared instance for singelton
    static var shared = Self()
    
    /// Private init for singleton
    private init() {
        let decoder = JSONDecoder()
        codableWidgetUrls = try! decoder.decode(CodableWidgetUrls.self, from: appUrls.data(using: .utf8)!)
        let archiveUrl = FileManager.default.sharedContainerUrl
        let settingsUrl = archiveUrl.appendingPathComponent(codableWidgetUrls.settings)
        let settingsData = FileManager.default.contents(atPath: settingsUrl.path)
        if let settingsData = settingsData {
            let settings = try! decoder.decode(CodableSettings.self, from: settingsData)
            person = settings.person
            style = settings.style
        } else {
            person = nil
            style = nil
        }
    }
    
    /// Used to decode app urls from json
    private var codableWidgetUrls: CodableWidgetUrls
    
    /// Url for the different app lists
    func listTypesUrls(of clubId: UUID) -> ListTypesUrls {
        let baseUrl = URL(string: codableWidgetUrls.baseUrl)!.appendingPathComponent("clubs").appendingPathComponent(clubId.uuidString)
        let personUrl = baseUrl.appendingPathComponent(codableWidgetUrls.lists.person)
        let fineUrl = baseUrl.appendingPathComponent(codableWidgetUrls.lists.fine)
        let reasonUrl = baseUrl.appendingPathComponent(codableWidgetUrls.lists.reason)
        return ListTypesUrls(person: personUrl, fine: fineUrl, reason: reasonUrl)
    }
    
    /// Url for the image directory of given clubId
    func imageDirUrl(of clubId: UUID) -> URL {
        let baseUrl = URL(string: codableWidgetUrls.baseUrl)!
        return baseUrl.appendingPathComponent("clubs").appendingPathComponent(clubId.uuidString).appendingPathComponent(codableWidgetUrls.imagesDirectory)
    }
    /// Contains username and password for website authorization
    var loginString: String {
        codableWidgetUrls.authorization
    }
    
    /// Codable Settings to get logged in person and style
    struct CodableSettings: Decodable {
        
        /// Logged in person
        struct Person: Decodable {
            
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
        
        /// Style of the widget (default / plain)
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
        
        /// Person that is logged in
        let person: Person?
        
        /// Style of the widget
        let style: Style
    }
    
    /// Logged in person
    var person: CodableSettings.Person?
    
    /// Style of the widget
    var style: CodableSettings.Style?
    
    /// Reload setting properties
    mutating func reloadSettings() {
        let decoder = JSONDecoder()
        let archiveUrl = FileManager.default.sharedContainerUrl
        let settingsUrl = archiveUrl.appendingPathComponent(codableWidgetUrls.settings)
        let settingsData = FileManager.default.contents(atPath: settingsUrl.path)
        if let settingsData = settingsData {
            let settings = try! decoder.decode(CodableSettings.self, from: settingsData)
            person = settings.person
            style = settings.style
        } else {
            person = nil
            style = nil
        }
    }
}

/// Used to decode app urls from json
struct CodableWidgetUrls: Decodable {
    
    /// Used to decode urls of the different app types
    struct AppTypes: Decodable {
        
        /// for person
        let person: String
        
        /// for fine
        let fine: String
        
        /// for reason
        let reason: String
    }
    
    /// Base url of server
    let baseUrl: String
    
    /// Url extensions for lists of different app types
    let lists: AppTypes
    
    /// Url extensions for image directory
    let imagesDirectory: String
    
    /// Authorization for server
    let authorization: String
    
    /// Url extension for settings file
    let settings: String
}
