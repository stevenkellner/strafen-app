//
//  HomeTab.swift
//  Strafen
//
//  Created by Steven on 27.05.21.
//

import SwiftUI

/// All available home tabs
class HomeTab: ObservableObject {

    /// All available tabs
    enum Tab {

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
            case .profileDetail: return "person"
            case .personList: return "person.2"
            case .reasonList: return "list.dash"
            case .addNewFine: return "plus"
            case .settings: return "gear"
            }
        }

        /// Title
        var title: String {
            switch self {
            case .profileDetail: return String(localized: "tab-bar-profile-detail", comment: "Text of profile detail tab bar item.")
            case .personList: return String(localized: "tab-bar-person-list", comment: "Text of person list tab bar item.")
            case .reasonList: return String(localized: "tab-bar-reason-list", comment: "Text of reason list tab bar item.")
            case .addNewFine: return String(localized: "tab-bar-add-new-fine", comment: "Text of add new fine tab bar item.")
            case .settings: return String(localized: "tab-bar-settings", comment: "Text of settings tab bar item.")
            }
        }
    }

    /// Shared instance for singelton
    static let shared = HomeTab()

    /// Private init for singleton
    private init() {}

    /// Active home tabs
    @Published var active: Tab = .profileDetail
}
