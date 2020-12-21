//
//  KeyboardAdaptive.swift
//  Strafen
//
//  Created by Steven on 10/22/20.
//

import SwiftUI
import Combine

// Extension of Publishers to get a publisher when a keyboard is shown / hide
extension Publishers {
    
    /// Keyboard heights before and after keyboard appereance on screen
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

// Extension of Notification to get the height of shown keyboard
extension Notification {
    
    /// Height of shown keyboard
    var keyboardHeight: CGFloat {
        (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

// Extenison of UIResponder to get the current first responder
extension UIResponder {
    
    /// Current first responder
    static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }
    
    /// Private current first responder
    private static weak var _currentFirstResponder: UIResponder?
    
    /// Finds current first responder
    @objc private func findFirstResponder(_ sender: Any) {
        UIResponder._currentFirstResponder = self
    }
    
    /// Global frame
    var globalFrame: CGRect? {
        guard let view = self as? UIView else { return nil}
        return view.superview?.convert(view.frame, to: nil)
    }
}

// Extension of CGSize to get infinity size
extension CGSize {
    
    /// Infinity size
    static var infinity: CGSize {
        CGSize(width: CGFloat.infinity, height: .infinity)
    }
}

/// View modifier for adaptive keyboard avoidance
struct KeyboardAdaptive: ViewModifier {
    
    /// Padding to the bottom
    @State private var bottomPadding: CGFloat = 0
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .padding(.bottom, bottomPadding)
                .onReceive(Publishers.keyboardHeight) { keyboardHeight in
                    let keyboardTop = geometry.frame(in: .global).height - keyboardHeight
                    let focusedTextInputBottom = UIResponder.currentFirstResponder?.globalFrame?.maxY ?? 0
                    bottomPadding = max(0, focusedTextInputBottom - keyboardTop - geometry.safeAreaInsets.bottom + 5)
                }
                .animation(.easeOut)
        }
    }
}

/// View modifier for adaptive keyboard avoidance offset
struct KeyboardAdaptiveOffset: ViewModifier {
    
    /// y - offset
    @State private var yOffset: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .animation(.easeOut)
            .offset(y: -yOffset)
            .onReceive(Publishers.keyboardHeight) { keyboardHeight in
                let keyboardTop = UIScreen.main.bounds.size.height - keyboardHeight
                let focusedTextInputBottom = UIResponder.currentFirstResponder?.globalFrame?.maxY ?? 0
                yOffset = max(0, focusedTextInputBottom - keyboardTop + 5)
            }
    }
}

// Extension of View to modify for adaptive keyboard avoidance
extension View {
    
    /// Modifier for adaptive keyboard avoidance
    var keyboardAdaptive: some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive())
    }
    
    /// Modifier for adaptive keyboard avoidance offset
    var keyboardAdaptiveOffset: some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptiveOffset())
    }
}
