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
    
    /// Indicates if addNewPerson sheet is shown
    @State var isAddNewReasonSheetShown = false
    
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
                    .padding(.top, 35)
                
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
            if settings.person!.isCashier {
                VStack(spacing: 0) {
                    Spacer()
                    HStack(spacing: 0) {
                        Spacer()
                        RoundedCorners()
                            .strokeColor(settings.style.strokeColor(colorScheme))
                            .fillColor(settings.style.fillColor(colorScheme, defaultStyle: Color.custom.lightGreen))
                            .lineWidth(settings.style == .default ? 1.5 : 0.5)
                            .radius(settings.style.radius)
                            .frame(width: 45, height: 45)
                            .overlay(
                                Image(systemName: "text.badge.plus")
                                    .font(.system(size: 25, weight: .light))
                                    .foregroundColor(.textColor)
                            )
                            .padding([.trailing, .bottom], 20)
                            .onTapGesture {
                                isAddNewReasonSheetShown = true
                            }
                            .sheet(isPresented: $isAddNewReasonSheetShown) {
                                ReasonAddNew()
                            }
                    }
                }
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
                
            }.frame(width: 245)
            
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
                
            }.frame(width: 100)
            
        }.frame(width: 345, height: 50)
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

