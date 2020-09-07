//
//  HomeViews.swift
//  Strafen
//
//  Created by Steven on 9/4/20.
//

import SwiftUI

/// View with all home tabs
struct HomeTabsView: View {
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    ///Dismiss handler
    @Binding var dismissHandler: (() -> ())?
    
    /// Active home tab
    @ObservedObject var homeTabs = HomeTabs.shared
    
    /// List data
    @ObservedObject var listData = ListData.shared
    
    var body: some View {
        Group {
            if listData.connectionState == .passed && homeTabs.active == .profileDetail {
                ProfileDetail(dismissHandler: $dismissHandler)
            } else if listData.connectionState == .passed && homeTabs.active == .personList {
                PersonList(dismissHandler: $dismissHandler)
            } else if listData.connectionState == .passed && homeTabs.active == .reasonList {
                ReasonList()
            } else if listData.connectionState == .passed && homeTabs.active == .addNewFine {
                ZStack {
                    colorScheme.backgroundColor
                    AddNewFine()
                        .padding(.top, 50)
                }
            } else if homeTabs.active == .notes {
                NoteList(dismissHandler: $dismissHandler)
            } else if homeTabs.active == .settings {
                SettingsView(dismissHandler: $dismissHandler)
            } else if listData.connectionState == .loading {
                ZStack {
                    colorScheme.backgroundColor
                    ProgressView("Laden")
                }
            } else if listData.connectionState == .failed {
                ZStack {
                    colorScheme.backgroundColor
                    VStack(spacing: 30) {
                        Spacer()
                        Text("Keine Internetverbindung")
                            .font(.text(25))
                            .foregroundColor(.textColor)
                            .padding(.horizontal, 15)
                            .multilineTextAlignment(.center)
                        Text("Erneut versuchen")
                            .font(.text(25))
                            .foregroundColor(Color.custom.red)
                            .padding(.horizontal, 15)
                            .multilineTextAlignment(.center)
                            .onTapGesture(perform: ListData.shared.fetchLists)
                        Spacer()
                    }
                }
            } else {
                Text("No available home view")
            }
        }
    }
}
