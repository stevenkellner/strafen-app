//
//  SplittedOutlinedContent.swift
//  Strafen
//
//  Created by Steven on 30.05.21.
//

import SwiftUI

/// Splitted content with default outline
struct SplittedOutlinedContent<LeftContent, RightContent>: View where LeftContent: View, RightContent: View {

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

    /// Handles tap gesture on the left outline
    private var leftTapGestureHandler: (() -> Void)?

    /// Handles tap gesture on the right outline
    private var rightTapGestureHandler: (() -> Void)?

    /// Percentage of width of left outline
    @Clamping(0.0...1.0) private var leftWidthPercentage: CGFloat = 0.5

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
            HStack(spacing: ((leftLineWidth ?? 0) + (rightLineWidth ?? 0)) * 0.5) {

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

                }.frame(width: geometry.size.width * leftWidthPercentage, height: geometry.size.height)
                    .optionalTapGesture(perform: leftTapGestureHandler)

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

                }.frame(width: geometry.size.width  * (1 - leftWidthPercentage), height: geometry.size.height)
                    .optionalTapGesture(perform: rightTapGestureHandler)

            }
        }.shadow(color: .black.opacity(0.25), radius: 10)
    }

    /// Set fill color of the left outline
    /// - Parameter fillColor: fill color of the left outline
    /// - Returns: modified outline
    func leftFillColor(_ fillColor: Color?) -> SplittedOutlinedContent {
        var outline = self
        outline.leftFillColor = fillColor
        return outline
    }

    /// Set fill color of the right outline
    /// - Parameter fillColor: fill color of the right outline
    /// - Returns: modified outline
    func rightFillColor(_ fillColor: Color?) -> SplittedOutlinedContent {
        var outline = self
        outline.rightFillColor = fillColor
        return outline
    }

    /// Set stroke color of the left outline
    /// - Parameter strokeColor: stroke color of the left outline
    /// - Returns: modified outline
    func leftStrokeColor(_ strokeColor: Color?) -> SplittedOutlinedContent {
        var outline = self
        outline.leftStrokeColor = strokeColor
        return outline
    }

    /// Set stroke color of the right outline
    /// - Parameter strokeColor: stroke color of the right outline
    /// - Returns: modified outline
    func rightStrokeColor(_ strokeColor: Color?) -> SplittedOutlinedContent {
        var outline = self
        outline.rightStrokeColor = strokeColor
        return outline
    }

    /// Set stroke color of the left and right outline
    /// - Parameter strokeColor: stroke color of the left and right outline
    /// - Returns: modified outline
    func strokeColor(_ strokeColor: Color?) -> SplittedOutlinedContent {
        var outline = self
        outline.leftStrokeColor = strokeColor
        outline.rightStrokeColor = strokeColor
        return outline
    }

    /// Set line width of the left outline
    /// - Parameter lineWidth: line width of the left outline
    /// - Returns: modified outline
    func leftLineWidth(_ lineWidth: CGFloat?) -> SplittedOutlinedContent {
        var outline = self
        outline.leftLineWidth = lineWidth
        return outline
    }

    /// Set line width of the right outline
    /// - Parameter lineWidth: line width of the right outline
    /// - Returns: modified outline
    func rightLineWidth(_ lineWidth: CGFloat?) -> SplittedOutlinedContent {
        var outline = self
        outline.rightLineWidth = lineWidth
        return outline
    }

    /// Set line width of the left and right outline
    /// - Parameter lineWidth: line width of the left and right outline
    /// - Returns: modified outline
    func lineWidth(_ lineWidth: CGFloat?) -> SplittedOutlinedContent {
        var outline = self
        outline.leftLineWidth = lineWidth
        outline.rightLineWidth = lineWidth
        return outline
    }

    /// Set corner radius of the left outline
    /// - Parameter radius: corner radius of the left outline
    /// - Returns: modified outline
    func leftRadius(_ radius: CGFloat?) -> SplittedOutlinedContent {
        var outline = self
        outline.leftCornerRadius = radius
        return outline
    }

    /// Set corner radius of the right outline
    /// - Parameter radius: corner radius of the right outline
    /// - Returns: modified outline
    func rightRadius(_ radius: CGFloat?) -> SplittedOutlinedContent {
        var outline = self
        outline.rightCornerRadius = radius
        return outline
    }

    /// Set left width percentage of the outline  (between 0 and 1)
    /// - Parameter percentage: width percentage of left outline (between 0 and 1)
    /// - Returns: modified outline
    func leftWidthPercentage(_ percentage: CGFloat) -> SplittedOutlinedContent {
        var outline = self
        outline.leftWidthPercentage = percentage
        return outline
    }

    /// Set left tap gesture handler
    /// - Parameter handler: handles tap gesture on the left outline
    /// - Returns: modified outline
    func onLeftTapGesture(_ handler: @escaping () -> Void) -> SplittedOutlinedContent {
        var outline = self
        outline.leftTapGestureHandler = handler
        return outline
    }

    /// Set left tap gesture handler
    /// - Parameter handler: handles tap gesture on the left outline
    /// - Returns: modified outline
    func onLeftTapGesture(_ handler: @escaping () async -> Void) -> SplittedOutlinedContent {
        var outline = self
        outline.leftTapGestureHandler = { async { await handler() } }
        return outline
    }

    /// Set right tap gesture handler
    /// - Parameter handler: handles tap gesture on the right outline
    /// - Returns: modified outline
    func onRightTapGesture(_ handler: @escaping () -> Void) -> SplittedOutlinedContent {
        var outline = self
        outline.rightTapGestureHandler = handler
        return outline
    }

    /// Set right tap gesture handler
    /// - Parameter handler: handles tap gesture on the right outline
    /// - Returns: modified outline
    func onRightTapGesture(_ handler: @escaping () async -> Void) -> SplittedOutlinedContent {
        var outline = self
        outline.rightTapGestureHandler = { async { await handler() } }
        return outline
    }
}
