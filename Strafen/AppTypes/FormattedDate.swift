//
//  FormattedDate.swift
//  Strafen
//
//  Created by Steven on 12.07.20.
//

import Foundation

/// Date with formatted Style
struct FormattedDate: Equatable {
    
    /// Raw date
    let date: Date
    
    /// Error for decoding json
    enum CodingError: Error {
        
        /// Error for unknown string value
        case unknownStringValue
    }
        
    /// Long format, only date, no time
    var formatted: String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("dMMMMyyyy")
        formatter.locale = Locale(identifier: "de")
        return formatter.string(from: date)
    }
    
    /// Formatted only date
    var shortFormatted: String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("dMyy")
        formatter.locale = Locale(identifier: "de")
        return formatter.string(from: date)
    }
    
    /// Formatted for POST method
    var formattedForPost: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
}

// Extension of FormattedDate for init from decoder
extension FormattedDate: Decodable {
    
    /// Init from decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawDate = try container.decode(String.self)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        guard let date = formatter.date(from: rawDate) else {
            throw CodingError.unknownStringValue
        }
        self.date = date
    }
}

// Extension of FormattedDate to encode to json
extension FormattedDate: Encodable {
    
    /// Encode to json
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        try container.encode(formatter.string(from: date))
    }
}
