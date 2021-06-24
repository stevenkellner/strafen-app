//
//  OverlayViews.swift
//  Strafen
//
//  Created by Steven on 23.06.21.
//

import SwiftUI

/// Views that overlays all other views
struct OverlayViews: View {

    /// Control for overlay view
    @ObservedObject var control = OverlayViewsControl.shared

    var body: some View {
        switch control.state {
        case .activityView: ActivityView.shared
        case nil: EmptyView()
        }
    }
}

/// Controls of overlayed views
class OverlayViewsControl: ObservableObject {

    /// State of control
    enum State {

        /// Activity view
        case activityView
    }

    /// Shared instance for singelton
    static let shared = OverlayViewsControl()

    /// Private init for singleton
    private init() {}

    /// State of control
    @Published private(set) var state: State?

    func setState(_ state: State) {
        self.state = state
    }

    func reset(old oldState: State) {
        if state == oldState {
            state = nil
        }
    }
}
