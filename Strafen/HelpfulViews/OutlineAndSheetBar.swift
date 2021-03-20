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
    
    /// Cornder radius
    private var cornerRadius: CGFloat? = nil
    
    /// Fill Color of the Outline
    private var fillColor: FillColor? = nil
    
    /// Stroke Color of the outline
    private var strokeColor: Color? = nil
    
    /// Line width of the outline
    private var lineWidth: CGFloat? = nil
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    init(_ cornerSet: RoundedCorners.CornerSet = .all) {
        self.cornerSet = cornerSet
    }
    
    var body: some View {
        RoundedCorners(cornerSet)
            .radius(cornerRadius ?? settings.style.radius)
            .lineWidth(lineWidth ?? settings.style.lineWidth)
            .fillColor(fillColor?.color(settings) ?? settings.style.fillColor(colorScheme))
            .strokeColor(strokeColor ?? settings.style.strokeColor(colorScheme))
    }
    
    /// Set fill color
    func fillColor(_ fillColor: Color?, onlyDefault: Bool = true) -> Outline {
        var outline = self
        outline.fillColor = FillColor1(onlyDefault: onlyDefault, fillColor: fillColor)
        return outline
    }
    
    /// Set fill color
    func fillColor(default color: Color?) -> Outline {
        var outline = self
        if var fillColor = outline.fillColor as? FillColor2 {
            fillColor.defaultColor = color
            outline.fillColor = fillColor
        } else {
            outline.fillColor = FillColor2(defaultColor: color, plainColor: nil)
        }
        return outline
    }
    
    /// Set fill color
    func fillColor(plain color: Color?) -> Outline {
        var outline = self
        if var fillColor = outline.fillColor as? FillColor2 {
            fillColor.plainColor = color
            outline.fillColor = fillColor
        } else {
            outline.fillColor = FillColor2(defaultColor: nil, plainColor: color)
        }
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
    
    /// Set corner radius
    func radius(_ radius: CGFloat?) -> Outline {
        var outline = self
        outline.cornerRadius = radius
        return outline
    }
    
    #if TARGET_MAIN_APP
    func errorMessages(_ errorMessages: Binding<ErrorMessages?>) -> Outline {
        strokeColor(errorMessages.wrappedValue.map { _ in Color.custom.red })
            .lineWidth(errorMessages.wrappedValue.map { _ in CGFloat(2) })
    }
    #endif
}

fileprivate protocol FillColor {
    func color(_ settings: Settings) -> Color?
}

fileprivate struct FillColor1: FillColor {
    
    /// Set fill color only in default style
    let onlyDefault: Bool
    
    /// Fill Color of the Outline
    let fillColor: Color?
    
    func color(_ settings: Settings) -> Color? {
        guard !onlyDefault || settings.style == .default else { return nil }
        return fillColor
    }
}

fileprivate struct FillColor2: FillColor {
    
    /// Default color
    var defaultColor: Color?
    
    /// Plain color
    var plainColor: Color?
    
    func color(_ settings: Settings) -> Color? {
        settings.style == .default ? defaultColor : plainColor
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
    @ObservedObject var settings = Settings.shared
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        RoundedCorners()
            .strokeColor(settings.style == .default ? Color.custom.gray : Color.plain.strokeColor(colorScheme))
            .lineWidth(2.5)
            .radius(2.5)
            .frame(width: width, height: 2.5)
    }
}
