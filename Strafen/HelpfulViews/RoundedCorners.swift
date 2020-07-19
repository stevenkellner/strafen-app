//
//  RoundedCorners.swift
//  Strafen
//
//  Created by Steven on 28.06.20.
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
///     - Stroke Color: Color.custom.gray

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
        init(_ cornerRadius: CGFloat, corner: CornerSet = .all) {
            topLeft = corner.topLeft ? cornerRadius : 0
            topRight = corner.topRight ? cornerRadius : 0
            bottomRight = corner.bottomRight ? cornerRadius : 0
            bottomLeft = corner.bottomLeft ? cornerRadius : 0
        }
        
        /// Init with different corner radius.
        init(_ topLeft: CGFloat, _ topRight: CGFloat, _ bottomRight: CGFloat, _ bottomLeft: CGFloat) {
            self.topLeft = topLeft
            self.topRight = topRight
            self.bottomRight = bottomRight
            self.bottomLeft = bottomLeft
        }
    }
    
    /// All differnt corner sets
    enum CornerSet {
        
        /// All corners
        case all
        
        /// Only the two left
        case left
        
        /// Only the two right
        case right
        
        /// Only the two top
        case top
        
        /// Only the two bottom
        case bottom
        
        /// Top left and bottom right
        case mainDiagonal
        
        /// Top right and bottom left
        case secondaryDiagonal
        
        /// Only top left
        case topLeft
        
        /// Only top right
        case topRight
        
        /// Only bottom right
        case bottomRight
        
        /// Only bottom left
        case bottomLeft
        
        /// No corner
        case none
        
        /// Checks if the top left corner is in this set
        var topLeft: Bool {
            switch self {
            case .all, .left, .top, .mainDiagonal, .topLeft:
                return true
            case .right, .bottom, .secondaryDiagonal, .topRight, .bottomRight, .bottomLeft, .none:
                return false
            }
        }
        
        /// Checks if the top right corner is in this set
        var topRight: Bool {
            switch self {
            case .all, .right, .top, .secondaryDiagonal, .topRight:
                return true
            case .left, .bottom, .mainDiagonal, .topLeft, .bottomRight, .bottomLeft, .none:
                return false
            }
        }
        
        /// Checks if the bottom right corner is in this set
        var bottomRight: Bool {
            switch self {
            case .all, .right, .bottom, .mainDiagonal, .bottomRight:
                return true
            case .left, .top, .secondaryDiagonal, .topLeft, .topRight, .bottomLeft, .none:
                return false
            }
        }
        
        /// Checks if the bottom left corner is in this set
        var bottomLeft: Bool {
            switch self {
            case .all, .left, .bottom, .secondaryDiagonal, .bottomLeft:
                return true
            case .right, .top, .mainDiagonal, .topLeft, .topRight, .bottomRight, .none:
                return false
            }
        }
    }
    
    /// Stroke color
    private var strokeColor = Color.custom.gray
    
    /// Fill color
    private var fillColor: Color = .clear
    
    /// Stroke width
    private var lineWidth: CGFloat = 1
    
    /// Radius of all corners
    private var radius: CGFloat = 10
    
    /// Set of rounded corners
    private let cornerSet: CornerSet
    
    /// Init with same corner radius.
    init(_ cornerSet: CornerSet = .all) {
        self.cornerSet = cornerSet
    }
    
    var body: some View {
        GeometryReader { geometry in
            RoundedCorners.path(width: geometry.size.width, height: geometry.size.height, cornerRadius: CornerRadius(radius, corner: cornerSet))
                .fill(self.fillColor)
                .overlay(
                    RoundedCorners.path(width: geometry.size.width, height: geometry.size.height, cornerRadius: CornerRadius(radius, corner: cornerSet))
                        .stroke(self.strokeColor, lineWidth: self.lineWidth)
                )
        }
    }
    
    /// Path of the outline
    static func path(width: CGFloat, height: CGFloat, cornerRadius: CornerRadius) -> some Shape {
        Path { path in
            
            // Make sure,the radius isn't larger than the Rectange.
            let topLeft = min(cornerRadius.topLeft, width / 2, height / 2)
            let topRight = min(cornerRadius.topRight, width / 2, height / 2)
            let bottomRight = min(cornerRadius.bottomRight, width / 2, height / 2)
            let bottomLeft = min(cornerRadius.bottomLeft, width / 2, height / 2)
            
            // Draw the Recatage with differnt corner radius.
            path.move(to: CGPoint(x: topLeft, y: 0))
            path.addLine(to: CGPoint(x: width - topRight, y: 0))
            path.addArc(center: CGPoint(x: width - topRight, y: topRight), radius: topRight, startAngle: .degrees(-90), endAngle: .zero, clockwise: false)
            path.addLine(to: CGPoint(x: width, y: height - bottomRight))
            path.addArc(center: CGPoint(x: width - bottomRight, y: height - bottomRight), radius: bottomRight, startAngle: .zero, endAngle: .degrees(90), clockwise: false)
            path.addLine(to: CGPoint(x: bottomLeft, y: height))
            path.addArc(center: CGPoint(x: bottomLeft, y: height - bottomLeft), radius: bottomLeft, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
            path.addLine(to: CGPoint(x: 0, y: topLeft))
            path.addArc(center: CGPoint(x: topLeft, y: topLeft), radius: topLeft, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        }
    }
    
    /// Set radius
    func radius(_ radius: CGFloat) -> RoundedCorners {
        var roundedCorners = self
        roundedCorners.radius = radius
        return roundedCorners
    }
    
    /// Set line width
    func lineWidth(_ lineWidth: CGFloat) -> RoundedCorners {
        var roundedCorners = self
        roundedCorners.lineWidth = lineWidth
        return roundedCorners
    }
    
    /// Set fill color
    func fillColor(_ fillColor: Color) -> RoundedCorners {
        var roundedCorners = self
        roundedCorners.fillColor = fillColor
        return roundedCorners
    }
    
    /// Set stroke color
    func strokeColor(_ strokeColor: Color) -> RoundedCorners {
        var roundedCorners = self
        roundedCorners.strokeColor = strokeColor
        return roundedCorners
    }
}

/// Outline for Row, Text or TextField
struct Outline: View {
    
    /// Set of rounded corners
    let cornerSet: RoundedCorners.CornerSet
    
    /// Set fill color only in default style
    private var onlyDefault = true
    
    /// Fill Color of the Outline
    private var fillColor: Color? = nil
    
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
            .strokeColor(settings.style.strokeColor(colorScheme))
    }
    
    /// Set fill color
    func fillColor(_ fillColor: Color, onlyDefault: Bool = true) -> Outline {
        var outline = self
        outline.fillColor = fillColor
        outline.onlyDefault = onlyDefault
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
