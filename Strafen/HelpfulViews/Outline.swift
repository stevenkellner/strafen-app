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

struct SplitedOutlinedContent<LeftContent, RightContent>: View where LeftContent: View, RightContent: View {

    /// Set of rounded corners
    let cornerSet: RoundedCorners.CornerSet

    /// Left content
    let leftContent: LeftContent

    /// Right content
    let rightContent: RightContent

    /// Fill Color of the left outline
    private var leftFillColor: Color?

    /// Fill Color of the right outline
    private var rightFillColor: Color?

    /// Stroke Color of the left outline
    private var leftStrokeColor: Color?

    /// Stroke Color of the right outline
    private var rightStrokeColor: Color?

    /// Line width of the left outline
    private var leftLineWidth: CGFloat?

    /// Line width of the right outline
    private var rightLineWidth: CGFloat?

    /// Cornder radius of the left outline
    private var leftCornerRadius: CGFloat?

    /// Cornder radius of the right outline
    private var rightCornerRadius: CGFloat?

    /// Init with corner set and content
    /// - Parameters:
    ///   - cornerSet: corner set
    ///   - leftContent: left content
    ///   - rightContent: right content
    init(_ cornerSet: RoundedCorners.CornerSet = .all, @ViewBuilder leftContent: () -> LeftContent, @ViewBuilder rightContent: () -> RightContent) {
        self.cornerSet = cornerSet
        self.leftContent = leftContent()
        self.rightContent = rightContent()
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: (leftLineWidth ?? 0) + (rightLineWidth ?? 0)) {

                // Left outlined content
                ZStack {

                    // Outline
                    Outline(cornerSet.intersection(.left))
                        .fillColor(leftFillColor)
                        .strokeColor(leftStrokeColor)
                        .lineWidth(leftLineWidth)
                        .radius(leftCornerRadius)

                    // Content
                    leftContent

                }.frame(width: geometry.size.width / 2, height: geometry.size.height)

                // Right outlined content
                ZStack {

                    // Outline
                    Outline(cornerSet.intersection(.right))
                        .fillColor(rightFillColor)
                        .strokeColor(rightStrokeColor)
                        .lineWidth(rightLineWidth)
                        .radius(rightCornerRadius)

                    // Content
                    rightContent

                }.frame(width: geometry.size.width / 2, height: geometry.size.height)

            }
        }.shadow(color: .black.opacity(0.25), radius: 10)
    }

    /// Set fill color of the left outline
    /// - Parameter fillColor: fill color of the left outline
    /// - Returns: modified outline
    func leftFillColor(_ fillColor: Color?) -> SplitedOutlinedContent {
        var outline = self
        outline.leftFillColor = fillColor
        return outline
    }

    /// Set fill color of the right outline
    /// - Parameter fillColor: fill color of the right outline
    /// - Returns: modified outline
    func rightFillColor(_ fillColor: Color?) -> SplitedOutlinedContent {
        var outline = self
        outline.rightFillColor = fillColor
        return outline
    }

    /// Set stroke color of the left outline
    /// - Parameter strokeColor: stroke color of the left outline
    /// - Returns: modified outline
    func leftStrokeColor(_ strokeColor: Color?) -> SplitedOutlinedContent {
        var outline = self
        outline.leftStrokeColor = strokeColor
        return outline
    }

    /// Set stroke color of the right outline
    /// - Parameter strokeColor: stroke color of the right outline
    /// - Returns: modified outline
    func rightStrokeColor(_ strokeColor: Color?) -> SplitedOutlinedContent {
        var outline = self
        outline.rightStrokeColor = strokeColor
        return outline
    }

    /// Set line width of the left outline
    /// - Parameter lineWidth: line width of the left outline
    /// - Returns: modified outline
    func leftLineWidth(_ lineWidth: CGFloat?) -> SplitedOutlinedContent {
        var outline = self
        outline.leftLineWidth = lineWidth
        return outline
    }

    /// Set line width of the right outline
    /// - Parameter lineWidth: line width of the right outline
    /// - Returns: modified outline
    func rightLineWidth(_ lineWidth: CGFloat?) -> SplitedOutlinedContent {
        var outline = self
        outline.rightLineWidth = lineWidth
        return outline
    }

    /// Set corner radius of the left outline
    /// - Parameter radius: corner radius of the left outline
    /// - Returns: modified outline
    func leftRadius(_ radius: CGFloat?) -> SplitedOutlinedContent {
        var outline = self
        outline.leftCornerRadius = radius
        return outline
    }

    /// Set corner radius of the right outline
    /// - Parameter radius: corner radius of the right outline
    /// - Returns: modified outline
    func rightRadius(_ radius: CGFloat?) -> SplitedOutlinedContent {
        var outline = self
        outline.rightCornerRadius = radius
        return outline
    }
}
