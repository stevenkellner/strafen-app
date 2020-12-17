//
//  FineEditorTemplate.swift
//  Strafen
//
//  Created by Steven on 11/26/20.
//

import SwiftUI

/// View of Fine Editor to select a reason template
struct FineEditorTemplate: View {
    
    /// Handled with selected reason template
    let completionHandler: (ReasonTemplate) -> Void
    
    init(completionHandler: @escaping (ReasonTemplate) -> Void) {
        self.completionHandler = completionHandler
    }
    
    /// Reason List Data
    @ObservedObject var reasonListData = ListData.reason
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Text searched in search bar
    @State var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Bar to wipe sheet down
            SheetBar()
            
            // Header
            Header("Strafe Auswählen")
            
            if let reasonList = reasonListData.list {
                
                // Empty List Text
                if reasonList.isEmpty {
                    Text("Es sind keine Strafen verfügbar.")
                        .configurate(size: 25)
                        .lineLimit(2)
                        .padding(.horizontal, 15)
                        .padding(.top, 50)
                    Text("Lege erst eine Neue im Strafenkatalog an.")
                        .configurate(size: 25)
                        .lineLimit(2)
                        .padding(.horizontal, 15)
                        .padding(.top, 20)
                }
                
                // Search Bar and List of reasons
                ScrollView {
                    
                    // Search Bar
                    if !reasonList.isEmpty {
                        SearchBar(searchText: $searchText)
                            .frame(width: UIScreen.main.bounds.width * 0.95 + 15)
                    }
                    
                    LazyVStack(spacing: 15) {
                        ForEach(reasonList.sortedForList(with: searchText)) { reason in
                            ReasonListRow(reason: reason)
                                .onTapGesture {
                                    completionHandler(reason)
                                    presentationMode.wrappedValue.dismiss()
                                }
                        }
                    }.padding(.bottom, 10)
                    
                }.padding(.vertical, 10)
                
            } else {
                Text("No available view")
            }
            
            Spacer(minLength: 0)
            
            // Cancel Button
            CancelButton()
                .onButtonPress { presentationMode.wrappedValue.dismiss() }
                .padding(.bottom, 50)
            
        }.setScreenSize
    }
    
    /// Row of reason list
    struct ReasonListRow: View {
        
        /// Reason of this row
        let reason: ReasonTemplate
        
        var body: some View {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                
                    // Left of the divider
                    ZStack {
                        
                        // Outline
                        Outline(.left)
                        
                        // Text
                        HStack(spacing: 0) {
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
                        
                        // Text
                        Text(String(describing: reason.amount))
                            .foregroundColor(plain: reason.importance.color)
                            .font(.text(20))
                            .lineLimit(1)
                        
                    }.frame(width: geometry.size.width * 0.3)
                    
                }
            }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
        }
    }

}

// Extension of Array to filter and sort it for fine editor reason list
extension Array where Element == ReasonTemplate {
    
    /// Filtered and sorted for fine editor reason list
    fileprivate func sortedForList(with searchText: String) -> [Element] {
        filter(for: searchText, at: \.reason).sorted(by: \.reason.localizedUppercase)
    }
}
