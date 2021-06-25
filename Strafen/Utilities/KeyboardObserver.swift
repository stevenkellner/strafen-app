//
//  KeyboardObserver.swift
//  Strafen
//
//  Created by Steven on 25.06.21.
//

import UIKit

class KeyboardObserver {

    private(set) var keyboardOnScreen = false

    static let shared = KeyboardObserver()

    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardShown() {
        keyboardOnScreen = true
    }

    @objc func keyboardHide() {
        keyboardOnScreen = false
    }
}
