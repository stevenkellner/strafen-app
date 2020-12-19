//
//  SmallWidget.swift
//  Strafen
//
//  Created by Steven on 26.07.20.
//

import SwiftUI
import WidgetKit

/// Small widget view
struct SmallWidget: View {
    
    /// Person id
    let personId: Person.ID
    
    /// Person List Data
    @ObservedObject var personListData = ListData.person
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            if let person = personListData.list?.first(where: { $0.id == personId }) {
                Spacer()
                
                // Name
                Text(person.name.formatted)
                    .configurate(size: 20)
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                
                Spacer()
                VStack(spacing: 5) {
                    
                    // Payed amount sum
                    AmountDisplay(of: personId, type: .payed)
                    
                    // Unpayed amount sum
                    AmountDisplay(of: personId, type: .unpayed)
                    
                }
                
                Spacer()
            } else {
                Text("No available view")
            }
        }.edgesIgnoringSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colorScheme.backgroundColor)
    }
}
