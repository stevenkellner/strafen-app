//
//  StrafenWidget.swift
//  StrafenWidget
//
//  Created by Steven on 24.07.20.
//

import WidgetKit
import SwiftUI
import Firebase

@main
struct StrafenWidget: Widget {
    
    init() {
        FirebaseApp.configure()
        try? Auth.auth().useUserAccessGroup("K7NTJ83ZF8.stevenkellner.Strafen.firebaseAuth")
    }
    
    private let kind: String = "StrafenWidget"

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetView(entry: entry)
                .widgetURL(URL(string: "profileDetail")!)
                .redacted(reason: entry.style == .skeleton ? .placeholder : [])
        }
        .configurationDisplayName(Text("Strafen Widget"))
        .description(Text("Zeigt deine Strafen und deinen offenen Betrag."))
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
