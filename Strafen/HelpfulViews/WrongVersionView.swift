//
//  WrongVersionView.swift
//  Strafen
//
//  Created by Steven on 3/20/21.
//

import SwiftUI

struct WrongVersionView: View {
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    var body: some View {
        ZStack {
            RoundedCorners().fillColor(colorScheme.backgroundColorSecondary(settings))
            VStack(spacing: 5) {
                Spacer()
                LottieAnimation(name: "errorLadder", size: OptionalSize(height: UIScreen.main.bounds.height * 0.35)).frame(height: UIScreen.main.bounds.height * 0.35)
                Spacer()
                Text("Alte Version").foregroundColor(Color.custom.red).configurate(size: 30).lineLimit(1).padding(.horizontal, 25)
                Text("Es ist ein Update verfügbar.").configurate(size: 25).lineLimit(2).padding(.horizontal, 25).padding(.top, 15)
                Text("Installiere die neueste Version, um fortzufahren.").configurate(size: 25).lineLimit(3).padding(.horizontal, 25).padding(.top, 10)
                Spacer()
            }
        }.frame(size: UIScreen.main.bounds.size * 0.85)
    }
}
