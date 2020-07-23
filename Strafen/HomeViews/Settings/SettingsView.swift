//
//  Settings.swift
//  Strafen
//
//  Created by Steven on 14.07.20.
//

import SwiftUI

/// Setting View
struct SettingsView: View {
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    var body: some View {
        ZStack {
            
            // Background Color
            colorScheme.backgroundColor
            
            VStack(spacing: 0) {
                
                // Header
                Header("Einstellungen")
                    .padding(.top, 50)
                
                Spacer()
                
                // Club id
                VStack(spacing: 0) {
                        
                    // Club id title
                    HStack(spacing: 0) {
                        Text("Dein Vereinscode:")
                            .foregroundColor(.textColor)
                            .font(.text(20))
                            .padding(.leading, 10)
                        Spacer()
                    }
                    
                    // Club id
                    HStack(spacing: 0) {
                        Spacer()
                        
                        // Id
                        Text(settings.person!.clubId.uuidString)
                            .foregroundColor(.orange)
                            .font(.text(17))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 15)
                        
                        Spacer()
                        
                        // Copy Button
                        Button {
                            UIPasteboard.general.string = settings.person!.clubId.uuidString
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 25, weight: .light))
                                .foregroundColor(.textColor)
                        }.padding(.trailing, 15)
                        
                        Spacer()
                    }.padding(.top, 5)
                    
                }
                
                Spacer()

                // Apearance Changer
                AppearanceChanger()
                
                Spacer()

                // Style Changer
                StyleChanger()
                
                Spacer()
                
                Text(settings.person?.isCashier ?? false ? "Zu kein Kassier" : "Zu Kassier") // TODO remove
                    .font(.text(20))
                    .foregroundColor(.textColor)
                    .frame(height: 50)
                    .onTapGesture {
                        settings.person?.isCashier.toggle()
                    }
                
                // Log Out TODO
                
                Spacer()
            }
        }
    }
    
    /// Apearance Changer
    struct AppearanceChanger: View {

        /// Color scheme to get appearance of this device
        @Environment(\.colorScheme) var colorScheme
        
        /// Observed Object that contains all settings of the app of this device
        @ObservedObject var settings = Settings.shared
        
        var body: some View {
            VStack(spacing: 0) {
                
                // Title
                HStack(spacing: 0) {
                    Text("Aussehen:")
                        .foregroundColor(.textColor)
                        .font(.text(20))
                        .padding(.leading, 10)
                    Spacer()
                }
                
                // Changer
                ZStack {
                    
                    // Fields
                    HStack(spacing: 0) {
                        
                        // Left Section
                        Outline(.left)
                            .fillColor(colorScheme == .dark ? Color.plain.darkDarkGray : Color.plain.darkGray, onlyDefault: false)
                            .frame(width: UIScreen.main.bounds.width * 0.3187, height: 50)
                            .onTapGesture {
                                settings.appearance = .dark
                            }
                        
                        // Middle Section
                        Outline(.none)
                            .fillColor(colorScheme == .dark ? Color.plain.lightGray : Color.plain.lightLightGray, onlyDefault: false)
                            .frame(width: UIScreen.main.bounds.width * 0.3187, height: 50)
                            .onTapGesture {
                                settings.appearance = .light
                            }
                        
                        // Right Section
                        GeometryReader { geometry in
                            ZStack {
                                
                                // Top Left Color (dark)
                                Path { path in
                                    path.move(to: .zero)
                                    path.addLine(to: CGPoint(x: geometry.size.width - (settings.style == .default ? 10 : 5), y: 0))
                                    path.addArc(center: CGPoint(x: geometry.size.width - (settings.style == .default ? 10 : 5), y: (settings.style == .default ? 10 : 5)), (settings.style == .default ? 10 : 5), startAngle: .zero, endAngle: .radians(0.614756), clockwise: false)
                                    path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                                    path.addLine(to: .zero)
                                }.fill(colorScheme == .dark ? Color.plain.darkDarkGray : Color.plain.darkGray)
                                
                                // Bottom Right Color (light)
                                Path { path in
                                    path.move(to: CGPoint(x: 0, y: geometry.size.height))
                                    path.addLine(to: CGPoint(x: geometry.size.width - (settings.style == .default ? 10 : 5), y: geometry.size.height))
                                    path.addArc(center: CGPoint(x: geometry.size.width - (settings.style == .default ? 10 : 5), y: geometry.size.height - (settings.style == .default ? 10 : 5)), (settings.style == .default ? 10 : 5), startAngle: .radians(.pi), endAngle: .radians(.pi / 2), clockwise: true)
                                    path.addLine(to: CGPoint(x: geometry.size.width, y: (settings.style == .default ? 10 : 5)))
                                    path.addArc(center: CGPoint(x: geometry.size.width - (settings.style == .default ? 10 : 5), y: (settings.style == .default ? 10 : 5)), (settings.style == .default ? 10 : 5), startAngle: .radians(.pi), endAngle: .radians(0.614756), clockwise: true)
                                    path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                                }.fill(colorScheme == .dark ? Color.plain.lightGray : Color.plain.lightLightGray)
                                
                                // Outline
                                RoundedCorners(.right)
                                    .strokeColor(settings.style.strokeColor(colorScheme))
                                    .lineWidth(settings.style.lineWidth)
                                    .radius(settings.style.radius)
                                    .frame(width: UIScreen.main.bounds.width * 0.3187, height: 50)
                                
                            }
                        }.frame(width: UIScreen.main.bounds.width * 0.3187, height: 50)
                            .onTapGesture {
                                settings.appearance = .system
                            }
                    }
                    
                    // Indicator
                    RoundedCorners()
                        .strokeColor(Color.custom.gray)
                        .lineWidth(2.5)
                        .radius(2.5)
                        .frame(width: 33, height: 2.5)
                        .offset(x: settings.appearance == .dark ? -UIScreen.main.bounds.width * 0.3187 : (settings.appearance == .system ? UIScreen.main.bounds.width * 0.3187 : 0))
                        .animation(.default)
                    
                }.padding(.top, 5)
            }
        }
    }
    
    /// Style Changer
    struct StyleChanger: View {
        
        /// Color scheme
        @Environment(\.colorScheme) var colorScheme
        
        /// Settings
        @ObservedObject var settings = Settings.shared
        
        var body: some View {
            VStack(spacing: 0) {
                
                // Title
                HStack(spacing: 0) {
                    Text("Design:")
                        .foregroundColor(.textColor)
                        .font(.text(20))
                        .padding(.leading, 10)
                    Spacer()
                }
                
                // Changer
                ZStack {
                    
                    // Fields
                    HStack(spacing: 0) {
                        
                        // Left Section
                        ZStack {
                            
                            // Outline
                            RoundedCorners(.left)
                                .strokeColor(settings.style == .default ? Color.custom.gray : Color.plain.strokeColor(colorScheme))
                                .fillColor(settings.style == .default ? Color.custom.lightGreen : (colorScheme == .dark ? Color.plain.darkDarkGray : Color.plain.lightLightGray))
                                .lineWidth(settings.style == .default ? 2 : 0.5)
                                .radius(settings.style == .default ? 10 : 5)
                            
                            // Text
                            Text("Standard")
                                .foregroundColor(Color.custom.gray)
                                .font(.custom("Futura-Medium", size: 20))
                                .lineLimit(1)
                                .opacity(settings.style == .default ? 0.75 : 1)
                                .padding(.horizontal, 15)
                                
                            
                        }.frame(width: UIScreen.main.bounds.width * 0.475, height: 50)
                            .onTapGesture {
                                withAnimation {
                                    settings.style = .default
                                }
                            }
                        
                        // Right Section
                        ZStack {
                            
                            // Outline
                            RoundedCorners(.right)
                                .strokeColor(settings.style == .default ? Color.custom.gray : Color.plain.strokeColor(colorScheme))
                                .fillColor(settings.style == .default ? Color.plain.lightGray : Color.plain.darkGray)
                                .lineWidth(settings.style == .default ? 2 : 0.5)
                                .radius(settings.style == .default ? 10 : 5)
                            
                            // Text
                            Text("Einfach")
                                .foregroundColor(settings.style == .default ? Color.custom.gray : Color.plain.lightGray)
                                .font(.custom("Futura-Medium", size: 20))
                                .lineLimit(1)
                                .opacity(settings.style == .plain ? 0.75 : 1)
                                .padding(.horizontal, 15)
                            
                        }.frame(width: UIScreen.main.bounds.width * 0.475, height: 50)
                            .onTapGesture {
                                withAnimation {
                                    settings.style = .plain
                                }
                            }
                        
                    }
                    
                    // Indicator
                    RoundedCorners()
                        .strokeColor(settings.style == .default ? Color.custom.gray : Color.plain.lightLightGray)
                        .lineWidth(2.5)
                        .radius(2.5)
                        .frame(width: 50, height: 2.5)
                        .offset(x: settings.style == .default ? -UIScreen.main.bounds.width * 0.2375 : UIScreen.main.bounds.width * 0.2375)
                        .animation(.default)
                    
                }.padding(.top, 5)
            }
        }
    }
}
