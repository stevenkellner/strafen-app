//
//  MediumWidgetSuccess.swift
//  StrafenWidgetExtension
//
//  Created by Steven on 27.07.20.
//

import SwiftUI
import WidgetKit

/// Medium widget view with success entry type of Strafen Widget
struct MediumWidgetSuccess: View {
    
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
            HStack(spacing: 0) {
                
                // Person Name and payed / unpayed display
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
                }.frame(width: geometry.size.width / 2)
                
                // Fine list
                VStack(spacing: 0) {
                    
                    // Empty List
                    if fineList.isEmpty {
                        Text("Du hast keine Strafen")
                            .font(.text(20))
                            .foregroundColor(.textColor)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Fine list
                    VStack(spacing: 5) {
                        ForEach(fineList.sorted(by: \.fineReason.reason.localizedUppercase).prefix(3)) { fine in
                            Link(destination: URL(string: "profileDetail/\(fine.id)")!) {
                                GeometryReader { geometry in
                                    HStack(spacing: 0) {
                                        Spacer()
                                        
                                        // Left of Divider
                                        ZStack {
                                           
                                            // Outline
                                            Outline(style: style, .left)
                                                .radius(10)
                                           
                                            // Text
                                            Text(fine.fineReason.reason)
                                                .foregroundColor(.textColor)
                                                .font(.text(12))
                                                .lineLimit(1)
                                                .padding(.horizontal, 5)
                                           
                                        }.frame(width: geometry.size.width * 0.50, height: geometry.size.height)
                                        
                                        // Right of the Divider
                                        ZStack {
                                            
                                            // Outline
                                            Outline(style: style, .right)
                                                .radius(10)
                                                .fillColor(style.fillColor(colorScheme, defaultStyle: fine.payed == .payed ? Color.custom.lightGreen : fine.fineReason.importance.color))
                                            
                                            // Amount
                                            Text(String(describing: fine.fineReason.amount * fine.number))
                                                .foregroundColor(style == .default ? .textColor : fine.payed == .payed ? Color.custom.lightGreen : fine.fineReason.importance.color)
                                                .font(.text(15))
                                                .lineLimit(1)
                                                .padding(.horizontal, 2)
                                            
                                        }.frame(width: geometry.size.width * 0.35, height: geometry.size.height)
                                        
                                        Spacer()
                                    }
                                }.frame(width: geometry.size.width / 2, height: 35)
                            }
                        }
                        
                        // Dots if fine list has more than three elements
                        if fineList.count > 3 {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.textColor)
                                .font(.system(size: 20, weight: .thin))
                        }
                        
                    }
                    
                }
                
            }
        }.edgesIgnoringSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colorScheme.backgroundColor)
    }
}

#if DEBUG
struct MediumWidgetSuccess_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(styleColorSchemPermutations, id: \.offset) {
                MediumWidgetSuccess(person: .default, style: $0.element.style, fineList: .random)
                    .previewContext(WidgetPreviewContext(family: .systemMedium))
                    .environment(\.colorScheme, $0.element.colorScheme)
//                    .redacted(reason: .placeholder)
            }
        }
    }
}
#endif
