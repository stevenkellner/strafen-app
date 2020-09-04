//
//  Settings+Appereance.swift
//  Strafen
//
//  Created by Steven on 9/4/20.
//

import SwiftUI

extension Settings {
    
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
}
