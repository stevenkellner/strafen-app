//
//  StrafenWidget.swift
//  StrafenWidget
//
//  Created by Steven on 24.07.20.
//

import WidgetKit
import SwiftUI

@main
struct StrafenWidget: Widget {
    private let kind: String = "StrafenWidget"

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetView(entry: entry)
                .widgetURL(URL(string: "profileDetail")!)
        }
        .configurationDisplayName(Text("Strafen Widget"))
        .description(Text("Zeigt deine Strafen und deinen offenen Betrag."))
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
