//
//  ForceSignedOutView.swift
//  Strafen
//
//  Created by Steven on 9/7/20.
//

import SwiftUI

struct ForceSignedOutView: View {
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// List data
    @ObservedObject var listData = ListData.shared
    
    var body: some View {
        VStack {
            
            // Header
            Header("Abgemeldet")
                .padding(.top, 50)
            
            Spacer()
            
            Text("Du wurdest vom Kassier oder Trainer abgemeldet, da du dich wahrscheinlich als falsche Person angemeldet hast.")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 15)
                .font(.text(25))
                .foregroundColor(.textColor)
            
            Spacer()
            
            Text("Du kannst dich erneut registrieren und deinem Team beitreten.")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 15)
                .font(.text(25))
                .foregroundColor(.textColor)
            
            Spacer()
            
            // Back to log in button
            ZStack {
                
                // Outline
                Outline()
                    .fillColor(settings.style.fillColor(colorScheme, defaultStyle: Color.custom.lightGreen))
                
                // Text
                Text("Zurück zur Anmeldung")
                    .foregroundColor(settings.style == .default ? Color.custom.gray : Color.custom.lightGreen)
                    .font(.text(20))
                    .lineLimit(1)
                
            }.frame(width: UIScreen.main.bounds.width * 0.7, height: 50)
                .padding(.bottom, 50)
                .onTapGesture {
                    listData.forceSignedOut = false
                    settings.person = nil
                }
        }
    }
}
