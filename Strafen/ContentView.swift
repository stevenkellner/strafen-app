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
    @ObservedObject var settings = Settings.shared
    
    /// List data that contains all datas of the different lists
    @ObservedObject var listData = ListData.shared
    
    var body: some View {
        ZStack {
            
            // Activity View
            ActivityView.shared
            
            if listData.forceSignedOut {
                
                // Force Sign Out View
                ForceSignedOutView()
                
            } else if listData.emailNotVerificated {
                
                /// Email not verificated view
                EmailNotVerificatedView()
                
            } else if settings.person != nil && Auth.auth().currentUser != nil {
                
                // Home Tabs View and Tab Bar
                ContentHomeView()
                    .onAppear {
                        ListData.shared.setup()
                    }
                
            } else {
                
                // Login Entry View
                LoginEntryView()
                    .edgesIgnoringSafeArea(.all)
                
            }
        }.onAppear {
            Settings.shared.applySettings()
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
                    
                }.screenSize($screenSize, geometry: geometry)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .onOpenURL { url in
                    homeTabs.active = url.pathComponents.first == "profileDetail" ? .profileDetail : homeTabs.active
                }
        }
    }
}
