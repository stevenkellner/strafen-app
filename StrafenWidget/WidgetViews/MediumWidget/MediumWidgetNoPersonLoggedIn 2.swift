//
//  MediumWidgetNoPersonLoggedIn.swift
//  StrafenWidgetExtension
//
//  Created by Steven on 27.07.20.
//

import SwiftUI
import WidgetKit

/// Medium widget view with no person logged in entry type of Strafen Widget
struct MediumWidgetNoPersonLoggedIn: View {
    
    /// Widget Style
    let style: WidgetUrls.CodableSettings.Style
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Niemand Ist Angemeldet")
                .font(.text(20))
                .foregroundColor(.textColor)
                .padding(.horizontal, 10)
                .multilineTextAlignment(.center)
                .unredacted()
        }.edgesIgnoringSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colorScheme.backgroundColor)
    }
}
