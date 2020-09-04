//
//  ContentView.swift
//  Strafen
//
//  Created by Steven on 26.06.20.
//

import SwiftUI

/// Content View
struct ContentView: View {
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    var body: some View {
        ZStack {
            
            // Activity View
            ActivityView.shared
            
            if settings.person != nil {
                HomeTabsView()
            } else {
                LoginEntryView()
                    .edgesIgnoringSafeArea(.all)
            }
        }.onAppear {
            Settings.shared.applySettings()
        }
    }
}
