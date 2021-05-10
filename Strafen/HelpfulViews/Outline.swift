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
    private var cornerRadius: CGFloat? = nil
    
    /// Fill Color of the Outline
    private var fillColor: Color? = nil
    
    /// Stroke Color of the outline
    private var strokeColor: Color? = nil
    
    /// Line width of the outline
    private var lineWidth: CGFloat? = nil
    
    /// Init with corner set
    /// - Parameter cornerSet: corner set
    init(_ cornerSet: RoundedCorners.CornerSet = .all) {
        self.cornerSet = cornerSet
    }
    
    var body: some View {
        RoundedCorners(cornerSet)
            .radius(cornerRadius ?? 5)
            .lineWidth(lineWidth)
            .fillColor(.fieldGray)
            .strokeColor(.clear)
    }
    
    /// Set fill color of the outline
    /// - Parameter fillColor: fill color of the outline
    /// - Returns: modified outline
    func fillColor(_ fillColor: Color) -> Outline {
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
            
            // Content
            content
            
        }.shadow(color: .black.opacity(0.25), radius: 10)
    }
}

struct SplitedOutlinedContent<LeftContent, RightContent>: View where LeftContent: View, RightContent: View {
    
    /// Set of rounded corners
    let cornerSet: RoundedCorners.CornerSet
    
    /// Left content
    let leftContent: LeftContent
    
    /// Right content
    let rightContent: RightContent
    
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
            HStack(spacing: 0) {
                
                // Left outlined content
                ZStack {
                    
                    // Outline
                    Outline(cornerSet.intersection(.left))
                    
                    // Content
                    leftContent
                    
                }.frame(width: geometry.size.width / 2, height: geometry.size.height)
                
                // Right outlined content
                ZStack {
                    
                    // Outline
                    Outline(cornerSet.intersection(.right))
                    
                    // Content
                    rightContent
                    
                }.frame(width: geometry.size.width / 2, height: geometry.size.height)
                
            }
        }.shadow(color: .black.opacity(0.25), radius: 10)
    }
}
