//
//  PersonDetail.swift
//  Strafen
//
//  Created by Steven on 16.06.21.
//

import SwiftUI

/// Person Detail View
struct PersonDetail: View {

    /// Currently logged in person
    @EnvironmentObject var loggedInPerson: Settings.Person

    /// Environment of the fine list
    @EnvironmentObject var fineListEnvironment: ListEnvironment<FirebaseFine>

    /// Environment of the reason list
    @EnvironmentObject var reasonListEnvironment: ListEnvironment<FirebaseReasonTemplate>

    /// Contains details of the person
    let person: FirebasePerson

    /// Image of the person
    @State var image: UIImage?

    /// Id of fine that is currenttly in large design
    @State var currentLargeFine: FirebaseFine.ID?

    var body: some View {
        ZStack {

            // Background color
            Color.backgroundGray

            VStack(spacing: 0) {

                // Back / edit button
                BackAndEditButton {
                    PersonEditor(person)
                }.padding(.top, 50)

                // Image
                PersonDetailImage($image, person: person)

                // Name
                Text(person.name.formatted)
                    .foregroundColor(.textColor)
                    .font(.system(size: 35, weight: .thin))
                    .lineLimit(1)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                // Amount Display
                AmountDisplay(personId: person.id)

                // Underlines
                Header.Underlines()

                // Empty List Text
                if fineListEnvironment.hasNoFines(of: person.id) {
                    VStack(spacing: 20) {
                        Text("person-detail-no-fines-message", comment: "Message that this person has no fines.")
                            .foregroundColor(.textColor)
                            .font(.system(size: 25, weight: .thin))
                            .lineLimit(1)
                            .padding(.horizontal, 15)
                        if loggedInPerson.isCashier {
                            Text("person-detail-how-new-fine-message", comment: "Message how you can add new fines.")
                                .foregroundColor(.textColor)
                                .font(.system(size: 25, weight: .thin))
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 15)
                        }
                    }.padding(.top, 20)
                }

                // Fine list
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 15) {
                        ForEach(fineListEnvironment.sortedForList(of: person.id, with: reasonListEnvironment.list)) { fine in
                            FineListRow(of: fine, currentLargeFine: $currentLargeFine)
                        }
                    }.padding(.top, 10)
                }.padding(.top, 10)

                Spacer(minLength: 0)
            }

            // Add New Fine Button
            AddNewListItemButton(isListEmpty: fineListEnvironment.list.filter({ $0.assoiatedPersonId == person.id }).isEmpty) {
                Text(verbatim: "Fine add new") // TODO
            }

//            AddNewListItemButton(list: $fineListData.list, listFilter: { $0.assoiatedPersonId == person.id }) {
//                VStack(spacing: 0) {
//
//                    // Bar to wipe sheet down
//                    SheetBar()
//
//                    // Content
//                    AddNewFine(with: person.id)
//                        .padding(.bottom, 15)
//
//                }
//            }

        }.maxFrame.dismissHandler
            .task {
                do {
                    let imageType = FirebaseImageStorage.ImageType(id: person.id, clubId: loggedInPerson.club.id)
                    image = try await FirebaseImageStorage.shared.getImage(imageType, size: .thumbBig)
                } catch {}
            }
    }
}

extension ListEnvironment where ListType == FirebaseFine {

    /// Filtered and sorted for person detail fine list
    fileprivate func sortedForList(of personId: FirebasePerson.ID, with reasonList: [FirebaseReasonTemplate]) -> [Element] {
        list.filter {
            $0.assoiatedPersonId == personId
        }.sorted { fine in
            fine.fineReason.reason(with: reasonList).localizedUppercase
        }
    }

    /// Indicathes whether given person has no fines
    /// - Parameter personId: id of the person
    /// - Returns: `true` if person has no fines, `false` otherwise
    fileprivate func hasNoFines(of personId: FirebasePerson.ID) -> Bool {
        list.filter { $0.assoiatedPersonId == personId }.isEmpty
    }
}
