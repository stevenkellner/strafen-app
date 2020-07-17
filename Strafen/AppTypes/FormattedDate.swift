//
//  FormattedDate.swift
//  Strafen
//
//  Created by Steven on 12.07.20.
//

import Foundation

/// Date with formatted Style
struct FormattedDate: Decodable, Equatable {
    
    /// Raw date
    let date: Date
    
    /// Error for decoding json
    enum CodingError: Error {
        
        /// Error for unknown string value
        case unknownStringValue
    }
        
    /// Long format, only date, no time
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("dMMMMyyyy")
        formatter.locale = Locale(identifier: "de")
        return formatter.string(from: date)
    }
}

// Extension for FormattedDate for init from decoder
extension FormattedDate {
    
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
