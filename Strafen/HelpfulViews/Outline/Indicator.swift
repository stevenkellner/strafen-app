//
//  Indicator.swift
//  Strafen
//
//  Created by Steven on 30.05.21.
//

import SwiftUI

/// Indicator
struct Indicator: View {

    /// Width
    let width: CGFloat

    var body: some View {
        RoundedCorners()
            .strokeColor(.tabBarBorderColor)
            .lineWidth(2.5)
            .radius(2.5)
            .frame(width: width, height: 2.5)
    }
}
