//
//  OutlineAndSheetBar.swift
//  Strafen
//
//  Created by Steven on 26.07.20.
//

import SwiftUI

/// Outline for Row, Text or TextField
struct Outline: View {
    
    /// Set of rounded corners
    let cornerSet: RoundedCorners.CornerSet
    
    /// Set fill color only in default style
    private var onlyDefault = true
    
    /// Fill Color of the Outline
    private var fillColor: Color? = nil
    
    /// Stroke Color of the outline
    private var strokeColor: Color? = nil
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    init(_ cornerSet: RoundedCorners.CornerSet = .all) {
        self.cornerSet = cornerSet
    }
    
    var body: some View {
        RoundedCorners(cornerSet)
            .radius(settings.style.radius)
            .lineWidth(settings.style.lineWidth)
            .fillColor(onlyDefault ? settings.style.fillColor(colorScheme, defaultStyle: fillColor) : fillColor!)
            .strokeColor(strokeColor ?? settings.style.strokeColor(colorScheme))
    }
    
    /// Set fill color
    func fillColor(_ fillColor: Color?, onlyDefault: Bool = true) -> Outline {
        var outline = self
        outline.fillColor = fillColor
        outline.onlyDefault = onlyDefault
        return outline
    }
    
    /// Set stroke color
    func strokeColor(_ strokeColor: Color?) -> Outline {
        var outline = self
        outline.strokeColor = strokeColor
        return outline
    }
}

/// Bar to wipe sheet down
struct SheetBar: View {
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    var body: some View {
        RoundedCorners()
            .radius(2.5)
            .lineWidth(2.5)
            .strokeColor(settings.style.strokeColor(colorScheme))
            .frame(width: 75, height: 2.5)
            .padding(.vertical, 20)
    }
}
