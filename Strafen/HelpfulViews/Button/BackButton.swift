//
//  BackButton.swift
//  Strafen
//
//  Created by Steven on 10.05.21.
//

import SwiftUI

/// Back  button
struct BackButton: View {

    /// Presentation mode
    @Environment(\.presentationMode) private var presentationMode

    public var body: some View {
        HStack(spacing: 0) {

            // Back Button
            Text("back-button-text", comment: "Text of button to get to last page.")
                .font(.system(size: 24, weight: .light))
                .foregroundColor(.textColor)
                .lineLimit(1)
                .padding(.leading, 10)
                .onTapGesture { presentationMode.wrappedValue.dismiss() }

            Spacer()
        }
    }
}
