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
    let entry: Provider.Entry
    
    /// Widget family
    @Environment(\.widgetFamily) var family

    var body: some View {
        if let personId = personId {
            switch family {
            case .systemSmall:
                SmallWidget(personId: personId)
            case .systemMedium:
                MediumWidget(personId: personId)
            case .systemLarge:
                LargeWidget(personId: personId)
            @unknown default:
                Text("No available view")
            }
        } else {
            NoPersonLoggedIn()
        }
    }
    
    /// Person id of logged in person
    var personId: Person.ID? {
        if entry.style == .default, let personId = Settings.shared.person?.id {
            return personId
        }
        return ListData.person.list?.first?.id ?? Person.ID(rawValue: UUID())
    }
}
