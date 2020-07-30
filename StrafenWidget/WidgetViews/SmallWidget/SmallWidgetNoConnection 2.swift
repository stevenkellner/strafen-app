//
//  SmallWidgetNoConnection.swift
//  Strafen
//
//  Created by Steven on 26.07.20.
//

import SwiftUI
import WidgetKit

/// Small widget view with no connection of Strafen Widget
struct SmallWidgetNoConnection: View {
    
    /// Widget Style
    let style: WidgetUrls.CodableSettings.Style
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Keine Internetverbindung")
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

#if DEBUG
struct SmallWidgetNoConnection_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(styleColorSchemPermutations, id: \.offset) {
                SmallWidgetNoConnection(style: $0.element.style)
                    .previewContext(WidgetPreviewContext(family: .systemSmall))
                    .environment(\.colorScheme, $0.element.colorScheme)
//                    .redacted(reason: .placeholder)
            }
        }
    }
}
#endif
