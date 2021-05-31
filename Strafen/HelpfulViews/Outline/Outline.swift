//
//  Outline.swift
//  Strafen
//
//  Created by Steven on 10.05.21.
//

import SwiftUI

/// Outline for Row, Text or TextField
struct Outline: View {

    /// Set of rounded corners
    let cornerSet: RoundedCorners.CornerSet

    /// Cornder radius
    private var cornerRadius: CGFloat?

    /// Fill Color of the Outline
    private var fillColor: Color?

    /// Stroke Color of the outline
    private var strokeColor: Color?

    /// Line width of the outline
    private var lineWidth: CGFloat?

    /// Init with corner set
    /// - Parameter cornerSet: corner set
    init(_ cornerSet: RoundedCorners.CornerSet = .all) {
        self.cornerSet = cornerSet
    }

    var body: some View {
        RoundedCorners(cornerSet)
            .radius(cornerRadius ?? 5)
            .lineWidth(lineWidth)
            .fillColor(fillColor ?? .fieldGray)
            .strokeColor(strokeColor ?? .clear)
    }

    /// Set fill color of the outline
    /// - Parameter fillColor: fill color of the outline
    /// - Returns: modified outline
    func fillColor(_ fillColor: Color?) -> Outline {
        var outline = self
        outline.fillColor = fillColor
        return outline
    }

    /// Set stroke color of the outline
    /// - Parameter strokeColor: stroke color of the outline
    /// - Returns: modified outline
    func strokeColor(_ strokeColor: Color?) -> Outline {
        var outline = self
        outline.strokeColor = strokeColor
        return outline
    }

    /// Set line width of the outline
    /// - Parameter lineWidth: line width of the outline
    /// - Returns: modified outline
    func lineWidth(_ lineWidth: CGFloat?) -> Outline {
        var outline = self
        outline.lineWidth = lineWidth
        return outline
    }

    /// Set corner radius of the outline
    /// - Parameter radius: corner radius of the outline
    /// - Returns: modified outline
    func radius(_ radius: CGFloat?) -> Outline {
        var outline = self
        outline.cornerRadius = radius
        return outline
    }
}
