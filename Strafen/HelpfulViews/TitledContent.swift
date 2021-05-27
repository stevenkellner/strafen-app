//
//  TitledContent.swift
//  Strafen
//
//  Created by Steven on 10.05.21.
//

import SwiftUI

/// Content with title
struct TitledContent<Content>: View where Content: View {

    /// Title
    let title: String

    /// Content
    let content: Content

    /// Frame of content
    private var contentFrame: (width: CGFloat?, height: CGFloat?) = (width: nil, height: nil)

    /// Title color
    private var titleColor: Color?

    /// Init with title
    /// - Parameter title: title
    /// - Parameter content: content
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    /// Init with localized string
    /// - Parameters:
    ///   - key: key of localized string
    ///   - table: table of localization
    ///   - replaceDict: dictionary to replace for string interpolation   
    ///   - comment: comment for localization
    /// - Parameter content: content
    init(_ key: String, table: LocalizationTables, replaceDict: [String: String] = [:], comment: String, @ViewBuilder content: () -> Content) {
        self.title = NSLocalizedString(key, table: table, replaceDict: replaceDict, comment: comment)
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 5) {

            // Title
            HStack(spacing: 0) {
                Text("\(title):")
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(titleColor ?? .textColor)
                    .lineLimit(1)
                    .padding(.leading, 10)
                Spacer()
            }

            // Content
            content
                .frame(width: contentFrame.width, height: contentFrame.height)

        }
    }

    /// Set frame of content
    /// - Parameter size: size of the content
    /// - Returns: modified content
    func contentFrame(size: CGSize) -> TitledContent {
        var content = self
        content.contentFrame = (width: size.width, height: size.height)
        return content
    }

    /// Set frame of content
    /// - Parameters:
    ///   - width: width of the content
    ///   - height: height of the content
    /// - Returns: modified content
    func contentFrame(width: CGFloat? = nil, height: CGFloat? = nil) -> TitledContent {
        var content = self
        content.contentFrame = (width: width, height: height)
        return content
    }

    /// Sets title color
    /// - Parameter color: title color
    /// - Returns: modified content
    func titleColor(_ color: Color) -> TitledContent {
        var content = self
        content.titleColor = color
        return content
    }
}
