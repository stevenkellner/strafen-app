//
//  FormattedDate.swift
//  Strafen
//
//  Created by Steven on 12.07.20.
//

import Foundation

/// Date with formatted Style
struct FormattedDate: Decodable {
    
    /// Raw date
    private let date: Date
    
    /// Error for decoding json
    enum CodingError: Error {
        
        /// Error for unknown string value
        case unknownStringValue
    }
    
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
