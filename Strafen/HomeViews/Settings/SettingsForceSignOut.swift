//
//  SettingsForceSignOut.swift
//  Strafen
//
//  Created by Steven on 24.06.21.
//

import SwiftUI

/// View to force sign out other persons
struct SettingsForceSignOut: View {

    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode

    /// Environment of the person list
    @EnvironmentObject var personListEnvironment: ListEnvironment<FirebasePerson>

    /// Currently logged in person
    @EnvironmentObject var loggedInPerson: Settings.Person

    /// Ids of selected persons
    @State var personIds = [FirebasePerson.ID]()

    /// Type of function call error
    @State var errorMessage: ErrorMessages?

    /// Connection State
    @State var connectionState: ConnectionState = .notStarted

    /// Text searched in search bar
    @State var searchText = ""

    var body: some View {
        ZStack {

            // Background Color
            Color.backgroundGray

            // Content
            VStack(spacing: 0) {

                // Back Button
                BackButton()
                    .padding(.top, 50)

                // Header
                Header(String(localized: "settings-force-sign-out-header", comment: "Header of settings force sign out view."))
                    .padding(.top, 10)

                // Empty List Text
                if personListEnvironment.list.isListEmpty {
                    Text(String(localized: "settings-force-sign-out-empty-list-text", comment: "Text of empty person list in settings force sign out view."))
                        .foregroundColor(.textColor)
                        .font(.system(size: 25, weight: .thin))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 15)
                        .padding(.top, 50)
                }

                // Search Bar and Person List
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 15) {

                        // Search Bar
                        if !personListEnvironment.list.isListEmpty {
                            SearchBar(searchText: $searchText)
                                .frame(width: UIScreen.main.bounds.width * 0.95 + 15)
                        }

                        LazyVStack(spacing: 15) {
                            ForEach(personListEnvironment.list.sortedForList(with: searchText)) { person in
                                SettingsForceSignOutRow(person: person, personIds: $personIds)
                            }
                        }
                    }.padding(.vertical, 10)
                }.padding(.top, 10)

                Spacer(minLength: 0)

                // Cancel and Confirm Button
                VStack(spacing: 5) {

                    // Error message
                    ErrorMessageView($errorMessage)

                    // Cancel and Confirm button
                    SplittedButton.cancelConfirm
                        .rightConnectionState($connectionState)
                        .onLeftClick { presentationMode.wrappedValue.dismiss() }
                        .onRightClick(perform: handleConfirm)

                }.padding(.bottom, 35)
                    .animation(.default, value: errorMessage)

            }

        }.maxFrame.dismissHandler
    }

    /// Handles cofirm button pressed
    func handleConfirm() async {
        guard !personListEnvironment.list.isListEmpty else {
            return presentationMode.wrappedValue.dismiss()
        }
        guard connectionState.restart() == .passed else { return }
        errorMessage = nil
        guard !personIds.isEmpty else {
            errorMessage = .noPersonSelected
            return connectionState.failed()
        }

        let result = await withTaskGroup(of: OperationResult.self, returning: OperationResult.self) { group in
            for personId in personIds {
                group.async {
                    do {
                        let callItem = await FFForceSignOutCall(clubId: loggedInPerson.club.id, personId: personId)
                        try await FirebaseFunctionCaller.shared.call(callItem)
                        return .passed
                    } catch { return .failed }
                }
            }
            return await group.contains(.failed) ? .failed : .passed
        }

        personIds = []
        guard result == .passed else {
            errorMessage = .internalErrorSave
            return connectionState.failed()
        }
        connectionState.passed()
        presentationMode.wrappedValue.dismiss()
    }

    /// Row of a SettingsForceSignOut
    struct SettingsForceSignOutRow: View {

        /// Currently logged in person
        @EnvironmentObject var loggedInPerson: Settings.Person

        /// Person of this row
        let person: FirebasePerson

        /// Ids of selected persons
        @Binding var personIds: [FirebasePerson.ID]

        /// Image of the person
        @State var image: UIImage?

        var body: some View {
            SingleOutlinedContent {
                HStack(spacing: 0) {

                    // Image
                    PersonRowImage(image: $image)

                    // Name
                    Text(person.name.formatted)
                        .font(.system(size: 20, weight: .thin))
                        .foregroundColor(personIds.contains(person.id) ? .customGreen : .textColor)
                        .lineLimit(1)
                        .padding(.horizontal, 15)

                    Spacer()
                }
            }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                .onTapGesture { personIds.toggle(person.id) }
                .task {
                    let imageType = FirebaseImageStorage.ImageType(id: person.id, clubId: loggedInPerson.club.id)
                    self.image = try? await FirebaseImageStorage.shared.getImage(imageType, size: .thumbsSmall)
                }
        }
    }
}

extension Array where Element == FirebasePerson {

    /// Filtered and sorted for person list
    fileprivate func sortedForList(with searchText: String) -> [FirebasePerson] {
        filter { person in
            let stringToTest = person.name.formatted.filter { !$0.isWhitespace }.lowercased()
            let searchText = searchText.filter { !$0.isWhitespace }.lowercased()
            return person.signInData != nil && !person.signInData!.isCashier && (searchText.isEmpty || stringToTest.contains(searchText))
        }.sorted {
            $0.name.formatted < $1.name.formatted
        }
    }

    /// Inidcates whether filtered person list is empty
    fileprivate var isListEmpty: Bool {
        sortedForList(with: "").isEmpty
    }
}
