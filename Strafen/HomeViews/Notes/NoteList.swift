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
    
    /// Indicates if addNewNote sheet is shown
    @State var isAddNewNoteSheetShown = false
    
    var body: some View {
        NavigationView {
            ZStack {
                
                // Background color
                colorScheme.backgroundColor
                
                // Header and list
                VStack(spacing: 0) {
                    
                    // Header
                    Header("Notizen")
                        .padding(.top, 35)
                    
                    // Note List
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 15) {
                            ForEach(noteListData.list!.sorted(by: \.subject.localizedUppercase)) { note in
                                NavigationLink(destination: NoteDetail(note: note, dismissHandler: $dismissHandler)) {
                                        NoteListRow(note: note)
                                }.buttonStyle(PlainButtonStyle())
                            }
                        }.padding(.bottom, 20)
                            .padding(.top, 5)
                        
                    }.padding(.top, 10)
                    
                    Spacer()
                }
                
                // Add New Note Button
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
                                isAddNewNoteSheetShown = true
                            }
                            .sheet(isPresented: $isAddNewNoteSheetShown) {
                                NoteAddNew()
                            }
                    }
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
            
        }.frame(width: 345, height: 50)
    }
}
