//
//  LoginEntryView.swift
//  Strafen
//
//  Created by Steven on 10.05.21.
//

import SwiftUI

/// Used to navigate through all login and signin views
struct LoginEntryView: View {
    var body: some View {
        ZStack {
            
            // Background color
            Color.backgroundGray
            
            // Background wave
            BackgroundWave(amplitute: 0.075, steps: 3)
                .frame(width: 250, height: 500)
                .foregroundColor(.waveGray)
            
            SignInView()
            
        }.edgesIgnoringSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
