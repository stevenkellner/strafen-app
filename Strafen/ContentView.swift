//
//  ContentView.swift
//  Strafen
//
//  Created by Steven on 26.06.20.
//

import SwiftUI
import FirebaseAuth

/// View with all relevant app contents.
struct ContentView: View {
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = NewSettings.shared
    
    /// List data that contains all datas of the different lists
    @ObservedObject var listData = NewListData.shared
    
    @ObservedObject var fineDataList = NewListData.fine
    
    var body: some View {
        ZStack {
            
            // Activity View
            ActivityView.shared
            
            if listData.forceSignedOut {
                
                // Force Sign Out View
                // ContentForceSignedOutView() TODO
                
            } else if listData.emailNotVerificated {
                
                // TODO
                
            }
            if settings.properties.person != nil && Auth.auth().currentUser != nil {
                
                // Home Tabs View and Tab Bar
                // TODO ContentHomeView()
                ScrollView {
                    if let list = fineDataList.list {
                        ForEach(list) { fine in
                            Text(fine.date.description)
                        }
                    }
                }.onAppear {
                    NewListData.shared.setup()
                }
                
            } else {
                
                // Login Entry View
                LoginEntryView()
                    .edgesIgnoringSafeArea(.all)
                
            }
        }.onAppear {
            NewSettings.shared.applySettings()
        }
    }
    
    /// View to force sign out a signed in person
    struct ContentForceSignedOutView: View {
        
        /// Color scheme to get appearance of this device
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            ZStack {
                
                // Backgroud color
                colorScheme.backgroundColor
                
                // Force Signed Out View
                ForceSignedOutView()
                
            }.edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    /// Home Tab Views and Tab Bar
    struct ContentHomeView: View {
        
        /// Handler to dimiss from a subview to the previous view.
        @State var dismissHandler: DismissHandler = nil
        
        /// Color scheme to get appearance of this device
        @Environment(\.colorScheme) var colorScheme
        
        /// Active home tab
        @ObservedObject var homeTabs = HomeTabs.shared
        
        /// Size of the home view and tab bar on the screen
        @State var screenSize: CGSize?
        
        var body: some View {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    
                    // Home Views
                    HomeTabsView(dismissHandler: $dismissHandler)
                        .edgesIgnoringSafeArea(.all)
                        .background(colorScheme.backgroundColor)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Tab bar
                    TabBar(dismissHandler: $dismissHandler)
                        .edgesIgnoringSafeArea([.horizontal, .top])
                    
                }.frame(size: screenSize ?? geometry.size)
                    .onAppear {
                        screenSize = geometry.size
                    }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .onOpenURL { url in
                    homeTabs.active = url.pathComponents.first == "profileDetail" ? .profileDetail : homeTabs.active
                }
        }
    }
}
