//
//  DeleteAlert.swift
//  Strafen
//
//  Created by Steven on 30.05.21.
//

import SwiftUI
import ToastUI

/// Alert for deletion
struct DeleteAlert: View {

    /// Delete text
    let deleteText: String

    /// Indicates whether delete alert is currently shown
    @Binding var showDeleteAlert: Bool

    /// Executed on delete button press
    let deleteHandler: () -> Void

    var body: some View {
        ToastView {
            VStack(spacing: 10) {

                // Animated trash can
                LottieAnimation("lottie-delete-trash")
                    .size(width: UIScreen.main.bounds.height * 0.15, height: UIScreen.main.bounds.height * 0.25)
                    .frame(width: UIScreen.main.bounds.height * 0.15, height: UIScreen.main.bounds.height * 0.25)

                // Text
                Text(deleteText)
                    .lineLimit(2)
                    .foregroundColor(.textColor)
                    .font(.system(size: 20, weight: .light))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 15)

                // Text
                Text("fine-editor-delete-no-return", table: .profileDetail, comment: "Fine editor delete no return")
                    .lineLimit(2)
                    .foregroundColor(.textColor)
                    .font(.system(size: 16, weight: .thin))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 30)

                // Delete button
                SingleButton("delete-button-text", table: .otherTexts, comment: "Text of delete button")
                    .fontSize(24)
                    .textColor(.customRed)
                    .size(width: UIScreen.main.bounds.width * 0.6, height: 40)
                    .onClick {
                        showDeleteAlert = false
                        deleteHandler()
                    }

                // Cancel button
                SingleButton("cancel-button-text", table: .otherTexts, comment: "Text of cancel button")
                    .fontSize(24)
                    .size(width: UIScreen.main.bounds.width * 0.6, height: 40)
                    .onClick { showDeleteAlert = false }

            }.frame(width: UIScreen.main.bounds.width * 0.65)
        }.cocoaBlur(blurIntensity: 0.15)
    }
}
