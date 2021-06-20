//
//  AddNewFinePerson.swift
//  Strafen
//
//  Created by Steven on 19.06.21.
//

import SwiftUI

/// View to select person for new fine
struct AddNewFinePerson: View {

    /// Presentation mode
    @Environment(\.presentationMode) private var presentationMode

    /// Environment of the person list
    @EnvironmentObject var personListEnvironment: ListEnvironment<FirebasePerson>

    /// Selected person ids
    @Binding var personIds: [FirebasePerson.ID]

    /// Text to search in person list
    @State var searchText = ""

    var body: some View {
        ZStack {

            // Background color
            Color.backgroundGray

            VStack(spacing: 0) {

                // Bar to wipe sheet down
                SheetBar()

                // Title
                Header(String(localized: "add-new-fine-person-header-text", comment: "Header of add new fine person view."))

                if personListEnvironment.list.isEmpty {
                    Text("person-list-empty-list", comment: "Message that person list is empty.")
                        .foregroundColor(.textColor)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 25, weight: .thin))
                        .lineLimit(2)
                        .padding(.horizontal, 15)
                        .padding(.top, 50)
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        // Search text
                        if !personListEnvironment.list.isEmpty {
                            SearchBar(searchText: $searchText)
                                .frame(width: UIScreen.main.bounds.width * 0.95 + 15)
                        }

                        // Person list
                        LazyVStack(spacing: 15) {
                            ForEach(personListEnvironment.list.sortedForList(with: searchText)) { person in
                                PersonListRow(personIds: $personIds, person: person)
                                    .onTapGesture { personIds.toggle(person.id) }
                            }
                        }.padding(.top, 10)

                    }
                }

                Spacer()

                // Confirm buttton
                SingleButton.confirm
                    .onClick {
                        presentationMode.wrappedValue.dismiss()
                    }.padding(.bottom, 35)
            }
        }.maxFrame
    }

    /// Row of person list
    struct PersonListRow: View {

        /// Currently logged in person
        @EnvironmentObject var loggedInPerson: Settings.Person

        /// Selected person ids
        @Binding var personIds: [FirebasePerson.ID]

        /// Person of this row
        let person: FirebasePerson

        /// Image of the person
        @State var image: UIImage?

        var body: some View {
            SingleOutlinedContent {
                HStack(spacing: 0) {
                    PersonRowImage(image: $image)
                        .padding(.leading, 10)
                    Text(person.name.formatted)
                        .foregroundColor(textColor)
                        .font(.system(size: 20, weight: .light))
                        .lineLimit(1)
                        .padding(.horizontal, 10)
                    Spacer()
                }
            }.frame(width: UIScreen.main.bounds.width * 0.95, height: 55)
                .task(fetchPersonImage)
        }

        /// Fetch person image
        func fetchPersonImage() async {
            do {
                let imageType = FirebaseImageStorage.ImageType(id: person.id, clubId: loggedInPerson.club.id)
                image = try await FirebaseImageStorage.shared.getImage(imageType, size: .thumbsSmall)
            } catch {}
        }

        /// Text color
        var textColor: Color {
            if personIds.contains(person.id) {
                return .customGreen
            }
            return .textColor
        }
    }
}

extension Array where Element == FirebasePerson {

    /// Filtered and sorted for person list
    fileprivate func sortedForList(with searchText: String) -> [Element] {
        filter {
            let stringToTest = $0.name.formatted.filter { !$0.isWhitespace }.lowercased()
            let searchText = searchText.filter { !$0.isWhitespace }.lowercased()
            return searchText.isEmpty || stringToTest.contains(searchText)
        }.sorted { $0.name.formatted < $1.name.formatted }
    }
}
