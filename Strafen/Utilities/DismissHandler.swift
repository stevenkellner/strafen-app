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

struct SetDismissHandlerViewModifier: ViewModifier {

    /// Handler to dimiss from a subview to the previous view.
    @EnvironmentObject var dismissHandler: DismissHandler

    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode

    func body(content: Content) -> some View {
        content
            .onAppear {
                dismissHandler.setHandler {
                    presentationMode.wrappedValue.dismiss()
                }
            }
    }
}

extension View {

    /// Set dismiss handler
    var dismissHandler: some View {
        ModifiedContent(content: self, modifier: SetDismissHandlerViewModifier())
    }
}
