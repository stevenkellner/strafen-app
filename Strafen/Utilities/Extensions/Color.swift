//
//  Color.swift
//  Strafen
//
//  Created by Steven on 27.06.20.
//

import SwiftUI

/// Custom colors for "Strafen" - App.
struct CustomColors {
   
   /// Custom gray Color
   let gray = Color(red: 112 / 255, green: 112 / 255, blue: 112 / 255)
   
   /// Custom darkGray Color
   let darkGray = Color(red: 28 / 255, green: 28 / 255, blue: 30 / 255)
   
   /// Custom darkGreen Color
   let darkGreen = Color(red: 106 / 255, green: 176 / 255, blue: 76 / 255)
   
   /// Custom lightGreen Color
   let lightGreen = Color(red: 186 / 255, green: 220 / 255, blue: 88 / 255)
   
   /// Custom yellow Color
   let yellow = Color(red: 254 / 255, green: 211 / 255, blue: 48 / 255)
   
   /// Custom orange Color
   let orange = Color(red: 255 / 255, green: 165 / 255, blue: 2 / 255)
   
   /// Custom red Color
   let red = Color(red: 238 / 255, green: 90 / 255, blue: 36 / 255)
   
   /// Custom blue Color
   let blue = Color(red: 24 / 255, green: 220 / 255, blue: 255 / 255)
}

/// Contains colors used in plain design
struct PlainColors {
    
    /// Plain light light gray Color
    let lightLightGray = Color(red: 240 / 255, green: 240 / 255, blue: 240 / 255)
    
    /// Plain light gray color
    let lightGray = Color(red: 180 / 255, green: 180 / 255, blue: 180 / 255)
    
    /// Plain dark gray color
    let darkGray = Color(red: 100 / 255, green: 100 / 255, blue: 100 / 255)
    
    /// Plain dark dark gray Color
    let darkDarkGray = Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255)
    
    /// Stroke color
    func strokeColor(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.plain.lightGray : Color.plain.darkGray
    }
    
    /// Background color
    func backgroundColor(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.plain.darkDarkGray : Color.plain.lightLightGray
    }
}

// Extension of Color for custom Colors
extension Color {
    
    /// Contains colors used in "SG-Stafen" - App.
    static let custom = CustomColors()
    
    /// Contains colors used in plain desing
    static let plain = PlainColors()
    
    /// Custom text color
    static let textColor = Color.custom.gray
}
