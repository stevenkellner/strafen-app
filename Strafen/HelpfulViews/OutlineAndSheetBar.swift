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
    
    /// Line width of the outline
    private var lineWidth: CGFloat? = nil
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = NewSettings.shared
    
    init(_ cornerSet: RoundedCorners.CornerSet = .all) {
        self.cornerSet = cornerSet
    }
    
    var body: some View {
        RoundedCorners(cornerSet)
            .radius(settings.properties.style.radius)
            .lineWidth(lineWidth ?? settings.properties.style.lineWidth)
            .fillColor(onlyDefault ? settings.properties.style.fillColor(colorScheme, defaultStyle: fillColor) : fillColor!)
            .strokeColor(strokeColor ?? settings.properties.style.strokeColor(colorScheme))
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
    
    /// Set line width
    func lineWidth(_ lineWidth: CGFloat?) -> Outline {
        var outline = self
        outline.lineWidth = lineWidth
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

/// Indicator
struct Indicator: View {
    
    /// Width
    let width: CGFloat
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = NewSettings.shared
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        RoundedCorners()
            .strokeColor(settings.properties.style == .default ? Color.custom.gray : Color.plain.strokeColor(colorScheme))
            .lineWidth(2.5)
            .radius(2.5)
            .frame(width: width, height: 2.5)
    }
}
