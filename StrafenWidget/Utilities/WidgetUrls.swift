//
//  WidgetUrls.swift
//  StrafenWidgetExtension
//
//  Created by Steven on 24.07.20.
//

import SwiftUI

/// Json of the app urls that contains urls of the lists / changers and settings.
let appUrls = """
        {
            "baseUrl": "http://svkleinsendelbach.de/strafen_v2",
            "imagesDirectory": "images",
            "lists": {
                "person": "lists/person.json",
                "fine": "lists/fine.json",
                "reason": "lists/reason.json",
                "allClubs": "allClubs.json"
            },
            "changer": {
                "newClub": "changer/newClub.php",
                "clubImage": "changer/clubImageChanger.php",
                "registerPerson": "changer/registerPerson.php",
                "mailCode": "changer/codeMail.php",
                "personImage": "changer/personImageChanger.php",
                "personList": "changer/personChanger.php",
                "reasonList": "changer/reasonChanger.php",
                "fineList": "changer/fineChanger.php",
                "latePaymentInterest": "changer/latePaymentInterestChanger.php",
                "forceSignOut": "changer/forceSignOutChanger.php",
                "deleteClub": "changer/deleteClub.php"
            },
            "authorization": "c3RldmVuOmZ5d3dlYi1yeWhrdU0tcXlneGU2",
            "key": "UM5fZEML22vzCQvMwyVN",
            "cipherKey": "3457758372438058",
            "settings": "settings.json",
            "notes": "notes.json"
        }
    """

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
        
        /// Late payment interest
        struct LatePaymentInterest: Codable {
            
            /// Compontents of date (day / month / year)
            enum DateComponent: String, Codable {
                
                /// Day
                case day
                
                /// Month
                case month
                
                /// Year
                case year
                
                /// Date component flag
                var dateComponentFlag: Calendar.Component {
                    switch self {
                    case .day:
                        return .day
                    case .month:
                        return .month
                    case .year:
                        return .year
                    }
                }
                
                /// Keypath from DateComponent
                var dateComponentKeyPath: KeyPath<DateComponents, Int?> {
                    switch self {
                    case .day:
                        return \.day
                    case .month:
                        return \.month
                    case .year:
                        return \.year
                    }
                }
                
                /// Number between dates
                func numberBetweenDates(start startDate: Date, end endDate: Date) -> Int {
                    let calender = Calendar.current
                    let startDate = calender.startOfDay(for: startDate)
                    let endDate = calender.startOfDay(for: endDate)
                    let components = calender.dateComponents([dateComponentFlag], from: startDate, to: endDate)
                    return components[keyPath: dateComponentKeyPath] ?? 0
                }
            }
            
            /// Contains value and unit of a time period
            struct TimePeriod: Codable {
                
                /// Value
                var value: Int
                
                /// Unit
                var unit: DateComponent
            }
            
            /// Interest free period
            var interestFreePeriod: TimePeriod
            
            /// Interest rate
            var interestRate: Double
            
            /// Interest period
            var interestPeriod: TimePeriod
            
            /// Compound interest
            var compoundInterest: Bool
        }
        
        /// Person that is logged in
        let person: Person?
        
        /// Style of the widget
        let style: Style
        
        /// Late payment interest
        let latePaymentInterest: LatePaymentInterest?
    }
    
    /// Logged in person
    var person: CodableSettings.Person?
    
    /// Style of the widget
    var style: CodableSettings.Style?
    
    /// Late payment interest
    var latePaymentInterest: CodableSettings.LatePaymentInterest?
    
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
            latePaymentInterest = settings.latePaymentInterest
        } else {
            person = nil
            style = nil
            latePaymentInterest = nil
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
