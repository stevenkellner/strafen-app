//
//  TextFieldFirstResponders.swift
//  Strafen
//
//  Created by Steven on 12.05.21.
//

import Foundation

/// Contains list of all textfield handlers to become first responder
struct TextFieldFirstResponders<TextFields> where TextFields: TextFieldsProtocol {
    
    /// List of all textfield handlers to become first responder
    private var handlerList = [(textField: TextFields, handler: () -> Void)]()
    
    /// Init with textfields type
    init() {}
    
    /// Append new handler with given textfield to all textfield handlers
    /// - Parameters:
    ///   - textField: textfield of new handler
    ///   - becomeFirstResponderHandler: handler to become first responders
    public mutating func append(_ textField: TextFields, handler becomeFirstResponderHandler: @escaping () -> Void) {
        handlerList.append((textField: textField, handler: becomeFirstResponderHandler))
        handlerList.sort { $0.textField < $1.textField }
    }
    
    /// Makes given textfield to first responder
    /// - Parameter textField: textField
    public func becomeFirstResponder(_ textField: TextFields) {
        guard let handler = handlerList.first(where: { $0.textField == textField })?.handler else { return }
        handler()
    }
}

extension TextFieldFirstResponders where TextFields == DefaultTextFields {
    
    /// Init with default values
    init() {}
}
