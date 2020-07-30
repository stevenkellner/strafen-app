//
//  Outline.swift
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
    
    /// Corner radius
    private var radius: CGFloat? = nil
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Widget style
    let style: WidgetUrls.CodableSettings.Style
    
    init(style: WidgetUrls.CodableSettings.Style, _ cornerSet: RoundedCorners.CornerSet = .all) {
        self.style = style
        self.cornerSet = cornerSet
    }
    
    var body: some View {
        RoundedCorners(cornerSet)
            .radius(radius ?? style.radius)
            .lineWidth(style.lineWidth)
            .fillColor(onlyDefault ? style.fillColor(colorScheme, defaultStyle: fillColor) : fillColor!)
            .strokeColor(style.strokeColor(colorScheme))
    }
    
    /// Set fill color
    func fillColor(_ fillColor: Color, onlyDefault: Bool = true) -> Outline {
        var outline = self
        outline.fillColor = fillColor
        outline.onlyDefault = onlyDefault
        return outline
    }
    
    /// Set corner radius
    func radius(_ radius: CGFloat) -> Outline {
        var outline = self
        outline.radius = radius
        return outline
    }
}
