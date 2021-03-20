//
//  OverlayViews.swift
//  Strafen
//
//  Created by Steven on 3/20/21.
//

import SwiftUI

struct OverlayViews: View {
    
    /// Control for overlay view
    @ObservedObject var control = OverlayViewsControl.shared
    
    var body: some View {
        switch control.state {
        case .activityView:
            ActivityView.shared
        case .wrongVersionView:
            WrongVersionView()
        case nil:
            EmptyView()
        }
    }
}

class OverlayViewsControl: ObservableObject {
    
    enum State {
        case activityView
        case wrongVersionView
    }
    
    /// Shared instance for singelton
    static let shared = OverlayViewsControl()
    
    /// Private init for singleton
    private init() {}
    
    @Published private(set) var state: State? = nil
    
    func setState(_ state: State) {
        self.state = state
    }
    
    func reset(old oldState: State) {
        if state == oldState {
            state = nil
        }
    }
}
