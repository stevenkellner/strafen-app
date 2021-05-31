//
//  SplittedButton.swift
//  Strafen
//
//  Created by Steven on 30.05.21.
//

import SwiftUI

/// Splitted button with a symbol
struct SplittedButton: View {

    /// Text of the left button
    private let leftText: String

    /// Text of the right button
    private let rightText: String

    /// Font size
    private var fontSize: CGFloat = 24

    /// Color of left text
    private var leftTextColor: Color?

    /// Color of right text
    private var rightTextColor: Color?

    /// Image of the left symbol
    private var leftImage: Image?

    /// Image of the right symbol
    private var rightImage: Image?

    /// Color of the left smbol
    private var leftColor: Color = .clear

    /// Color of the right symbol
    private var rightColor: Color = .clear

    /// Height of the left symbol
    private var leftSymbolHeight: CGFloat = 27

    /// Height of the right symbol
    private var rightSymbolHeight: CGFloat = 27

    /// Left Bbtton handler
    private var leftButtonHandler: (() -> Void)?

    /// Right button handler
    private var rightButtonHandler: (() -> Void)?

    /// Connection state of left button
    private var leftConnectionState: Binding<ConnectionState>?

    /// Connection state of right button
    private var rightConnectionState: Binding<ConnectionState>?

    /// Init with text of the button
    /// - Parameter leftText: text of the left button
    /// - Parameter rightText: text of the right button
    init(left leftText: String, right rightText: String) {
        self.leftText = leftText
        self.rightText = rightText
    }

    var body: some View {
        SplittedOutlinedContent {
            HStack(spacing: 0) {

                // Symbol
                if leftConnectionState?.wrappedValue == .loading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .textColor))
                        .frame(width: leftSymbolHeight, height: leftSymbolHeight)
                        .padding(.leading, 10)
                } else if let image = leftImage {
                    image.resizable()
                        .scaledToFit()
                        .foregroundColor(leftColor)
                        .frame(height: leftSymbolHeight)
                        .padding(.leading, 10)
                }

                // Text
                Text(leftText)
                    .font(.system(size: fontSize, weight: .light))
                    .foregroundColor(leftTextColor ?? .textColor)
                    .lineLimit(1)
                    .padding(.horizontal, 10)

            }
        } rightContent: {
            HStack(spacing: 0) {

                // Text
                Text(rightText)
                    .font(.system(size: fontSize, weight: .light))
                    .foregroundColor(rightTextColor ?? .textColor)
                    .lineLimit(1)
                    .padding(.horizontal, 10)

                // Symbol
                if rightConnectionState?.wrappedValue == .loading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .textColor))
                        .frame(width: rightSymbolHeight, height: rightSymbolHeight)
                        .padding(.trailing, 10)
                } else if let image = rightImage {
                    image.resizable()
                        .scaledToFit()
                        .foregroundColor(rightColor)
                        .frame(height: rightSymbolHeight)
                        .padding(.trailing, 10)
                }

            }
        }.onLeftTapGesture { leftButtonHandler?() }
            .onRightTapGesture { rightButtonHandler?() }
            .frame(width: UIScreen.main.bounds.width * 0.95, height: 55)
    }

    /// Sets font size of the text
    /// - Parameter size: font size of the text
    /// - Returns: modified single button
    public func fontSize(_ size: CGFloat) -> SplittedButton {
        var button = self
        button.fontSize = size
        return button
    }

    /// Sets text color of left button
    /// - Parameter size: text color of left button
    /// - Returns: modified single button
    public func leftTextColor(_ color: Color) -> SplittedButton {
        var button = self
        button.leftTextColor = color
        return button
    }

    /// Sets text color of right button
    /// - Parameter size: text color of right button
    /// - Returns: modified single button
    public func righttTextColor(_ color: Color) -> SplittedButton {
        var button = self
        button.rightTextColor = color
        return button
    }

    /// Sets left symbol of the button
    /// - Parameter image: left iamge of the button
    /// - Returns: modified single button
    public func leftSymbol(_ image: Image) -> SplittedButton {
        var button = self
        button.leftImage = image
        return button
    }

    /// Sets right symbol of the button
    /// - Parameter image: right image of the button
    /// - Returns: modified single button
    public func rightSymbol(_ image: Image) -> SplittedButton {
        var button = self
        button.rightImage = image
        return button
    }

    /// Sets left symbol of the button
    /// - Parameter symbolName: left symbol of the button
    /// - Returns: modified single button
    public func leftSymbol(name symbolName: String) -> SplittedButton {
        var button = self
        button.leftImage = Image(systemName: symbolName)
        return button
    }

    /// Sets right symbol of the button
    /// - Parameter symbolName: right symbol of the button
    /// - Returns: modified single button
    public func rightSymbol(name symbolName: String) -> SplittedButton {
        var button = self
        button.rightImage = Image(systemName: symbolName)
        return button
    }

    /// Sets color of the left symbol
    /// - Parameter color: color of the left symbol
    /// - Returns: modified single button
    public func leftColor(_ color: Color) -> SplittedButton {
        var button = self
        button.leftColor = color
        return button
    }

    /// Sets color of the right symbol
    /// - Parameter color: color of the right symbol
    /// - Returns: modified single button
    public func rightColor(_ color: Color) -> SplittedButton {
        var button = self
        button.rightColor = color
        return button
    }

    /// Sets height of the left symbol
    /// - Parameter height: height of the left symbol
    /// - Returns: modified single button
    public func leftSymbolHeight(_ height: CGFloat) -> SplittedButton {
        var button = self
        button.leftSymbolHeight = height
        return button
    }

    /// Sets height of the right symbol
    /// - Parameter height: height of the right symbol
    /// - Returns: modified single button
    public func rightSymbolHeight(_ height: CGFloat) -> SplittedButton {
        var button = self
        button.rightSymbolHeight = height
        return button
    }

    /// Sets left button handler
    /// - Parameter buttonHandler: left button handler
    /// - Returns: modified single button
    public func onLeftClick(perform buttonHandler: @escaping () -> Void) -> SplittedButton {
        var button = self
        button.leftButtonHandler = buttonHandler
        return button
    }

    /// Sets right button handler
    /// - Parameter buttonHandler: right button handler
    /// - Returns: modified single button
    public func onRightClick(perform buttonHandler: @escaping () -> Void) -> SplittedButton {
        var button = self
        button.rightButtonHandler = buttonHandler
        return button
    }

    /// Sets connection state of left button
    /// - Parameter connectionState: connection state
    /// - Returns: modified single button
    public func leftConnectionState(_ connectionState: Binding<ConnectionState>) -> SplittedButton {
        var button = self
        button.leftConnectionState = connectionState
        return button
    }

    /// Sets connection state of right button
    /// - Parameter connectionState: connection state
    /// - Returns: modified single button
    public func rightConnectionState(_ connectionState: Binding<ConnectionState>) -> SplittedButton {
        var button = self
        button.rightConnectionState = connectionState
        return button
    }

    /// Delete and confirm button
    static let deleteConfirm = SplittedButton(left: NSLocalizedString("delete-button-text", table: .otherTexts, comment: "Text of delete button"), right: NSLocalizedString("confirm-button-text", table: .otherTexts, comment: "Text of confirm button"))
        .fontSize(24)
        .leftSymbol(name: "trash")
        .rightSymbol(name: "checkmark.seal")
        .leftColor(.customRed)
        .rightColor(.customGreen)
        .leftTextColor(.customRed)
}
