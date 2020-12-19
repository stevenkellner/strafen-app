//
//  Settings.swift
//  Strafen
//
//  Created by Steven on 14.07.20.
//

import SwiftUI
import FirebaseAuth
import WidgetKit

/// Setting View
struct SettingsView: View {
    
    ///Dismiss handler
    @Binding var dismissHandler: DismissHandler
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                
                // Background Color
                colorScheme.backgroundColor
                
                VStack(spacing: 0) {
                    
                    // Header
                    Header("Einstellungen")
                        .padding(.top, 50)
                    
                    // Settings
                    ScrollView(showsIndicators: true) {
                        VStack(spacing: 20) {
                            
                            // Club id
                            ClubId()
                            
                            if settings.person?.isCashier ?? false {
                                LatePaymentInterestChanger(dismissHandler: $dismissHandler)
                            }
                            
                            // Apearance Changer
                            AppearanceChanger()

                            // Style Changer
                            StyleChanger()
                            
                            if settings.person?.isCashier ?? false {
                                
                                // Fines Formatter
                                FinesFormatter(dismissHandler: $dismissHandler)
                                
                                // Force Sign out button
                                ForceSignOutButton(dismissHandler: $dismissHandler)
                                
                            }
                            
                            // Log out button
                            LogOutButton()
                            
                        }.padding(.vertical, 20)
                        
                        Spacer()
                    }.padding(.vertical, 10)
                }
            }.edgesIgnoringSafeArea(.all)
                .navigationTitle("title")
                .navigationBarHidden(true)
        }
    }
    
    /// Club id
    struct ClubId: View {
        
        /// Observed Object that contains all settings of the app of this device
        @ObservedObject var settings = Settings.shared
        
        var body: some View {
            VStack(spacing: 0) {
                    
                // Title
                Title("Deine Vereinskennung")
                
                // Club id
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        
                        // Club id
                        ZStack {
                            
                            // Outline
                            Outline(.left)
                            
                            // Id
                            Text(settings.person?.clubProperties.identifier ?? "")
                                .configurate(size: 20)
                                .padding(.horizontal, 10)
                        }.frame(width: geometry.size.width * 0.775)
                        
                        // Copy button
                        ZStack {
                            
                            // Outline
                            Outline(.right)
                                .fillColor(Color.custom.lightGreen, onlyDefault: false)
                            
                            // Copy button
                            Button {
                                guard let id = settings.person?.clubProperties.identifier else { return }
                                UIPasteboard.general.string = id
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.success)
                            } label: {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 25, weight: .light))
                                    .foregroundColor(.textColor)
                            }
                        }.frame(width: geometry.size.width * 0.225)
                    }
                }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                
            }
        }
    }
    
    /// Late payment interest changer
    struct LatePaymentInterestChanger: View {
        
        ///Dismiss handler
        @Binding var dismissHandler: DismissHandler
        
        /// Observed Object that contains all settings of the app of this device
        @ObservedObject var settings = Settings.shared
        
        var body: some View {
            VStack(spacing: 0) {
                
                // Title
                Title("Verzugszinsen")
                
                CustomNavigationLink(destination: LatePaymentInterestChangerView(dismissHandler: $dismissHandler)) {
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            
                            // Text
                            ZStack {
                                
                                // Outline
                                Outline(.left)
                                
                                // Text
                                Text(settings.latePaymentInterest?.description ?? "Verzugszinsen")
                                    .configurate(size: 20)
                                    .lineLimit(1)
                                    .padding(.leading, 10)
                                
                            }.frame(width: geometry.size.width * 0.775, height: 50)
                            
                            // Outline
                            Outline(.right)
                                .fillColor(settings.latePaymentInterest == nil ? Color.custom.red : Color.custom.lightGreen, onlyDefault: false)
                                .frame(width: geometry.size.width * 0.225, height: 50)
                        }
                    }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                }
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
                Title("Aussehen")
                
                // Changer
                ZStack {
                    
                    // Fields
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            
                            // Left Section
                            Outline(.left)
                                .fillColor(colorScheme == .dark ? Color.plain.darkDarkGray : Color.plain.darkGray, onlyDefault: false)
                                .frame(width: geometry.size.width / 3)
                                .onTapGesture {
                                    settings.appearance = .dark
                                }
                            
                            // Middle Section
                            Outline(.none)
                                .fillColor(colorScheme == .dark ? Color.plain.lightGray : Color.plain.lightLightGray, onlyDefault: false)
                                .frame(width: geometry.size.width / 3)
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
                            }.frame(width: geometry.size.width / 3)
                                .onTapGesture {
                                    settings.appearance = .system
                                }
                        }
                    }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                    
                    // Indicator
                    Indicator(width: 33)
                        .offset(x: settings.appearance == .dark ? -UIScreen.main.bounds.width * 0.3187 : (settings.appearance == .system ? UIScreen.main.bounds.width * 0.3187 : 0))
                        .animation(.default)
                    
                }
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
                Title("Design")
                
                // Changer
                ZStack {
                    
                    // Fields
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            
                            // Left Section
                            ZStack {
                                
                                // Outline
                                Outline(.left)
                                    .fillColor(default: Color.custom.lightGreen)
                                    .fillColor(plain: colorScheme == .dark ? Color.plain.darkDarkGray : Color.plain.lightLightGray)
                                
                                // Text
                                Text("Standard")
                                    .foregroundColor(Color.custom.gray)
                                    .font(.text(20))
                                    .lineLimit(1)
                                    .opacity(settings.style == .default ? 0.75 : 1)
                                    .padding(.horizontal, 15)
                                    
                                
                            }.frame(width: geometry.size.width * 0.5)
                                .onTapGesture {
                                    withAnimation { settings.style = .default }
                                }
                            
                            // Right Section
                            ZStack {
                                
                                // Outline
                                Outline(.right)
                                    .fillColor(default: Color.plain.lightGray)
                                    .fillColor(plain: Color.plain.darkGray)
                                
                                // Text
                                Text("Einfach")
                                    .foregroundColor(settings.style == .default ? Color.custom.gray : Color.plain.lightGray)
                                    .font(.text(20))
                                    .lineLimit(1)
                                    .opacity(settings.style == .plain ? 0.75 : 1)
                                    .padding(.horizontal, 15)
                                
                            }.frame(width: geometry.size.width * 0.5)
                                .onTapGesture {
                                    withAnimation { settings.style = .plain }
                                }
                            
                        }
                    }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                    
                    // Indicator
                    Indicator(width: 50)
                        .offset(x: settings.style == .default ? -UIScreen.main.bounds.width * 0.2375 : UIScreen.main.bounds.width * 0.2375)
                        .animation(.default)
                    
                }
            }
        }
    }
    
    /// Fines Formatter
    struct FinesFormatter: View {
        
        ///Dismiss handler
        @Binding var dismissHandler: DismissHandler
        
        var body: some View {
            VStack(spacing: 0) {
                
                // Title
                Title("Strafen teilen")
                
                CustomNavigationLink(destination: FinesFormatterView(dismissHandler: $dismissHandler)) {
                    HStack(spacing: 0) {
                        
                        // Text
                        ZStack {
                            
                            // Outline
                            Outline(.left)
                            
                            // Text
                            Text("Strafen Teilen")
                                .configurate(size: 20)
                                .lineLimit(1)
                                .padding(.leading, 10)
                            
                        }.frame(width: UIScreen.main.bounds.width * 0.75, height: 50)
                        
                        // Arrow
                        ZStack {
                            
                            // Outline
                            Outline(.right)
                                .fillColor(Color.custom.lightGreen, onlyDefault: false)
                            
                            // Arrow
                            Image(systemName: "arrowshape.turn.up.left.2")
                                .rotation3DEffect(.radians(.pi), axis: (x: 0, y: 1, z: 0))
                                .font(.system(size: 25, weight: .light))
                                .foregroundColor(.textColor)
                                .padding(.leading, 15)
                                .padding(.trailing, 10)
                            
                        }.frame(width: UIScreen.main.bounds.width * 0.2, height: 50)
                    }
                }
            }
        }
    }
    
    /// Force sign out button
    struct ForceSignOutButton: View {
        
        ///Dismiss handler
        @Binding var dismissHandler: DismissHandler
        
        var body: some View {
            VStack(spacing: 0) {
                Title("Abmelden Anderer Erzwingen")
                CustomNavigationLink(destination: SettingsForceSignOut(dismissHandler: $dismissHandler)) {
                    ZStack {
                        Outline()
                        Text("Abmelden Anderer Erzwingen")
                            .configurate(size: 20)
                            .lineLimit(1)
                    }
                }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
            }
        }
    }
    
    /// Log out button
    struct LogOutButton: View {
        
        /// Settings
        @ObservedObject var settings = Settings.shared
        
        /// Indicates if log out alert is shown
        @State var isLogOutAlertShown = false
        
        var body: some View {
            VStack(spacing: 0) {
                Title("Abmelden")
                ZStack {
                    Outline()
                        .fillColor(Color.custom.red, onlyDefault: false)
                    Text("Abmelden")
                        .configurate(size: 20)
                        .toggleOnTapGesture($isLogOutAlertShown)
                        .alert(isPresented: $isLogOutAlertShown) {
                            Alert(title: Text("Abmelden"),
                                  message: Text("Möchtest du wirklich abgemldet werden?"),
                                  primaryButton: .default(Text("Abbrechen")),
                                  secondaryButton: .destructive(Text("Abmelden"), action: {
                                    try? Auth.auth().signOut()
                                    settings.person = nil
                                    WidgetCenter.shared.reloadTimelines(ofKind: "StrafenWidget")
                                  }))
                        }
                }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
            }
        }
    }
    
    /// Title of a setting
    struct Title: View {
        
        /// Title
        var title: String
        
        init(_ title: String) {
            self.title = title
        }
        
        var body: some View {
            HStack(spacing: 0) {
                Text("\(title):")
                    .configurate(size: 20)
                    .padding(.leading, 10)
                Spacer()
            }.padding(.bottom, 5)
        }
    }
}
