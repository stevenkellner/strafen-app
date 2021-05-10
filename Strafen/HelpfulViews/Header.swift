//
//  Header.swift
//  Strafen
//
//  Created by Steven on 10.05.21.
//

import SwiftUI

/// Page Header with underlines
struct Header: View {
    
    /// Page title
    private let title: String
    
    /// Line limit of the text
    private var lineLimit: Int? = 1
    
    /// Color of the text and underlines
    private var color: Color = .textColor
    
    /// Init with title
    /// - Parameter title: page title
    public init(_ title: String) {
        self.title = title
    }
    
    public var body: some View {
        VStack(spacing: 10) {
            
            // Title
            HStack {
                Text(title)
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(color)
                    .lineLimit(lineLimit)
                    .padding(.horizontal, UIScreen.main.bounds.width * 0.025)
                Spacer()
            }
            
            // Underlines
            Underlines()
                .color(color)
                
        }
    }
    
    /// Set line limit of the text
    /// - Parameter lineLimit: line limit of the text
    /// - Returns: modified header
    public func lineLimit(_ lineLimit: Int?) -> Header {
        var header = self
        header.lineLimit = lineLimit
        return header
    }
    
    /// Sets color of the text and underlines
    /// - Parameter color: color of the text and underlines
    /// - Returns: modified header
    public func color(_ color: Color) -> Header {
        var header = self
        header.color = color
        return header
    }
    
    /// Two underlines
    struct Underlines: View {
        
        /// Color of the underlines
        private var color: Color = .textColor
        
        var body: some View {
            VStack(spacing: 5) {
                
                // Top Underline
                HStack {
                    Rectangle()
                        .frame(width: 300, height: 2)
                        .border(color, width: 1)
                    Spacer()
                }
                
                // Bottom Underline
                HStack {
                    Rectangle()
                        .frame(width: 275, height: 2)
                        .border(color, width: 1)
                    Spacer()
                }
                
            }
        }
        
        /// Sets color the underlines
        /// - Parameter color: color of the underlines
        /// - Returns: modified underlines
        public func color(_ color: Color) -> Underlines {
            var underlines = self
            underlines.color = color
            return underlines
        }
    }
}
