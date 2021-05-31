//
//  ImportanceChanger.swift
//  Strafen
//
//  Created by Steven on 30.05.21.
//

import SwiftUI

/// Bar to change between the differnt importance types
struct ImportanceChanger: View {

    /// Importance to change
    @Binding var importance: Importance

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: 0) {

                    // Left Part
                    Outline(.left)
                        .fillColor(.customRed)
                        .frame(width: geometry.size.width / 3, height: geometry.size.height)
                        .setOnTapGesture($importance, to: .high, animation: .default)
                        .shadow(color: .black.opacity(0.25), radius: 10)

                    // Middle Part
                    Outline(.none)
                        .fillColor(.customOrange)
                        .frame(width: geometry.size.width / 3, height: geometry.size.height)
                        .setOnTapGesture($importance, to: .medium, animation: .default)
                        .shadow(color: .black.opacity(0.25), radius: 10)

                    // Right Part
                    Outline(.right)
                        .fillColor(.customYellow)
                        .frame(width: geometry.size.width / 3, height: geometry.size.height)
                        .setOnTapGesture($importance, to: .low, animation: .default)
                        .shadow(color: .black.opacity(0.25), radius: 10)

                }

                // Indicator
                Indicator(width: geometry.size.width / 8)
                    .offset(x: importance == .high ? -geometry.size.width / 3 : importance == .low ? geometry.size.width / 3 : 0)

            }
        }
    }
}
