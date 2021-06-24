//
//  SettingsFinesFormatter.swift
//  Strafen
//
//  Created by Steven on 23.06.21.
//

import SwiftUI

/// Fines Formatter View
struct FinesFormatter: View {

    /// Environment of the person list
    @EnvironmentObject var personListEnvironment: ListEnvironment<FirebasePerson>

    /// Environment of the fine list
    @EnvironmentObject var fineListEnvironment: ListEnvironment<FirebaseFine>

    /// Environment of the reason list
    @EnvironmentObject var reasonListEnvironment: ListEnvironment<FirebaseReasonTemplate>

    /// Preview text
    @State var previewText = ""

    /// Indicates if shared text has a header text
    @State var showHeaderText = true

    /// Indicates if shared text is expanded
    @State var showExpandedText = true

    var body: some View {
        ZStack {

            // Background Color
            Color.backgroundGray

            // Content
            VStack(spacing: 0) {

                // Back button
                BackButton()
                    .padding(.top, 50)

                // Header
                Header(String(localized: "settings-fine-formatter-header", comment: "Header of settings fine formatter view."))
                    .padding(.top, 10)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 15) {

                        // Header Text Changer
                        TitledContent(String(localized: "settings-fine-formatter-show-header-text-title", comment: "Title of show header text in fine formatter view.")) {
                            CustomToggle(String(localized: "settings-fine-formatter-show-header-text-title", comment: "Title of show header text in fine formatter view."), isOn: $showHeaderText)
                                .fieldSize(width: UIScreen.main.bounds.width * 0.95, height: 50)
                                .onChange(of: showHeaderText) { _ in
                                    withAnimation { previewText = shareText }
                                }
                        }

                        // Expanded Text Changer
                        TitledContent(String(localized: "settings-fine-formatter-show-additional-header-text-title", comment: "Title of show additional header text in fine formatter view.")) {
                            CustomToggle(String(localized: "settings-fine-formatter-show-additional-header-text-title", comment: "Title of show additional header text in fine formatter view."), isOn: $showExpandedText)
                                .fieldSize(width: UIScreen.main.bounds.width * 0.95, height: 50)
                                .onChange(of: showExpandedText) { _ in
                                    withAnimation { previewText = shareText }
                                }
                        }

                        // Preview Text
                        TitledContent(String(localized: "settings-fine-formatter-preview-title", comment: "Title of preview in fine formatter view.")) {
                            HStack {
                                Text(previewText)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.textColor)
                                    .font(.system(size: 20, weight: .thin))
                                    .lineLimit(nil)
                                    .padding(.horizontal, 20)
                                Spacer()
                            }
                        }

                    }.padding(.vertical, 10)
                }.padding(.top, 10)

                Spacer(minLength: 0)

                // Share and copy button
                SplittedButton(left: String(localized: "settings-fine-formatter-share-button-text", comment: "Text of share button in settings fine formatter view."),
                               right: String(localized: "settings-fine-formatter-copy-button-text", comment: "Text of copy button in settings fine formatter view."))
                    .fontSize(24)
                    .leftSymbol(name: "square.and.arrow.up")
                    .rightSymbol(name: "doc.on.doc")
                    .leftColor(.customGreen)
                    .onLeftClick {
                        ActivityView.shared.shareText(shareText)
                    }
                    .onRightClick {
                        UIPasteboard.general.string = shareText
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
                    .padding(.bottom, 35)
            }

        }.maxFrame.dismissHandler
            .onAppear { previewText = shareText }
    }

    /// Share text
    var shareText: String {
        var shareText = ""
        if showHeaderText {
            shareText.append(String(localized: "settings-fine-formatter-header-text", comment: "Text of header in fine formatter view."))
            if !showExpandedText {
                shareText.append(" " + String(localized: "settings-fine-formatter-additional-header-text", comment: "Text of additional header in fine formatter view."))
            }
            shareText.append("\n\n")
        }
        shareText.append(personListText)
        return shareText
    }

    /// Person list text
    var personListText: String {
        personListEnvironment.list.sorted {
            $0.name.formatted < $1.name.formatted
        }.compactMap { person in
            personText(of: person)
        }.joined(separator: showExpandedText ? "\n\n" : "\n")
    }

    /// Person text of given person
    func personText(of person: FirebasePerson) -> String? {
        let fineList = fineListEnvironment.list.filter {
            $0.assoiatedPersonId == person.id && !$0.isPayed
        }
        guard !fineList.isEmpty else { return nil }
        let amountSum = fineList.reduce(into: .zero) { result, fine in
            result += fine.completeAmount(with: reasonListEnvironment.list)
        }
        let personText = "\(person.name.formatted):\t \(String(describing: amountSum))"
        if showExpandedText {
            return "\(personText)\n\(fineText(of: fineList))"
        }
        return personText
    }

    /// Fine text of given fine list
    func fineText(of fineList: [FirebaseFine]) -> String {
        fineList.map { fine in
            "\t- \(fine.reason(with: reasonListEnvironment.list)),\n\t  \(fine.date.formattedLong):\t \(fine.completeAmount(with: reasonListEnvironment.list))"
        }.joined(separator: "\n")
    }
}
