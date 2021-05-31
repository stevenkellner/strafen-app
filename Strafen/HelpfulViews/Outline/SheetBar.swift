//
//  SheetBar.swift
//  Strafen
//
//  Created by Steven on 30.05.21.
//

import SwiftUI

/// Bar to wipe sheet down
struct SheetBar: View {

    var body: some View {
        RoundedCorners()
            .radius(2.5)
            .lineWidth(2.5)
            .strokeColor(.tabBarBorderColor)
            .frame(width: 75, height: 2.5)
            .padding(.vertical, 20)
    }
}
