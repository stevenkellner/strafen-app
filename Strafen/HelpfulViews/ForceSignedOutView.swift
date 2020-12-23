//
//  ForceSignedOutView.swift
//  Strafen
//
//  Created by Steven on 9/7/20.
//

import SwiftUI
import FirebaseAuth
import WidgetKit

struct ForceSignedOutView: View {
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// List data
    @ObservedObject var listData = ListData.shared
    
    var body: some View {
        VStack {
            
            // Header
            Header("Abgemeldet")
                .padding(.top, 35)
            
            Spacer()
            
            Text("Du wurdest vom Kassier oder Trainer abgemeldet, da du dich wahrscheinlich als falsche Person angemeldet hast.")
                .configurate(size: 25)
                .padding(.horizontal, 15)
                .lineLimit(2)
            
            Spacer()
            
            Text("Du kannst dich erneut registrieren und deinem Team beitreten.")
                .configurate(size: 25)
                .padding(.horizontal, 15)
                .lineLimit(2)
            
            Spacer()
            
            // Back to log in button
            ZStack {
                
                // Outline
                Outline()
                    .fillColor(Color.custom.lightGreen)
                
                // Text
                Text("Zurück zur Anmeldung")
                    .foregroundColor(plain: Color.custom.lightGreen)
                    .font(.text(20))
                    .lineLimit(1)
                
            }.frame(width: UIScreen.main.bounds.width * 0.7, height: 50)
                .padding(.bottom, 50)
                .onTapGesture {
                    listData.forceSignedOut = false
                    try? Auth.auth().signOut()
                    settings.person = nil
                    WidgetCenter.shared.reloadTimelines(ofKind: "StrafenWidget")
                }
        }
    }
}
