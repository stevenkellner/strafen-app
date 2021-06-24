//
//  ReasonList.swift
//  Strafen
//
//  Created by Steven on 17.06.21.
//

import SwiftUI

/// List of all templates
struct ReasonList: View {

    /// Environment of the reason list
    @EnvironmentObject var reasonListEnvironment: ListEnvironment<FirebaseReasonTemplate>

    /// Currently logged in person
    @EnvironmentObject var person: Settings.Person

    /// Indicates whether the view is a placeholder
    let isPlaceholder: Bool

    init(placeholder: Bool = false) {
        self.isPlaceholder = placeholder
    }

    /// Text to search in person list
    @State var searchText = ""

    var body: some View {
        NavigationView {
            ZStack {

                // Background color
                Color.backgroundGray

                VStack(spacing: 10) {

                    // Header
                    Header(String(localized: "reason-list-header-text", comment: "Header of reason list view."))
                        .unredacted()
                        .padding(.top, 50)

                    // Empty list text
                    if reasonListEnvironment.list.isEmpty {
                        VStack(spacing: 50) {
                            Text("reason-list-empty-list", comment: "Message that reason list is empty.")
                                .foregroundColor(.textColor)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 25, weight: .thin))
                                .lineLimit(2)
                                .padding(.horizontal, 15)
                            if person.isCashier {
                                Text("reason-list-empty-list-cashier", comment: "Message that reason list is empty for the cashier.")
                                    .foregroundColor(.textColor)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 25, weight: .thin))
                                    .lineLimit(2)
                                    .padding(.horizontal, 15)
                            }
                        }.padding(.top, 50)
                    } else {

                        // Search bar and list
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 0) {

                                // Search text
                                if !reasonListEnvironment.list.isEmpty {
                                    SearchBar(searchText: $searchText)
                                        .frame(width: UIScreen.main.bounds.width * 0.95 + 15)
                                }

                                // Reason list
                                LazyVStack(spacing: 15) {
                                    ForEach(reasonListEnvironment.list.sortedForList(with: searchText)) { reason in
                                        ReasonListRow(reason: reason, searchText: $searchText, isPlaceholder: isPlaceholder)
                                    }
                                }.padding(.top, 10)

                            }
                        }

                    }

                    Spacer(minLength: 0)
                }

                // Add new reason button
                if !isPlaceholder {
                    AddNewListItemButton(isListEmpty: reasonListEnvironment.list.isEmpty) {
                        ReasonAddNew()
                    }
                }

            }.maxFrame.redacted(reason: isPlaceholder ? .placeholder : [])
        }
    }

    // A Row of reason list with details of one reason.
    struct ReasonListRow: View {

        /// Currently logged in person
        @EnvironmentObject var person: Settings.Person

        /// Contains details of the reason
        let reason: FirebaseReasonTemplate

        /// Text to search in person list
        @Binding var searchText: String

        /// Indicates whether the view is a placeholder
        let isPlaceholder: Bool

        /// Indicates if navigation link is active
        @State var isNavigationLinkActive = false

        var body: some View {
            SplittedOutlinedContent {

                // Left content
                HStack(spacing: 0) {
                    Text(reason.reason)
                        .foregroundColor(.textColor)
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
                    guard !isPlaceholder, person.isCashier else { return }
                    UIApplication.shared.dismissKeyboard()
                    searchText = ""
                    isNavigationLinkActive = true
                }
                .sheet(isPresented: $isNavigationLinkActive) {
                    ReasonEditor(reason)
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
