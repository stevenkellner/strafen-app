//
//  ReasonList.swift
//  Strafen
//
//  Created by Steven on 17.07.20.
//

import SwiftUI

/// List of all templates
struct ReasonList: View {
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Reason List Data
    @ObservedObject var reasonListData = ListData.reason
    
    /// Text searched in search bar
    @State var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                
                // Background color
                colorScheme.backgroundColor
                
                // Header and list
                VStack(spacing: 0) {
                    
                    // Header
                    Header("Verfügbare Strafen")
                        .padding(.top, 50)
                    
                    if let reasonList = reasonListData.list {
                        
                        // Empty List Text
                        if reasonList.isEmpty {
                            VStack(spacing: 20) {
                                if settings.person?.isCashier ?? false {
                                    Text("Du hast noch keine Strafe erstellt.")
                                        .configurate(size: 25).lineLimit(2)
                                    Text("Füge eine Neue mit der Taste unten rechts hinzu.")
                                        .configurate(size: 25).lineLimit(2)
                                } else {
                                    Text("Es gibt keine verfügbare Strafen.")
                                        .configurate(size: 25).lineLimit(2)
                                }
                            }.padding(.horizontal, 15)
                                .padding(.top, 50)
                        }
                        
                        // Search Bar and list
                        ScrollView {
                            VStack(spacing: 0) {
                                
                                // Search Bar
                                if !reasonList.isEmpty {
                                    SearchBar(searchText: $searchText)
                                        .frame(width: UIScreen.main.bounds.width * 0.95 + 15)
                                }
                                
                                LazyVStack(spacing: 15) {
                                    
                                    /// Native Ad
                                    NativeAdView()
                                    
                                    ForEach(reasonList.sortedForList(with: searchText)) { reason in
                                        ReasonListRow(reason: reason)
                                    }
                                }.padding(.bottom, 10)
                                
                            }
                        }.padding(.top, 10)
                        
                    } else {
                        Text("No available view")
                    }
                    
                    Spacer(minLength: 0)
                }
                
                // Add New Reason Button
                AddNewListItemButton(list: $reasonListData.list) {
                    ReasonAddNew()
                }
                
            }.edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .hideNavigationBarTitle()
        }.setScreenSize
    }
    
    /// A Row of reason list with details of one reason.
    struct ReasonListRow: View {
        
        /// Contains details of the reason
        let reason: ReasonTemplate
        
        /// Observed Object that contains all settings of the app of this device
        @ObservedObject var settings = Settings.shared
        
        /// Indicates if reason editor sheet is shown
        @State var isEditorSheetShown = false
        
        var body: some View {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    
                    // Left of the divider
                    ZStack {
                        
                        // Outline
                        Outline(.left)
                        
                        // Inside
                        HStack(spacing: 0) {
                            
                            // Name
                            Text(reason.reason)
                                .configurate(size: 20)
                                .lineLimit(1)
                                .padding(.horizontal, 15)
                            
                            Spacer()
                        }
                        
                    }.frame(width: geometry.size.width * 0.7)
                    
                    // Right of the divider
                    ZStack {
                        
                        // Outline
                        Outline(.right)
                            .fillColor(reason.importance.color)
                        
                        // Inside
                        Text(String(describing: reason.amount))
                            .foregroundColor(plain: reason.importance.color)
                            .font(.text(20))
                            .lineLimit(1)
                        
                    }.frame(width: geometry.size.width * 0.3)
                    
                }.onTapGesture {
                        if settings.person?.isCashier ?? false {
                            isEditorSheetShown = true
                            UIApplication.shared.dismissKeyboard()
                        }
                    }
                    .sheet(isPresented: $isEditorSheetShown) {
                        ReasonEditor(reasonToEdit: reason)
                    }
            }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
        }
    }
}

// Extension of Array to filter and sort it for reason list
extension Array where Element == ReasonTemplate {
    
    /// Filtered and sorted for reason list
    fileprivate func sortedForList(with searchText: String) -> [Element] {
        filter(for: searchText, at: \.reason).sorted(by: \.reason.localizedUppercase)
    }
}
