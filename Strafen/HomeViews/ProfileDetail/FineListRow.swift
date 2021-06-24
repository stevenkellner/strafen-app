//
//  FineListRow.swift
//  Strafen
//
//  Created by Steven on 29.05.21.
//

import SwiftUI

/// Row of fine list of profile / person detail
struct FineListRow: View {

    /// Fine of this row
    let fine: FirebaseFine

    /// Id of fine that is currenttly in large design
    @Binding var currentLargeFine: FirebaseFine.ID?

    /// Indicates whether the view is a placeholder
    let isPlaceholder: Bool

    init(of fine: FirebaseFine, currentLargeFine: Binding<FirebaseFine.ID?>, placeholder: Bool = false) {
        self.fine = fine
        self._currentLargeFine = currentLargeFine
        self.isPlaceholder = placeholder
    }

    /// Namespace for matched geometry effect
    @Namespace var namespace

    /// Indicates if navigation link is active
    @State var isNavigationLinkActive = false

    var body: some View {
        ZStack {

            // Navigation Link
            EmptyNavigationLink(isActive: $isNavigationLinkActive) {
                FineDetail(fine: fine)
            }

            if currentLargeFine == fine.id {

                // Large row
                LargeRow(fine: fine, isPlaceholder: isPlaceholder, namespace: namespace, isNavigationLinkActive: $isNavigationLinkActive)
                    .setOnTapGesture($currentLargeFine, to: nil, animation: .default)

            } else {

                // Small row
                SmallRow(fine: fine, isPlaceholder: isPlaceholder, namespace: namespace, isNavigationLinkActive: $isNavigationLinkActive)
                    .setOnTapGesture($currentLargeFine, to: fine.id, animation: .default)

            }

        }
    }

    /// Small row
    struct SmallRow: View {

        /// Environment of the reason list
        @EnvironmentObject var reasonListEnvironment: ListEnvironment<FirebaseReasonTemplate>

        /// Fine of this row
        let fine: FirebaseFine

        /// Indicates whether the view is a placeholder
        let isPlaceholder: Bool

        /// Namespace for matched geometry effect
        let namespace: Namespace.ID

        /// Indicates if navigation link is active
        @Binding var isNavigationLinkActive: Bool

        var body: some View {
            GeometryReader { geometry in
                SplittedOutlinedContent {

                    // Left outline
                    Text(describing: fine.completeAmount(with: reasonListEnvironment.list))
                        .foregroundColor(fine.amountTextColor(with: reasonListEnvironment.list))
                        .font(.system(size: 20, weight: .thin))
                        .lineLimit(1)
                        .matchedGeometryEffect(id: "firstOutline", in: namespace)

                } rightContent: {

                    // Right outline
                    HStack(spacing: 0) {

                        // Reason text
                        Text(fine.reason(with: reasonListEnvironment.list))
                            .foregroundColor(.textColor)
                            .font(.system(size: 20, weight: .thin))
                            .lineLimit(1)
                            .padding(.leading, 10)
                            .matchedGeometryEffect(id: "reason", in: namespace)

                        Spacer()

                        // Arrow
                        HStack(spacing: 0) {
                            Image(systemName: "control")
                                .rotationEffect(.radians(.pi / 2))
                                .padding(.leading, 10)
                                .foregroundColor(.textColor)
                            Spacer()
                        }.frame(width: geometry.size.width * 0.1, height: geometry.size.height)
                            .matchedGeometryEffect(id: "secondOutline", in: namespace)
                            .unredacted()
                            .onTapGesture {
                                guard !isPlaceholder else { return  }
                                isNavigationLinkActive = true
                            }

                    }

                }.leftWidthPercentage(0.3)
            }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
        }
    }

    /// Large row
    struct LargeRow: View {

        /// Environment of the reason list
        @EnvironmentObject var reasonListEnvironment: ListEnvironment<FirebaseReasonTemplate>

        /// Fine of this row
        let fine: FirebaseFine

        /// Indicates whether the view is a placeholder
        let isPlaceholder: Bool

        /// Namespace for matched geometry effect
        let namespace: Namespace.ID

        /// Indicates if navigation link is active
        @Binding var isNavigationLinkActive: Bool

        var body: some View {
            VStack(spacing: 0) {

                // Top row
                SplittedOutlinedContent(.top) {

                    // Left outline
                    Text(describing: fine.completeAmount(with: reasonListEnvironment.list))
                        .foregroundColor(fine.amountTextColor(with: reasonListEnvironment.list))
                        .font(.system(size: 20, weight: .thin))
                        .lineLimit(1)
                        .matchedGeometryEffect(id: "firstOutline", in: namespace)

                } rightContent: {

                    // Right outline
                    Text(fine.date.formattedLong)
                        .foregroundColor(.textColor)
                        .font(.system(size: 20, weight: .thin))
                        .lineLimit(1)

                }.leftWidthPercentage(0.382)
                    .frame(height: 50)

                // Bottom row
                GeometryReader { geometry in
                    SingleOutlinedContent(.bottom) {
                        HStack(spacing: 0) {

                            // Reason text
                            Text(fine.reason(with: reasonListEnvironment.list))
                                .foregroundColor(.textColor)
                                .font(.system(size: 20, weight: .thin))
                                .lineLimit(1)
                                .padding(.leading, 15)
                                .matchedGeometryEffect(id: "reason", in: namespace)

                            Spacer()

                            // Arrow
                            HStack(spacing: 0) {
                                Image(systemName: "control")
                                    .rotationEffect(.radians(.pi / 2))
                                    .padding(.leading, 10)
                                    .foregroundColor(.textColor)
                                Spacer()
                            }.frame(width: geometry.size.width * 0.1, height: geometry.size.height)
                                .matchedGeometryEffect(id: "secondOutline", in: namespace)
                                .unredacted()
                                .onTapGesture {
                                    guard !isPlaceholder else { return  }
                                    isNavigationLinkActive = true
                                }

                        }
                    }

                }.frame(height: 50)
            }.frame(width: UIScreen.main.bounds.width * 0.95)
        }
    }
}
