//
//  RoundedCorners.swift
//  Strafen
//
//  Created by Steven on 10.05.21.
//

import SwiftUI

/// Creates a Rectangle with custom corner radius.
///
/// Default:
///
///     - Corner Set: .all
///     - Radius: 10
///     - Line Width: 1
///     - Fill Color: .clear
///     - Stroke Color: .gray
///
struct RoundedCorners: View {

    /// Contains all corner radius.
    struct CornerRadius {

        /// Radius of the top left corner.
        let topLeft: CGFloat

        /// Radius of the top right corner.
        let topRight: CGFloat

        /// Radius of the bottom right corner.
        let bottomRight: CGFloat

        /// Radius of the bottom left corner.
        let bottomLeft: CGFloat

        /// Init with same corner radius.
        /// - Parameters:
        ///   - cornerRadius: radius of all corners in corner set
        ///   - corner: corner set
        init(_ cornerRadius: CGFloat, corner: CornerSet = .all) {
            topLeft = corner.contains(.topLeft) ? cornerRadius : 0
            topRight = corner.contains(.topRight) ? cornerRadius : 0
            bottomRight = corner.contains(.bottomRight) ? cornerRadius : 0
            bottomLeft = corner.contains(.bottomLeft) ? cornerRadius : 0
        }

        /// Init with different corner radius.
        /// - Parameters:
        ///   - topLeft: radius of top left corner
        ///   - topRight: radius of top right corner
        ///   - bottomRight: radius of bottom right corner
        ///   - bottomLeft: radius of bottom left corner
        init(_ topLeft: CGFloat, _ topRight: CGFloat, _ bottomRight: CGFloat, _ bottomLeft: CGFloat) {
            self.topLeft = topLeft
            self.topRight = topRight
            self.bottomRight = bottomRight
            self.bottomLeft = bottomLeft
        }
    }

    /// Set of corners
    struct CornerSet: OptionSet {

        let rawValue: Int

        /// Top left corner
        static let topLeft = CornerSet(rawValue: 1 << 0)

        /// Top right corner
        static let topRight = CornerSet(rawValue: 1 << 1)

        /// Bottom right corner
        static let bottomRight = CornerSet(rawValue: 1 << 2)

        /// Bottom left corner
        static let bottomLeft = CornerSet(rawValue: 1 << 3)

        /// Left corners
        static let left: CornerSet = [.topLeft, .bottomLeft]

        /// Right corners
        static let right: CornerSet = [.topRight, .bottomRight]

        /// Top corners
        static let top: CornerSet = [.topLeft, .topRight]

        /// Bottom corners
        static let bottom: CornerSet = [.bottomLeft, .bottomRight]

        /// All corners
        static let all: CornerSet = [.topLeft, .topRight, .bottomRight, .bottomLeft]

        /// Top left and bottom right corner
        static let mainDiagonal: CornerSet = [.topLeft, .bottomRight]

        /// Top right and bottom left corner
        static let secondaryDiagonal: CornerSet = [.topRight, .bottomLeft]

        /// No corners
        static let none: CornerSet = []
    }

    /// Shape of the rounded corner
    struct RoundedCornerShape: Shape {

        /// Corner radius
        let cornerRadius: CornerRadius

        func path(in rect: CGRect) -> Path {
            var path = Path()

            // Make sure,the radius isn't larger than the Rectange.
            let topLeftRadius = min(cornerRadius.topLeft, rect.width / 2, rect.height / 2)
            let topRightRadius = min(cornerRadius.topRight, rect.width / 2, rect.height / 2)
            let bottomRightRadius = min(cornerRadius.bottomRight, rect.width / 2, rect.height / 2)
            let bottomLeftRadius = min(cornerRadius.bottomLeft, rect.width / 2, rect.height / 2)

            // Draw the Recatage with differnt corner radius.
            path.move(to: CGPoint(x: rect.minX + topLeftRadius, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - topRightRadius, y: rect.minY))
            path.addArc(center: CGPoint(x: rect.maxX - topRightRadius, y: rect.minY + topRightRadius), radius: topRightRadius, startAngle: .degrees(-90), endAngle: .zero, clockwise: false)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRightRadius))
            path.addArc(center: CGPoint(x: rect.maxX - bottomRightRadius, y: rect.maxY - bottomRightRadius), radius: bottomRightRadius, startAngle: .zero, endAngle: .degrees(90), clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX + bottomLeftRadius, y: rect.maxY))
            path.addArc(center: CGPoint(x: rect.minX + bottomLeftRadius, y: rect.maxY - bottomLeftRadius), radius: bottomLeftRadius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeftRadius))
            path.addArc(center: CGPoint(x: rect.minX + topLeftRadius, y: rect.minY + topLeftRadius), radius: topLeftRadius, startAngle: .degrees(180), endAngle: .degrees(-90), clockwise: false)

            return path
        }
    }

    /// Stroke color
    private var strokeColor = Color.gray

    /// Fill color
    private var fillColor: Color = .clear

    /// Stroke width
    private var lineWidth: CGFloat? = 1

    /// Radius of all corners
    private var radius: CGFloat = 10

    /// Set of rounded corners
    private let cornerSet: CornerSet

    /// Init with same corner radius.
    /// - Parameter cornerSet: corner set
    init(_ cornerSet: CornerSet = .all) {
        self.cornerSet = cornerSet
    }

    var body: some View {
        GeometryReader { geometry in
            RoundedCornerShape(cornerRadius: CornerRadius(radius, corner: cornerSet))
                .fill(fillColor)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .overlay(
                    RoundedCornerShape(cornerRadius: CornerRadius(radius, corner: cornerSet))
                        .stroke(strokeColor, lineWidth: lineWidth ?? 0)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                )
        }
    }

    /// Set radius of rounded corners
    /// - Parameter radius: radius of rounded corners
    /// - Returns: modified rounded corners
    func radius(_ radius: CGFloat) -> RoundedCorners {
        var roundedCorners = self
        roundedCorners.radius = radius
        return roundedCorners
    }

    /// Set line width of rounded corners
    /// - Parameter lineWidth: line width of rounded corners
    /// - Returns: modified rounded corners
    func lineWidth(_ lineWidth: CGFloat?) -> RoundedCorners {
        var roundedCorners = self
        roundedCorners.lineWidth = lineWidth
        return roundedCorners
    }

    /// Set fill color of rounded corners
    /// - Parameter fillColor: fill color of rounded corners
    /// - Returns: modified rounded corners
    func fillColor(_ fillColor: Color) -> RoundedCorners {
        var roundedCorners = self
        roundedCorners.fillColor = fillColor
        return roundedCorners
    }

    /// Set stroke color of rounded corners
    /// - Parameter strokeColor: stroke color of rounded corners
    /// - Returns: modified rounded corners
    func strokeColor(_ strokeColor: Color) -> RoundedCorners {
        var roundedCorners = self
        roundedCorners.strokeColor = strokeColor
        return roundedCorners
    }
}
