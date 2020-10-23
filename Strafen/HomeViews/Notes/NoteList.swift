//
//  NoteList.swift
//  Strafen
//
//  Created by Steven on 18.07.20.
//

import SwiftUI

/// List of all notes
struct NoteList: View {
    
    ///Dismiss handler
    @Binding var dismissHandler: (() -> ())?
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Note List Data
    @ObservedObject var noteListData = ListData.note
    
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
                    Header("Notizen")
                        .padding(.top, 50)
                    
                    // Empty List Text
                    if noteListData.list!.isEmpty {
                        Text("Du hast noch keine Notiz erstellt.")
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
                    }
                    
                    // Search Bar and Note List
                    ScrollView {
                        
                        // Search Bar
                        if !noteListData.list!.isEmpty {
                            SearchBar(searchText: $searchText)
                                .frame(width: UIScreen.main.bounds.width * 0.95 + 15)
                        }
                        
                        // Note List
                        LazyVStack(spacing: 15) {
                            ForEach(noteListData.list!.filter(for: searchText, at: \.subject).sorted(by: \.subject.localizedUppercase)) { note in
                                CustomNavigationLink(destination: NoteDetail(note: note, dismissHandler: $dismissHandler)) {
                                        NoteListRow(note: note)
                                }.buttonStyle(PlainButtonStyle())
                            }.animation(.none)
                        }.padding(.bottom, 20)
                            .padding(.top, 5)
                            .animation(.default)
                        
                    }.padding(.top, 10)
                    
                    Spacer()
                }
                
                // Add New Note Button
                AddNewListItemButton(list: $noteListData.list) {
                    NoteAddNew()
                }
                
            }.edgesIgnoringSafeArea(.all)
                .navigationTitle("Title")
                .navigationBarHidden(true)
        }
    }
}

/// Row of note list
struct NoteListRow: View {
    
    /// Note
    let note: Note
    
    var body: some View {
        ZStack {
            
            // Ouline
            Outline()
            
            // Text
            HStack(spacing: 0) {
                Text(note.subject)
                    .font(.text(20))
                    .foregroundColor(.textColor)
                    .padding(.horizontal, 15)
                    .lineLimit(1)
                Spacer()
            }
            
        }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
    }
}
