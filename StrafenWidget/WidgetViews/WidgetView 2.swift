//
//  WidgetView.swift
//  Strafen
//
//  Created by Steven on 24.07.20.
//

import SwiftUI

/// View of Strafen Widget
struct WidgetView: View {
    
    /// Widget entry
    var entry: Provider.Entry
    
    /// Widget family
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallWidget(entry: entry)
            case .systemMedium:
                MediumWidget(entry: entry)
            case .systemLarge:
                LargeWidget(entry: entry)
            @unknown default:
                Text("Not available!")
            }
        }
    }
}
