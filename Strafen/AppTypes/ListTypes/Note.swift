//
//  Note.swift
//  Strafen
//
//  Created by Steven on 18.07.20.
//

import Foundation

/// Note with subject, date and message
struct Note: Identifiable, Equatable, LocalListTypes {
    
    /// Url to local list
    static let localListUrl = \AppUrls.notesUrl
    
    /// List data of this local list type
    static let listData = ListData.note
    
    /// Id
    let id: UUID
    
    /// Subject
    let subject: String
    
    /// Date
    let date: FormattedDate
    
    /// Message
    let message: String
}
