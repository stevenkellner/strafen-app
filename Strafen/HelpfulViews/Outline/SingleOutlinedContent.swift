//
//  SingleOutlinedContent.swift
//  Strafen
//
//  Created by Steven on 30.05.21.
//

import SwiftUI

/// Single content with default outline
struct SingleOutlinedContent<Content>: View where Content: View {

    /// Set of rounded corners
    let cornerSet: RoundedCorners.CornerSet

    /// Content
    let content: Content

    /// Fill Color of the Outline
    private var fillColor: Color?

    /// Stroke Color of the outline
    private var strokeColor: Color?

    /// Line width of the outline
    private var lineWidth: CGFloat?

    /// Cornder radius
    private var cornerRadius: CGFloat?

    /// Init with corner set and content
    /// - Parameters:
    ///   - cornerSet: corner set
    ///   - content: content
    init(_ cornerSet: RoundedCorners.CornerSet = .all, @ViewBuilder content: () -> Content) {
        self.cornerSet = cornerSet
        self.content = content()
    }

    var body: some View {
        ZStack {

            // Outline
            Outline(cornerSet)
                .fillColor(fillColor)
                .strokeColor(strokeColor)
                .lineWidth(lineWidth)
                .radius(cornerRadius)
                .shadow(color: .black.opacity(0.25), radius: 10)

            // Content
            content

        }
    }

    /// Set fill color of the outline
    /// - Parameter fillColor: fill color of the outline
    /// - Returns: modified outline
    func fillColor(_ fillColor: Color?) -> SingleOutlinedContent {
        var outline = self
        outline.fillColor = fillColor
        return outline
    }

    /// Set stroke color of the outline
    /// - Parameter strokeColor: stroke color of the outline
    /// - Returns: modified outline
    func strokeColor(_ strokeColor: Color?) -> SingleOutlinedContent {
        var outline = self
        outline.strokeColor = strokeColor
        return outline
    }

    /// Set line width of the outline
    /// - Parameter lineWidth: line width of the outline
    /// - Returns: modified outline
    func lineWidth(_ lineWidth: CGFloat?) -> SingleOutlinedContent {
        var outline = self
        outline.lineWidth = lineWidth
        return outline
    }

    /// Set corner radius of the outline
    /// - Parameter radius: corner radius of the outline
    /// - Returns: modified outline
    func radius(_ radius: CGFloat?) -> SingleOutlinedContent {
        var outline = self
        outline.cornerRadius = radius
        return outline
    }
}
