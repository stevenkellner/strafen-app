//
//  ContentView.swift
//  Strafen
//
//  Created by Steven on 04.05.21.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {

    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared

    var body: some View {
        ZStack {

            if let person = settings.person, Auth.auth().currentUser != nil {

                VStack(spacing: 0) {

                }.maxFrame
                    .environmentObject(person)
                    .environmentObject(DismissHandler())

            } else {

                LoginView()
            }

        }.onAppear {
            UIApplication.shared.windows.first!.overrideUserInterfaceStyle = .dark
        }
    }
}
