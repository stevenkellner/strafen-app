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
    @State var dismissHandler: (() -> ())? = nil
    
    /// Active home tab
    @ObservedObject var homeTabs = HomeTabs.shared
    
    /// State of internet connection
    @State var connectionState: ConnectionState = .loading
    
    /// Screen size
    @State var screenSize: CGSize?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                switch connectionState {
                case .loading:
                    
                    // Loading
                    switch homeTabs.active {
                    case .notes:
                        NoteList(dismissHandler: $dismissHandler)
                            .edgesIgnoringSafeArea(.all)
                            .background(colorScheme.backgroundColor)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    case .settings:
                        SettingsView(dismissHandler: $dismissHandler)
                            .edgesIgnoringSafeArea(.all)
                            .background(colorScheme.backgroundColor)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    default:
                        ZStack {
                            colorScheme.backgroundColor
                            ProgressView("Laden")
                        }.edgesIgnoringSafeArea(.all)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                case .failed:
                    
                    // No internet connection
                    switch homeTabs.active {
                    case .notes:
                        NoteList(dismissHandler: $dismissHandler)
                            .edgesIgnoringSafeArea(.all)
                            .background(colorScheme.backgroundColor)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    case .settings:
                        SettingsView(dismissHandler: $dismissHandler)
                            .edgesIgnoringSafeArea(.all)
                            .background(colorScheme.backgroundColor)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    default:
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
                                    .onTapGesture(perform: fetchLists)
                                Spacer()
                            }
                        }.edgesIgnoringSafeArea(.all)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
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
                            ZStack {
                                colorScheme.backgroundColor
                                AddNewFine()
                                    .padding(.top, 50)
                            }.edgesIgnoringSafeArea(.all)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        case .notes:
                            NoteList(dismissHandler: $dismissHandler)
                        case .settings:
                            SettingsView(dismissHandler: $dismissHandler)
                        }
                        
                    }.edgesIgnoringSafeArea(.all)
                        .background(colorScheme.backgroundColor)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                }
                
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
                
                fetchLists()
            }
            .onOpenURL { url in
                homeTabs.active = url.pathComponents.first == "profileDetail" ? .profileDetail : homeTabs.active
            }
    }
    
    /// Fetch all list data
    func fetchLists() {
        
        connectionState = .loading
        
        // Reset lists
        ListData.person.list = nil
        ListData.reason.list = nil
        ListData.fine.list = nil
        ListData.club.list = nil
        
        // Enter DispathGroup
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
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
        
        // Fetch club list
        ListData.club.fetch {
            dispatchGroup.leave()
        } failedHandler: {
            connectionState = .failed
        }
        
        // Notify dispath group
        dispatchGroup.notify(queue: .main) {
            Settings.shared.latePaymentInterest = ListData.club.list?.first(where: { club in
                Settings.shared.person?.clubId == club.id
            })?.latePaymentInterest
            connectionState = .passed
        }
    }
}
