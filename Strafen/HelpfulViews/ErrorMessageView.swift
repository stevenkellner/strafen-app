//
//  ErrorMessageView.swift
//  Strafen
//
//  Created by Steven on 15.05.21.
//

import SwiftUI

/// View to show error message
struct ErrorMessageView: View {

    /// Binding of the error message
    @Binding var errorMessage: ErrorMessages?

    /// Init with binding of the error message
    /// - Parameter errorMessage: binding of the error message
    init(_ errorMessage: Binding<ErrorMessages?>) {
        self._errorMessage = errorMessage
    }

    var body: some View {
        if let errorMessage = errorMessage {
            Text(errorMessage.message)
                .foregroundColor(.customRed)
                .font(.system(size: 20, weight: .regular))
                .lineLimit(1)
                .padding(.horizontal, 10)
        }
    }
}
