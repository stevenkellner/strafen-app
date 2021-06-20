//
//  AddNewFineReason.swift
//  Strafen
//
//  Created by Steven on 20.06.21.
//

import SwiftUI

/// View to select reason for new fine
struct AddNewFineReason: View {

    /// Environment of the reason list
    @EnvironmentObject var reasonListEnvironment: ListEnvironment<FirebaseReasonTemplate>

    /// Fine reason
    @Binding var fineReason: FineReason?

    /// Text searched in search bar
    @State var searchText = ""

    var body: some View {
        ZStack {

            // Background color
            Color.backgroundGray

            VStack(spacing: 0) {

                // Bar to wipe sheet down
                SheetBar()

                // Header
                Header(String(localized: "add-new-fine-reason-header-text", comment: "Header of add new fine reason view."))

                // Search bar and list
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        // Search text
                        if !reasonListEnvironment.list.isEmpty {
                            SearchBar(searchText: $searchText)
                                .frame(width: UIScreen.main.bounds.width * 0.95 + 15)
                        }

                        // Custom fine reason
                        TitledContent(String(localized: "add-new-fine-reason-custom-reason-title", comment: "Title of custom reason for add new fine reason.")) {
                            CustomReasonRow(fineReason: $fineReason)
                        }

                        // Empty List Text
                        if reasonListEnvironment.list.isEmpty {
                            Text("add-new-fine-reason-empty-list", comment: "Empty list text of add new fine reason.")
                                .foregroundColor(.textColor)
                                .font(.system(size: 25, weight: .thin))
                                .lineLimit(2)
                                .padding(.horizontal, 15)
                                .padding(.top, 50)
                            Text("add-new-fine-reason-empty-list-add-new", comment: "Empty list add new reason of new fine reason.")
                                .foregroundColor(.textColor)
                                .font(.system(size: 25, weight: .thin))
                                .lineLimit(2)
                                .padding(.horizontal, 15)
                                .padding(.top, 20)
                        }

                        // Reason list
                        TitledContent(String(localized: "add-new-fine-reason-reason-list-title", comment: "Title of reason list for add new fine reason.")) {
                            LazyVStack(spacing: 15) {
                                ForEach(reasonListEnvironment.list.sortedForList(with: searchText)) { reason in
                                    ReasonListRow(reason: reason, fineReason: $fineReason)
                                }
                            }.padding(.vertical, 10)
                        }

                    }
                }

                Spacer(minLength: 0)
            }
        }.maxFrame
    }

    /// Row for custom fine reason
    struct CustomReasonRow: View {

        /// Presentation mode
        @Environment(\.presentationMode) private var presentationMode

        /// Fine reason
        @Binding var fineReason: FineReason?

        /// Indicates whether custom fine reason editor sheet is shown
        @State var showCustomFineReasonSheet = false

        var body: some View {
            SplittedOutlinedContent {

                // Left content
                HStack(spacing: 0) {
                    Text((fineReason as? FineReasonCustom)?.reason ?? String(localized: "add-new-fine-reason-select-text", comment: "Text of select custom reason button."))
                        .foregroundColor(fineReason is FineReasonCustom ? .customGreen : .textColor)
                        .opacity(fineReason is FineReasonCustom ? 1 : 0.5)
                        .font(.system(size: 20, weight: .thin))
                        .lineLimit(1)
                        .padding(.leading, 10)
                    Spacer()
                }

            } rightContent: {

                // Right content
                Text(describing: (fineReason as? FineReasonCustom)?.amount ?? .zero)
                    .foregroundColor((fineReason as? FineReasonCustom)?.importance.color ?? .customGreen)
                    .font(.system(size: 20, weight: .thin))
                    .lineLimit(1)

            }.leftWidthPercentage(0.7)
                .frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                .toggleOnTapGesture($showCustomFineReasonSheet)
                .sheet(isPresented: $showCustomFineReasonSheet) {
                    AddNewFineCustomReason(with: $fineReason) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        }
    }

    /// Row of reason list
    struct ReasonListRow: View {

        /// Presentation mode
        @Environment(\.presentationMode) private var presentationMode

        /// Reason of this row
        let reason: FirebaseReasonTemplate

        /// Fine reason
        @Binding var fineReason: FineReason?

        var body: some View {
            SplittedOutlinedContent {

                // Left content
                HStack(spacing: 0) {
                    Text(reason.reason)
                        .foregroundColor(reason.id == (fineReason as? FineReasonTemplate)?.templateId ? .customGreen : .textColor)
                        .font(.system(size: 20, weight: .thin))
                        .lineLimit(1)
                        .padding(.leading, 10)
                    Spacer()
                }

            } rightContent: {

                // Right content
                Text(describing: reason.amount)
                    .foregroundColor(reason.importance.color)
                    .font(.system(size: 20, weight: .thin))
                    .lineLimit(1)

            }.leftWidthPercentage(0.7)
                .frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                .onTapGesture {
                    fineReason = reason.id == (fineReason as? FineReasonTemplate)?.templateId ? nil : FineReasonTemplate(templateId: reason.id)
                    presentationMode.wrappedValue.dismiss()
                }
        }
    }
}

extension Array where Element == FirebaseReasonTemplate {

    /// Filtered and sorted for reason list
    fileprivate func sortedForList(with searchText: String) -> [Element] {
        filter {
            let stringToTest = $0.reason.filter { !$0.isWhitespace }.lowercased()
            let searchText = searchText.filter { !$0.isWhitespace }.lowercased()
            return searchText.isEmpty || stringToTest.contains(searchText)
        }.sorted {
            $0.reason < $1.reason
        }
    }
}
