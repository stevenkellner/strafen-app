//
//  DateChanger.swift
//  Strafen
//
//  Created by Steven on 30.05.21.
//

import SwiftUI

/// Date changer
struct DateChanger: View {

    /// Inputed date
    @Binding var date: Date

    /// Error message of date input
    @Binding var errorMessage: ErrorMessages?

    var body: some View {
        VStack(spacing: 5) {

            TitledContent(String(localized: "fine-editor-date-title", comment: "Plain text of date for text field title.")) {
                ZStack {

                    // Date View
                    SplittedOutlinedContent {

                        // Left outline
                        Text(verbatim: "\(String(localized: "fine-editor-date-placeholder", comment: "Plain text of date for text field placeholder.")):")
                            .foregroundColor(.textColor)
                            .font(.system(size: 20, weight: .thin))
                            .lineLimit(1)
                            .padding(.horizontal, 15)

                    } rightContent: {

                        // Right outline
                        Text(date.formattedLong)
                            .foregroundColor(.textColor)
                            .font(.system(size: 20, weight: .thin))
                            .lineLimit(1)
                            .padding(.horizontal, 5)
                    }.leftWidthPercentage(0.425)
                        .strokeColor(errorMessage.map { _ in .customRed})
                        .lineWidth(errorMessage.map { _ in 2 })

                    // Date Picker
                    DatePicker("", selection: $date, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                        .colorMultiply(.black)
                        .transformEffect(.init(scaleX: 4, y: 1.5))
                        .offset(x: -UIScreen.main.bounds.width * 0.35, y: -10)
                        .opacity(0.011)

                }.clipped()
            }.contentFrame(width: UIScreen.main.bounds.width * 0.95, height: 50)

            // Error Message
            ErrorMessageView($errorMessage)

        }.animation(.default)
    }
}
