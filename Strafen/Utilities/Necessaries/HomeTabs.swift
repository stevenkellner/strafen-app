//
//  HomeTabs.swift
//  Strafen
//
//  Created by Steven on 20.07.20.
//

import SwiftUI

/// All available home tabs
class HomeTabs: ObservableObject {
    
    /// All available tabs
    enum Tabs {
        
        /// Profile detail
        case profileDetail
        
        /// Person list
        case personList
        
        /// Reason list
        case reasonList
        
        /// Add new fine
        case addNewFine
        
        /// Settings
        case settings
        
        /// System image name
        var imageName: String {
            switch self {
            case .profileDetail:
                return "person"
            case .personList:
                return "person.2"
            case .reasonList:
                return "list.dash"
            case .addNewFine:
                return "plus"
            case .settings:
                return "gear"
            }
        }
        
        /// Title
        var title: String {
            switch self {
            case .profileDetail:
                return "Profil"
            case .personList:
                return "Personen"
            case .reasonList:
                return "Strafenkatalog"
            case .addNewFine:
                return "Strafe"
            case .settings:
                return "Einstellungen"
            }
        }
    }
    
    /// Shared instance for singelton
    static let shared = HomeTabs()
    
    /// Private init for singleton
    private init() {}
    
    /// Active home tabs
    @Published var active: Tabs = .profileDetail
    
    /// Used only in swiftui preview to select active home tab
    @available(*, deprecated, message: "only use it in previews.")
    static func forPreview(_ active: Tabs) -> HomeTabs {
        let homeTabs = HomeTabs()
        homeTabs.active = active
        return homeTabs
    }
}
