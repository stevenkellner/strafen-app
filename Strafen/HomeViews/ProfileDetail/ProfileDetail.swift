//
//  ProfileDetail.swift
//  Strafen
//
//  Created by Steven on 27.05.21.
//

import SwiftUI

/// Detail View of loggedIn person
struct ProfileDetail: View {

    /// Currently logged in person
    @EnvironmentObject var person: Settings.Person

    /// Environment of the fine list
    @EnvironmentObject var fineListEnvironment: ListEnvironment<FirebaseFine>

    /// Environment of the reason list
    @EnvironmentObject var reasonListEnvironment: ListEnvironment<FirebaseReasonTemplate>

    /// Image of the person
    @State var image: UIImage?

    /// Id of fine that is currenttly in large design
    @State var currentLargeFine: FirebaseFine.ID?

    var body: some View {
        NavigationView {
            ZStack {

                // Background color
                Color.backgroundGray

                VStack(spacing: 10) {

                    // Image and edit button
                    ImageEditButton($image)

                    // Payed and unpayed Display
                    HStack(spacing: 0) {
                        Spacer()

                        // Payed Display
                        SingleAmountDisplay(.payed)

                        Spacer()

                        // Unpayed Display
                        SingleAmountDisplay(.unpayed)

                        Spacer()
                    }

                    // Total Display
                    HStack(spacing: 0) {
                        Spacer()
                        SingleAmountDisplay( .total)
                        Spacer()
                    }

                    // Underlines
                    Header.Underlines()

                    // Empty List Text
                    if fineListEnvironment.hasNoFines(of: person.id) {
                        Text("profile-detail-no-fines-message", comment: "Message that person has no fines.")
                            .foregroundColor(.textColor)
                            .font(.system(size: 25, weight: .thin))
                            .lineLimit(1)
                            .padding(.horizontal, 15)
                            .padding(.top, 20)
                    }

                    // Fine list
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 15) {
                            ForEach(fineListEnvironment.sortedForList(of: person.id, with: reasonListEnvironment.list)) { fine in
                                FineListRow(of: fine, currentLargeFine: $currentLargeFine)
                            }
                        }.padding(.vertical, 10)
                    }.padding(.top, 10)

                    Spacer(minLength: 0)
                }.padding(.top, 40)

            }.maxFrame
                .task {
                    do {
                        let imageType = FirebaseImageStorage.ImageType(id: person.id, clubId: person.club.id)
                        image = try await FirebaseImageStorage.shared.getImage(imageType, size: .thumbBig)
                    } catch {}
                }
        }
    }

    /// View with image and image edit button of signed in person
    struct ImageEditButton: View {

        /// Currently logged in person
        @EnvironmentObject var person: Settings.Person

        /// Person image
        @Binding var image: UIImage?

        /// Init with image binding
        init(_ image: Binding<UIImage?>) {
            self._image = image
        }

        /// Indicate if image picker is shown
        @State var showImagePicker = false

        var body: some View {
            HStack(spacing: 0) {

                // Image
                PersonDetailImage($image, person: person.firebasePerson)
                    .padding(.leading, image == nil ? 25 : 0)

                Spacer()

                // Edit button
                SingleOutlinedContent {
                    Text("edit-button-text", comment: "Text of edit button.")
                        .foregroundColor(.textColor)
                        .font(.system(size: 20, weight: .thin))
                        .lineLimit(1)
                }.frame(width: 150, height: 35)
                    .toggleOnTapGesture($showImagePicker)
                    .sheet(isPresented: self.$showImagePicker) {
                        ImagePicker($image) { image, _ in
                            async {
                                let imageType = FirebaseImageStorage.ImageType(id: person.id, clubId: person.club.id)
                                _ = try? await FirebaseImageStorage.shared.store(image, of: imageType)
                            }
                        }
                    }

            }.frame(height: 100)
                .padding(.horizontal, 30)
        }
    }
}

extension ListEnvironment where ListType == FirebaseFine {

    /// Filtered and sorted for profile detail fine list
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
