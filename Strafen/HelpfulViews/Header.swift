//
//  Header.swift
//  Strafen
//
//  Created by Steven on 28.06.20.
//

import SwiftUI

/// Page Header with underlines
struct Header: View {
    
    /// Page title
    let title: String
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        VStack(spacing: 0) {
                
            // Title
            HStack {
                Text(self.title)
                    .foregroundColor(Color.textColor)
                    .font(.text(35))
                    .padding(.leading, 22)
                Spacer()
            }
            
            // Top Underline
            HStack {
                Rectangle()
                    .frame(width: 300, height: 2)
                    .border(settings.style == .default ? Color.custom.darkGreen : (colorScheme == .dark ? Color.plain.lightGray : Color.plain.darkGray), width: 1)
                Spacer()
            }.padding(.top, 10)
            
            // Bottom Underline
            HStack {
                Rectangle()
                    .frame(width: 275, height: 2)
                    .border(settings.style == .default ? Color.custom.darkGreen : (colorScheme == .dark ? Color.plain.lightGray : Color.plain.darkGray), width: 1)
                Spacer()
            }.padding(.top, 5)
                
        }
    }
}
