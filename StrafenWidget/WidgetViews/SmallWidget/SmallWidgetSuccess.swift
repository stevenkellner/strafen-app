//
//  SmallWidgetSuccess.swift
//  Strafen
//
//  Created by Steven on 26.07.20.
//

import SwiftUI
import WidgetKit

/// Small widget view with success entry type of Strafen Widget
struct SmallWidgetSuccess: View {
    
    /// Logged in person
    let person: WidgetUrls.CodableSettings.Person
    
    /// Widget Style
    let style: WidgetUrls.CodableSettings.Style
    
    /// Fine list of this person
    let fineList: [WidgetFineNoTemplate]
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Name
            Text(person.name.formatted)
                .font(.text(20))
                .foregroundColor(.textColor)
                .lineLimit(1)
                .padding(.horizontal, 10)
                .padding(.top, 15)
            
            Spacer()
            
            // Payed Amount Sum
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Spacer()
                    
                    // Left of Divider
                    ZStack {
                       
                        // Outline
                        Outline(style: style, .left)
                            .radius(10)
                       
                        // Text
                        Text("Bezahlt:")
                            .foregroundColor(.textColor)
                            .font(.text(12))
                            .lineLimit(1)
                            .padding(.horizontal, 2)
                            .unredacted()
                       
                    }.frame(width: geometry.size.width * 0.50, height: geometry.size.height)
                    
                    // Right of the Divider
                    ZStack {
                        
                        // Outline
                        Outline(style: style, .right)
                            .radius(10)
                            .fillColor(style.fillColor(colorScheme, defaultStyle: Color.custom.lightGreen))
                        
                        // Amount
                        Text(String(describing: fineList.payedAmountSum))
                            .foregroundColor(style == .default ? .textColor : Color.custom.lightGreen)
                            .font(.text(15))
                            .lineLimit(1)
                            .padding(.horizontal, 2)
                        
                    }.frame(width: geometry.size.width * 0.35, height: geometry.size.height)
                    
                    Spacer()
                }
            }.frame(height: 35)
            
            // Unayed Amount Sum
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Spacer()
                    
                    // Left of Divider
                    ZStack {
                       
                        // Outline
                        Outline(style: style, .left)
                            .radius(10)
                       
                        // Text
                        Text("Ausstehend:")
                            .foregroundColor(.textColor)
                            .font(.text(12))
                            .lineLimit(1)
                            .padding(.horizontal, 2)
                            .unredacted()
                       
                    }.frame(width: geometry.size.width * 0.50, height: geometry.size.height)
                    
                    // Right of the Divider
                    ZStack {
                        
                        // Outline
                        Outline(style: style, .right)
                            .radius(10)
                            .fillColor(style.fillColor(colorScheme, defaultStyle: Color.custom.red))
                        
                        // Amount
                        Text(String(describing: fineList.unpayedAmountSum))
                            .foregroundColor(style == .default ? .textColor : Color.custom.red)
                            .font(.text(15))
                            .lineLimit(1)
                            .padding(.horizontal, 2)
                        
                    }.frame(width: geometry.size.width * 0.35, height: geometry.size.height)
                    
                    Spacer()
                }
            }.frame(height: 35)
                .padding(.top, 5)
            
            Spacer()
        }.edgesIgnoringSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colorScheme.backgroundColor)
    }
}

#if DEBUG
struct SmallWidgetSuccess_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(styleColorSchemPermutations, id: \.offset) {
                SmallWidgetSuccess(person: .default, style: $0.element.style, fineList: .random)
                    .previewContext(WidgetPreviewContext(family: .systemSmall))
                    .environment(\.colorScheme, $0.element.colorScheme)
//                    .redacted(reason: .placeholder)
            }
        }
    }
}
#endif
