//
//  EmptyNavigationLink.swift
//  Strafen
//
//  Created by Steven on 10.05.21.
//

import SwiftUI

/// Empty navigation link
struct EmptyNavigationLink<Destination>: View where Destination: View {

    /// Indicates wheter navigation link is active
    @Binding var isActive: Bool

    /// Destination view
    let destination: Destination

    /// Init with is active binding and destination
    /// - Parameters:
    ///   - isActive: indicates wheter navigation link is active
    ///   - destination: destination view
    init(isActive: Binding<Bool> = .constant(true), @ViewBuilder destination: () -> Destination) {
        self._isActive = isActive
        self.destination = destination()
    }

    var body: some View {
        NavigationLink( destination: destination, isActive: $isActive) {}
    }
}
