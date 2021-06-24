//
//  CustomToggle.swift
//  Strafen
//
//  Created by Steven on 16.05.21.
//

import SwiftUI

/// View used to toggle a bool
struct CustomToggle: View {

    /// Title of the bool to change
    private let title: String

    /// Bool to change
    @Binding private var boolToToggle: Bool

    /// Init with title and bool to change
    /// - Parameters:
    ///   - title: title of the bool to change
    ///   - boolToToggle: bool to change
    init(_ title: String, isOn boolToToggle: Binding<Bool>) {
        self.title = title
        self._boolToToggle = boolToToggle
    }

    /// Error message of the bool
    private var errorMessage: Binding<ErrorMessages?>?

    /// Textfield size
    private var fieldSize: (width: CGFloat?, height: CGFloat?)?

    var body: some View {
        VStack(spacing: 5) {
            SingleOutlinedContent {
                HStack(spacing: 0) {
                    Spacer()

                    // Title
                    Text(verbatim: "\(title):")
                        .foregroundColor(.textColor)
                        .font(.system(size: 20, weight: .light))
                        .padding(.horizontal, 15)
                        .lineLimit(1)

                    Spacer(minLength: 0)

                    // Toggle
                    HStack(spacing: 0) {
                        SplittedOutlinedContent {
                            Text("toggle-state-off", comment: "Text of toogle state off.")
                                .foregroundColor(boolToToggle ? .customRed : .textColor)
                                .font(.system(size: 16, weight: .light))
                                .padding(.horizontal, 5)
                                .lineLimit(1)
                        } rightContent: {
                            Text("toggle-state-on", comment: "Text of toogle state on.")
                                .foregroundColor(boolToToggle ? .textColor : .customGreen)
                                .font(.system(size: 16, weight: .light))
                                .padding(.horizontal, 5)
                                .lineLimit(1)
                        }.leftLineWidth(boolToToggle ? nil : 1)
                            .rightLineWidth(boolToToggle ? 1 : nil)
                            .leftStrokeColor(boolToToggle ? nil : .customRed)
                            .rightStrokeColor(boolToToggle ? .customGreen : nil)
                            .leftFillColor(boolToToggle ? nil : .customRed.opacity(0.25))
                            .rightFillColor(boolToToggle ? .customGreen.opacity(0.25) : nil)

                    }.frame(width: fieldSize?.width.map { $0 * 0.4 }, height: fieldSize?.height.map { $0 * 0.75 })
                        .toggleOnTapGesture($boolToToggle)
                        .padding(.trailing, 15)

                }
            }.strokeColor(errorMessage?.wrappedValue.map { _ in .customRed })
                .lineWidth(errorMessage?.wrappedValue.map { _ in 2 })
                .frame(width: fieldSize?.width, height: fieldSize?.height)

            // Error message
            if let errorMessage = errorMessage {
                ErrorMessageView(errorMessage)
            }
        }
    }

    /// Sets error message of the bool
    /// - Parameter errorMessage: error message of the bool
    /// - Returns: modified toggle
    public func errorMessage(_ errorMessage: Binding<ErrorMessages?>) -> CustomToggle {
        var toggle = self
        toggle.errorMessage = errorMessage
        return toggle
    }

    /// Set field size
    /// - Parameters:
    ///   - width: width of the field
    ///   - height: height of the field
    /// - Returns: modified toggle
    public func fieldSize(width: CGFloat? = nil, height: CGFloat? = nil) -> CustomToggle {
        var toggle = self
        toggle.fieldSize = (width: width, height: height)
        return toggle
    }

    /// Set field size
    /// - Parameter size: field size
    /// - Returns: modified toggle
    public func fieldSize(size: CGSize) -> CustomToggle {
        var toggle = self
        toggle.fieldSize = (width: size.width, height: size.height)
        return toggle
    }
}
