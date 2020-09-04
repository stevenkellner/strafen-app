//
//  Settings+Style.swift
//  Strafen
//
//  Created by Steven on 9/4/20.
//

import SwiftUI

extension Settings {
    
    /// Style of the app (default / plain)
    enum Style: String, Codable {
        
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
}
