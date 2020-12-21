//
//  NoPersonLoggedIn.swift
//  StrafenWidgetExtension
//
//  Created by Steven on 12/17/20.
//

import SwiftUI
import WidgetKit

/// View with no person logged
struct NoPersonLoggedIn: View {
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Niemand Ist Angemeldet")
                .configurate(size: 20)
                .lineLimit(2)
                .padding(.horizontal, 10)
                .unredacted()
        }.edgesIgnoringSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colorScheme.backgroundColor)
    }
}
