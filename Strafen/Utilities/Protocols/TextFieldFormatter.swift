//
//  TextFieldFormatter.swift
//  Strafen
//
//  Created by Steven on 13.05.21.
//

import Foundation

/// Formatter for text of a textfield
protocol TextFieldFormatter {
    
    /// Converts original text to formatted text
    /// - Parameter originalText: original text
    func formattedText(_ originalText: String) -> String
    
    /// Converts formatted text to original text
    /// - Parameter formattedText: formatted text
    func originalText(_ formattedText: String) -> String
}

/// Default formatter for text of a textfield
struct DefaultTextFieldFormatter: TextFieldFormatter {
    
    func formattedText(_ originalText: String) -> String { originalText }
    
    func originalText(_ formattedText: String) -> String { formattedText }
}
