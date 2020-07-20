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
        ZStack {
            
            // Background color
            colorScheme.backgroundColor
            
            // Header and list
            VStack(spacing: 0) {
                
                // Header
                Header("Verfügbare Strafen")
                    .padding(.top, 50)
                
                // Empty List Text
                if reasonListData.list!.isEmpty  {
                    if settings.person!.isCashier {
                        Text("Du hast noch keine Strafe erstellt.")
                            .font(.text(25))
                            .foregroundColor(.textColor)
                            .padding(.horizontal, 15)
                            .multilineTextAlignment(.center)
                            .padding(.top, 50)
                        Text("Füge eine Neue mit der Taste unten rechts hinzu.")
                            .font(.text(25))
                            .foregroundColor(.textColor)
                            .padding(.horizontal, 15)
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                    } else {
                        Text("Es gibt keine verfügbare Strafen.")
                            .font(.text(25))
                            .foregroundColor(.textColor)
                            .padding(.horizontal, 15)
                            .multilineTextAlignment(.center)
                            .padding(.top, 50)
                    }
                }
                
                // Template List
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 15) {
                        ForEach(reasonListData.list!.sorted(by: \.reason.localizedUppercase)) { reason in
                            ReasonListRow(reason: reason)
                        }
                    }.padding(.bottom, 20)
                        .padding(.top, 5)
                    
                }.padding(.top, 10)
                
                Spacer()
            }
            
            // Add New Reason Button
            AddNewListItemButton(list: $reasonListData.list) {
                ReasonAddNew()
            }
            
        }.edgesIgnoringSafeArea(.all)
    }
}

/// A Row of reason list with details of one reason.
struct ReasonListRow: View {
    
    /// Contains details of the reason
    let reason: Reason
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Indicates if reason editor sheet is shown
    @State var isEditorSheetShown = false
    
    var body: some View {
        HStack(spacing: 0) {
            
            // Left of the divider
            ZStack {
                
                // Outline
                Outline(.left)
                
                // Inside
                HStack(spacing: 0) {
                    
                    // Name
                    Text(reason.reason)
                        .foregroundColor(.textColor)
                        .font(.text(20))
                        .lineLimit(1)
                        .padding(.horizontal, 15)
                    
                    Spacer()
                }
                
            }.frame(width: UIScreen.main.bounds.width * 0.675)
            
            // Right of the divider
            ZStack {
                
                // Outline
                Outline(.right)
                    .fillColor(settings.style.fillColor(colorScheme, defaultStyle: reason.importance.color))
                
                // Inside
                Text(String(describing: reason.amount))
                    .foregroundColor(settings.style == .default ? .textColor : reason.importance.color)
                    .font(.text(20))
                    .lineLimit(1)
                
            }.frame(width: UIScreen.main.bounds.width * 0.275)
            
        }.frame(width: UIScreen.main.bounds.width * 0.5, height: 50)
            .padding(.horizontal, 1)
            .onTapGesture {
                if settings.person!.isCashier {
                    isEditorSheetShown = true
                }
            }
            .sheet(isPresented: $isEditorSheetShown) {
                ReasonEditor(reasonToEdit: reason)
            }
    }
}

