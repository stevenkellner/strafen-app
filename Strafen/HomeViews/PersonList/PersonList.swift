//
//  PersonList.swift
//  Strafen
//
//  Created by Steven on 31.05.21.
//

import SwiftUI

/// List of all persons
struct PersonList: View {

    /// Environment of the person list
    @EnvironmentObject var personListEnvironment: ListEnvironment<FirebasePerson>

    /// Currently logged in person
    @EnvironmentObject var person: Settings.Person

    /// Text to search in person list
    @State var searchText = ""

    var body: some View {
        NavigationView {
            ZStack {

                // Background color
                Color.backgroundGray

                VStack(spacing: 10) {

                    // Header
                    Header(String(localized: "person-list-header-text", comment: "Header of person list view."))
                        .padding(.top, 50)

                    if personListEnvironment.list.isEmpty {

                        // Empty list text
                        if person.isCashier {
                            Text("person-list-empty-list-cashier", comment: "Message that person list is empty for the cashier.")
                                .foregroundColor(.textColor)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 25, weight: .thin))
                                .lineLimit(2)
                                .padding(.horizontal, 15)
                                .padding(.top, 50)
                        } else {
                            Text("person-list-empty-list", comment: "Message that person list is empty.")
                                .foregroundColor(.textColor)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 25, weight: .thin))
                                .lineLimit(2)
                                .padding(.horizontal, 15)
                                .padding(.top, 50)
                        }

                    } else {

                        // Search bar and list
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 0) {

                                // Search text
                                if !personListEnvironment.list.isEmpty {
                                    SearchBar(searchText: $searchText)
                                        .frame(width: UIScreen.main.bounds.width * 0.95 + 15)
                                }

                                // Person list
                                LazyVStack(spacing: 15) {
                                    ForEach(personListEnvironment.list.sortedForList(loggedInPerson: person, with: searchText)) { person in
                                        PersonListRow(person: person, searchText: $searchText)
                                    }
                                }.padding(.vertical, 10)

                            }
                        }

                    }

                    Spacer(minLength: 0)
                }

                // Add new person button
                AddNewListItemButton(isListEmpty: personListEnvironment.list.isEmpty) {
                    PersonAddNew()
                }

            }.maxFrame
        }
    }

    /// A Row of person list with details of one person.
    struct PersonListRow: View {

        /// Environment of the fine list
        @EnvironmentObject var fineListEnvironment: ListEnvironment<FirebaseFine>

        /// Environment of the reason list
        @EnvironmentObject var reasonListEnvironment: ListEnvironment<FirebaseReasonTemplate>

        /// Currently logged in person
        @EnvironmentObject var loggedInPerson: Settings.Person

        /// Contains details of the person
        let person: FirebasePerson

        /// Text to search in person list
        @Binding var searchText: String

        /// Indicates if navigation link is active
        @State var isNavigationLinkActive = false

        /// Person image
        @State var image: UIImage?

        var body: some View {
            ZStack {

                // Navigation link to person detail
                EmptyNavigationLink(isActive: $isNavigationLinkActive) {
                    PersonDetail(person: person)
                }

                SplittedOutlinedContent {

                    // Left content
                    HStack(spacing: 0) {

                        // Image
                        PersonRowImage(image: $image)
                            .padding(.leading, 10)

                        // Name
                        Text(person.name.formatted)
                            .foregroundColor(.textColor)
                            .font(.system(size: 20, weight: .thin))
                            .lineLimit(1)
                            .padding(.leading, 10)

                        Spacer()
                    }

                } rightContent: {

                    // Right content
                    Text(describing: amount)
                        .foregroundColor(amountColor)
                        .font(.system(size: 20, weight: .thin))
                        .lineLimit(1)

                }.leftWidthPercentage(0.7)
                    .frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                    .onTapGesture {
                        UIApplication.shared.dismissKeyboard()
                        searchText = ""
                        isNavigationLinkActive = true
                    }
                    .onAppear {
                        async {
                            do {
                                let imageType = FirebaseImageStorage.ImageType(id: person.id, clubId: loggedInPerson.club.id)
                                image = try await FirebaseImageStorage.shared.getImage(imageType, size: .thumbsSmall)
                            } catch {}
                        }
                    }
            }
        }

        /// Color of amount text, `.customRed` if unpayed amount sum is not `.zero`, otherwise `.customGreen`
        var amountColor: Color {
            let unpayedSum = fineListEnvironment.list.unpayed(of: person.id, with: reasonListEnvironment.list)
            if unpayedSum != .zero { return .customRed }
            return .customGreen
        }

        /// Unpayed amount sum of the person if not `.zero`, otherwise payed amount sum
        var amount: Amount {
            let unpayedSum = fineListEnvironment.list.unpayed(of: person.id, with: reasonListEnvironment.list)
            if unpayedSum != .zero { return unpayedSum }
            return fineListEnvironment.list.payed(of: person.id, with: reasonListEnvironment.list)
        }
    }
}

// Extension of Array to filter and sort it for person list
extension Array where Element == FirebasePerson {

    /// Filtered and sorted for person list
    fileprivate func sortedForList(loggedInPerson: Settings.Person, with searchText: String) -> [Element] {
        filter {
            let stringToTest = $0.name.formatted.filter { !$0.isWhitespace }.lowercased()
            let searchText = searchText.filter { !$0.isWhitespace }.lowercased()
            return searchText.isEmpty || stringToTest.contains(searchText)
        }.sorted {
            if $0.id == loggedInPerson.id { return true }
            if $1.id == loggedInPerson.id { return false }
            return $0.name.formatted < $1.name.formatted
        }
    }
}
