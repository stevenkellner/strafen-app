//
//  ContentView.swift
//  Strafen
//
//  Created by Steven on 26.06.20.
//

import SwiftUI

/// Content View
struct ContentView: View {
    
    ///Dismiss handler
    @State var dismissHandler: (() -> ())? = nil
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Active home tab
    @ObservedObject var homeTabs = HomeTabs.shared
    
    /// Screen size
    @State var screenSize: CGSize?
    
    var body: some View {
        ZStack {
            
            // Activity View
            ActivityView.shared
            
            if settings.person != nil {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        
                        // HomeViews
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
                    .onAppear {
                        
                        // Fetch note list
                        ListData.note.list = nil
                        ListData.note.fetch()
                        
                        ListData.shared.fetchLists()
                    }
                    .onOpenURL { url in
                        homeTabs.active = url.pathComponents.first == "profileDetail" ? .profileDetail : homeTabs.active
                    }
            } else {
                LoginEntryView()
                    .edgesIgnoringSafeArea(.all)
            }
        }.onAppear {
            Settings.shared.applySettings()
        }
    }
}
