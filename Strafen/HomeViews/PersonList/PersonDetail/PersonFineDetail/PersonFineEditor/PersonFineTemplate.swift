//
//  PersonFineTemplate.swift
//  Strafen
//
//  Created by Steven on 17.07.20.
//

import SwiftUI

/// View of PersonFineEditor to select a template
struct PersonFineTemplate: View {
    
    /// Handled with selected template
    let completionHandler: (Reason) -> ()
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Reason List Data
    @ObservedObject var reasonListData = ListData.reason
    
    init(completionHandler: @escaping (Reason) -> ()) {
        self.completionHandler = completionHandler
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Bar to wipe sheet down
            SheetBar()
            
            // Title
            Header("Strafe Auswählen")
            
            // Empty List Text
            if reasonListData.list!.isEmpty {
                Text("Es sind keine Strafen verfügbar.")
                    .font(.text(25))
                    .foregroundColor(.textColor)
                    .padding(.horizontal, 15)
                    .multilineTextAlignment(.center)
                    .padding(.top, 50)
                Text("Lege erst eine Neue im Strafenkatalog an.")
                    .font(.text(25))
                    .foregroundColor(.textColor)
                    .padding(.horizontal, 15)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
            }
            
            // List of reasons
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 15) {
                    ForEach(reasonListData.list!.sorted(by: \.reason.localizedUppercase)) { reason in
                        PersonFineTemplateRow(reason: reason)
                            .onTapGesture {
                                completionHandler(reason)
                                presentationMode.wrappedValue.dismiss()
                            }
                    }
                }.padding(.bottom, 20)
                    .padding(.top, 5)
            }.padding(.top, 10)
            
            Spacer()
            
            // Cancel Button
            CancelButton {
                presentationMode.wrappedValue.dismiss()
            }.padding(.bottom, 30)
                .padding(.top, 15)
            
        }
    }
}

/// Row of PersonFineTemplate
struct PersonFineTemplateRow: View {
    
    /// Reason of this row
    let reason: Reason
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    var body: some View {
        HStack(spacing: 0) {
            
            // Left of the divider
            ZStack {
                
                // Outline
                Outline(.left)
                
                // Text
                HStack(spacing: 0) {
                    Text(reason.reason)
                        .foregroundColor(.textColor)
                        .font(.text(20))
                        .lineLimit(1)
                        .padding(.leading, 15)
                    Spacer()
                }
                
            }.frame(width: 245, height: 50)
            
            // Right of the divider
            ZStack {
                
                // Outline
                Outline(.right)
                    .fillColor(reason.importance.color)
                
                // Text
                Text(String(describing: reason.amount))
                    .foregroundColor(settings.style == .default ? .textColor : reason.importance.color)
                    .font(.text(20))
                    .lineLimit(1)
                
            }.frame(width: 100, height: 50)
            
        }
    }
}
