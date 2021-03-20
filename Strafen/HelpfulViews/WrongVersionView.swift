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
                Text("")
            }
        }.frame(size: UIScreen.main.bounds.size * 0.85)
    }
}
