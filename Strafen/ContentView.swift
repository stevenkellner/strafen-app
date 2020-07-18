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
                LoginView()
            }
        }.edgesIgnoringSafeArea(.all)
            .onAppear {
                Settings.shared.applySettings()
            }
    }
}

/// View with all home tabs
struct HomeTabsView: View {
    
    /// State of internet connection
    enum ConnectionState {
        
        /// Still loading
        case loading
        
        /// No connection
        case failed
        
        /// All loaded
        case passed
    }
    
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
                    .background(colorScheme.backgroundColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failed:
                Text("Failed") // TODO
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
                    case .notes:
                        Text(homeTabs.active.title)
                    case .settings:
                        SettingsView()
                    }
                    
                }.background(colorScheme.backgroundColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }
            
            // Tab bar
            TabBar(dismissHandler: $dismissHandler)
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                fetchLists()
            }
    }
    
    /// Fetch all list data
    func fetchLists() {
        
        // Reset lists
        ListData.person.list = nil
        ListData.reason.list = nil
        ListData.fine.list = nil
        
        // Enter DispathGroup
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        dispatchGroup.enter()
        dispatchGroup.enter()
        
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

/// All available home tabs
class HomeTabs: ObservableObject {
    
    /// All available tabs
    enum Tabs {
        
        /// Profile detail
        case profileDetail
        
        /// Person list
        case personList
        
        /// Reason list
        case reasonList
        
        /// Add new fine
        case addNewFine
        
        /// Notes
        case notes
        
        /// Settings
        case settings
        
        /// System image name
        var imageName: String {
            switch self {
            case .profileDetail:
                return "person"
            case .personList:
                return "person.2"
            case .reasonList:
                return "list.dash"
            case .addNewFine:
                return "plus"
            case .notes:
                return "note.text"
            case .settings:
                return "gear"
            }
        }
        
        /// Title
        var title: String {
            switch self {
            case .profileDetail:
                return "Profil"
            case .personList:
                return "Personen"
            case .reasonList:
                return "Strafenkatalog"
            case .addNewFine:
                return "Strafe"
            case .notes:
                return "Notizen"
            case .settings:
                return "Einstellungen"
            }
        }
    }
    
    /// Shared instance for singelton
    static let shared = HomeTabs()
    
    /// Private init for singleton
    private init() {}
    
    /// Active home tabs
    @Published var active: Tabs = .addNewFine
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
