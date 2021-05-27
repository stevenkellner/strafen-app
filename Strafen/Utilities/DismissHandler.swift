//
//  DismissHandler.swift
//  Strafen
//
//  Created by Steven on 26.05.21.
//

import SwiftUI

/// Contains handler to dismiss current view
class DismissHandler: ObservableObject {

    /// Handler to dissmiss current view
    @Published private var handler: (() -> Void)?

    /// Sets handler to dismiss current view
    /// - Parameter handler: Handler to dimiss current view
    func setHandler(_ handler: @escaping () -> Void) {
        self.handler = handler
    }

    /// Dismisses current view
    func dismissCurrentView() {
        handler?()
    }
}
