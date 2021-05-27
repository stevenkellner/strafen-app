//
//  TabBar.swift
//  Strafen
//
//  Created by Steven on 27.05.21.
//

import SwiftUI

/// Tab Bar that contains the Buttons to navigate through the home tabs
struct TabBar: View {

    /// Logged in person
    @EnvironmentObject var person: Settings.Person

    /// Handler to dimiss from a subview to the previous view.
    @EnvironmentObject var dismissHandler: DismissHandler

    var body: some View {
        ZStack {

            Color.tabBarColor
                .frame(height: 65)
                .offset(y: 65)

            GeometryReader { geometry in
                VStack(spacing: 0) {

                    // Outline
                    Rectangle()
                        .frame(width: geometry.size.width, height: 1)
                        .border(Color.tabBarBorderColor, width: 0.5)

                    // Tab bar items
                    HStack(spacing: 0) {

                        // Profile detail tab
                        ButtonContent(.profileDetail, size: geometry.size) {
                            dismissHandler.dismissCurrentView()
                        }

                        // Person list tab
                        ButtonContent(.personList, size: geometry.size) {
                            dismissHandler.dismissCurrentView()
                        }

                        // Reason list tab
                        ButtonContent(.reasonList, size: geometry.size)

                        // Add new fine tab
                        if person.isCashier {
                            ButtonContent(.addNewFine, size: geometry.size)
                        }

                        // Settings tab
                        ButtonContent(.settings, size: geometry.size)

                    }

                }
            }.frame(height: 70)

        }.background(Color.tabBarColor)
    }

    /// Content of TabBar Button
    struct ButtonContent: View {

        /// Logged in person
        @EnvironmentObject var person: Settings.Person

        /// Active home tab
        @EnvironmentObject var homeTab: HomeTab

        /// Tab type of this Button
        let tab: HomeTab.Tab

        /// Button size
        let size: CGSize

        /// Handles the tap
        let tapHandler: (() -> Void)?

        init(_ tab: HomeTab.Tab, size: CGSize, handler tapHandler: (() -> Void)? = nil) {
            self.tab = tab
            self.size = size
            self.tapHandler = tapHandler
        }

        var body: some View {
            Button {
                tapHandler?()
                homeTab.active = tab
            } label: {
                VStack(spacing: 0) {

                    // Image
                    Image(systemName: tab.imageName)
                        .font(.system(size: 30, weight: .thin))
                        .foregroundColor(tab == homeTab.active ? .customOrange : .customGreen)
                        .frame(height: 30)

                    // Title
                    Text(tab.title)
                        .foregroundColor(.textColor)
                        .font(.system(size: 10, weight: .thin))
                        .lineLimit(1)
                        .padding(.top, 8)
                        .padding(.horizontal, 2)

                }.frame(width: size.width / (person.isCashier ? 5 : 4), height: size.height)
            }.buttonStyle(PlainButtonStyle())
        }
    }
}
