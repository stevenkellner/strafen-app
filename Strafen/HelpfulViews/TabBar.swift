//
//  TabBar.swift
//  Strafen
//
//  Created by Steven on 11.07.20.
//

import SwiftUI

/// Tab Bar that contains the Buttons to navigate through the home tabs
struct TabBar: View {
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Active home tab
    @ObservedObject var homeTabs = HomeTabs.shared
    
    /// Handler to dimiss from a subview to the previous view.
    @Binding var dismissHandler: DismissHandler
    
    var body: some View {
        ZStack {
            
            colorScheme.backgroundColorSecondary(settings)
                .frame(height: 65)
                .offset(y: 65)
            
            // Outline in default style
            if settings.style == .default {
                GeometryReader { geometry in
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 72))
                        path.addLine(to: CGPoint(x: 0, y: 10))
                        path.addArc(center: CGPoint(x: 10, y: 10), radius: 10, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
                        path.addLine(to: CGPoint(x: geometry.size.width - 10, y: 0))
                        path.addArc(center: CGPoint(x: geometry.size.width - 10, y: 10), radius: 10, startAngle: .degrees(-90), endAngle: .zero, clockwise: false)
                        path.addLine(to: CGPoint(x: geometry.size.width, y: 72))
                    }.stroke(Color.custom.darkGreen, lineWidth: 2)
                }.frame(height: 72)
                    .padding(.horizontal, 1)
            }
            
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    
                    // Outline in plain style
                    if settings.style == .plain {
                        Rectangle()
                            .frame(width: geometry.size.width, height: 1)
                            .border(Color.plain.strokeColor(colorScheme), width: 0.5)
                    }
                    
                    // TabBar items
                    HStack(spacing: 0) {
                        
                        // Profile Detail Button
                        ButtonContent(tab: .profileDetail, size: geometry.size) {
                            if let dismissHandler = dismissHandler { dismissHandler() }
                        }
                        
                        // Left Divider
                        if settings.style == .default {
                            Rectangle()
                                .frame(width: 2, height: geometry.size.height * 3 / 4)
                                .border(Color.custom.darkGreen, width: 1)
                        }
                        
                        // Person Button
                        ButtonContent(tab: .personList, size: geometry.size) {
                            if let dismissHandler = dismissHandler { dismissHandler() }
                        }
                        
                        // Middle Divider
                        if settings.style == .default {
                            Rectangle()
                                .frame(width: 2, height: geometry.size.height * 3 / 4)
                                .border(Color.custom.darkGreen, width: 1)
                        }
                        
                        // Reason Button
                        ButtonContent(tab: .reasonList, size: geometry.size, tabHandler: nil)
                    
                        if settings.person?.isCashier ?? false {
                            
                            // Add New Fine Button
                            if settings.style == .default {
                                ZStack {
                                    Circle()
                                        .overlay(
                                            Circle()
                                                .stroke(Color.custom.darkGreen, lineWidth: 2)
                                        )
                                        .frame(width: geometry.size.width / 7, height: geometry.size.height)
                                        .foregroundColor(Color.custom.lightGreen)
                                    Image(systemName: HomeTabs.Tabs.addNewFine.imageName)
                                        .font(.system(size: 35, weight: .light))
                                        .foregroundColor(homeTabs.active == .addNewFine ? Color.custom.orange : Color.custom.gray)
                                }.offset(y: -20)
                                    .onTapGesture {
                                        homeTabs.active = .addNewFine
                                    }
                            } else if settings.style == .plain {
                                ButtonContent(tab: .addNewFine, size: geometry.size, tabHandler: nil)
                            }
                            
                        // Right Divider
                        } else if settings.style == .default {
                            Rectangle()
                                .frame(width: 2, height: geometry.size.height * 3 / 4)
                                .border(Color.custom.darkGreen, width: 1)
                        }
                        
                        // Settings Button
                        ButtonContent(tab: .settings, size: geometry.size) {
                            if let dismissHandler = dismissHandler { dismissHandler() }
                        }
        
                    }
                    
                }
            }.frame(height: 65)
        }.background(settings.style == .plain ? colorScheme == .light ? Color.plain.lightLightGray : Color.plain.darkDarkGray : colorScheme.backgroundColor)
    }
    
    /// Content of TabBar Button
    struct ButtonContent: View {
        
        /// Tab type of this Button
        let tab: HomeTabs.Tabs
        
        /// Button size
        let size: CGSize
        
        /// Active home tab
        @ObservedObject var homeTabs = HomeTabs.shared
        
        /// Observed Object that contains all settings of the app of this device
        @ObservedObject var settings = Settings.shared
        
        /// Handles the tab
        let tabHandler: (() -> ())?
        
        var body: some View {
            Button {
                if let tabHandler = tabHandler { tabHandler() }
                homeTabs.active = tab
            } label: {
                VStack(spacing: 0) {
                    
                    // Image
                    Image(systemName: tab.imageName)
                        .font(.system(size: 30, weight: .thin))
                        .foregroundColor(tab == homeTabs.active ? Color.custom.orange : Color.custom.darkGreen)
                        .frame(height: 30)
                    
                    // Title
                    Text(tab.title)
                        .foregroundColor(.textColor)
                        .font(.text(10))
                        .lineLimit(1)
                        .padding(.top, 8)
                        .padding(.horizontal, 2)
                    
                }.frame(width: settings.person?.isCashier ?? false ? size.width / 5 : size.width / 4, height: size.height)
            }.buttonStyle(PlainButtonStyle())
        }
    }
}
