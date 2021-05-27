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

                    Text("asldkjf")
                        .edgesIgnoringSafeArea(.all)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Tab bar
                    TabBar()
                        .edgesIgnoringSafeArea([.horizontal, .top])

                }.environmentObject(person)
                    .environmentObject(DismissHandler())
                    .environmentObject(HomeTab.shared)

            } else {

                LoginView()
            }

        }.onAppear {
            UIApplication.shared.windows.first!.overrideUserInterfaceStyle = .dark
        }
    }
}
