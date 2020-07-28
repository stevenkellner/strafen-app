//
//  LargeWidgetSuccess.swift
//  StrafenWidgetExtension
//
//  Created by Steven on 27.07.20.
//

import SwiftUI
import WidgetKit

/// Large widget view with success entry type of Strafen Widget
struct LargeWidgetSuccess: View {
    
    /// Logged in person
    let person: WidgetUrls.CodableSettings.Person
    
    /// Widget Style
    let style: WidgetUrls.CodableSettings.Style
    
    /// Fine list of this person
    let fineList: [WidgetFineNoTemplate]
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            
        }.edgesIgnoringSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colorScheme.backgroundColor)
    }
}

#if DEBUG
struct LargeWidgetSuccess_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(styleColorSchemPermutations, id: \.offset) {
                LargeWidgetSuccess(person: .default, style: $0.element.style, fineList: .random)
                    .previewContext(WidgetPreviewContext(family: .systemLarge))
                    .environment(\.colorScheme, $0.element.colorScheme)
//                    .redacted(reason: .placeholder)
            }
        }
    }
}
#endif
