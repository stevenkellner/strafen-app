//
//  ContentView.swift
//  Strafen
//
//  Created by Steven on 04.05.21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        BackgroundWave(amplitute: 0.1, steps: 4)
            .frame(width: 200, height: 400)
            .foregroundColor(.blue)
    }
}
