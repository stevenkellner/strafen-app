//
//  ContentView.swift
//  Strafen
//
//  Created by Steven on 04.05.21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        LoginView()
            .onAppear {
                UIApplication.shared.windows.first!.overrideUserInterfaceStyle = .dark
            }
    }
}
