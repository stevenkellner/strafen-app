//
//  ContentView.swift
//  Strafen
//
//  Created by Steven on 26.06.20.
//

import SwiftUI

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

/// View with all home tabs
struct HomeTabsView: View {
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    ///Dismiss handler
    @State var dismissHandler: (() -> ())? = nil
    
    /// Active home tab
    @ObservedObject var homeTabs = HomeTabs.shared
    
    /// State of internet connection
    @State var connectionState: ConnectionState = .loading
    
    var body: some View {
        VStack(spacing: 0) {
            
            switch connectionState {
            case .loading:
                Text("Loading") // TODO
                    .edgesIgnoringSafeArea(.all)
                    .background(colorScheme.backgroundColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failed:
                Text("Failed") // TODO
                    .edgesIgnoringSafeArea(.all)
                    .background(colorScheme.backgroundColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .passed:
                
                // Home tabs
                HStack(spacing: 0) {
                    
                    switch homeTabs.active {
                    case .profileDetail:
                        ProfileDetail(dismissHandler: $dismissHandler)
                    case .personList:
                        PersonList(dismissHandler: $dismissHandler)
                    case .reasonList:
                        ReasonList()
                    case .addNewFine:
                        AddNewFine()
                            .padding(.top, 50)
                    case .notes:
                        NoteList(dismissHandler: $dismissHandler)
                    case .settings:
                        SettingsView()
                    }
                    
                }.edgesIgnoringSafeArea(.all)
                    .background(colorScheme.backgroundColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }
            
            // Tab bar
            TabBar(dismissHandler: $dismissHandler)
                .edgesIgnoringSafeArea([.horizontal, .top])
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                fetchLists()
            }
    }
    
    /// Fetch all list data
    func fetchLists() {
        
        // Reset lists
        ListData.note.list = nil
        ListData.person.list = nil
        ListData.reason.list = nil
        ListData.fine.list = nil
        
        // Enter DispathGroup
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        dispatchGroup.enter()
        dispatchGroup.enter()
        dispatchGroup.enter()
        
        // Fetch note list
        ListData.note.fetch {
            dispatchGroup.leave()
        }
        
        // Fetch person list
        ListData.person.fetch {
            dispatchGroup.leave()
        } failedHandler: {
            connectionState = .failed
        }
        
        // Fetch reason list
        ListData.reason.fetch {
            dispatchGroup.leave()
        } failedHandler: {
            connectionState = .failed
        }
        
        // Fetch fine list
        ListData.fine.fetch {
            dispatchGroup.leave()
        } failedHandler: {
            connectionState = .failed
        }
        
        // Notify dispath group
        dispatchGroup.notify(queue: .main) {
            connectionState = .passed
        }
    }
}

/// State of internet connection
enum ConnectionState {
    
    /// Still loading
    case loading
    
    /// No connection
    case failed
    
    /// All loaded
    case passed
}
