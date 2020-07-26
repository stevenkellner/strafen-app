//
//  WidgetUrls.swift
//  StrafenWidgetExtension
//
//  Created by Steven on 24.07.20.
//

import Foundation

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
    static let shared = Self()
    
    /// Private init for singleton
    private init() {
        let decoder = JSONDecoder()
        codableWidgetUrls = try! decoder.decode(CodableWidgetUrls.self, from: appUrls.data(using: .utf8)!)
        let archiveUrl = FileManager.default.sharedContainerUrl
        let settingsUrl = archiveUrl.appendingPathComponent(codableWidgetUrls.settings)
        let settingsData = FileManager.default.contents(atPath: settingsUrl.path)
        if let settingsData = settingsData {
            person = try! decoder.decode(CodableSettings.self, from: settingsData).person
        } else {
            person = nil
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
    
    /// Codable Settings to get logged in person
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
        
        /// Person that is logged in
        let person: Person?
    }
    
    /// Logged in person
    let person: CodableSettings.Person?
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
