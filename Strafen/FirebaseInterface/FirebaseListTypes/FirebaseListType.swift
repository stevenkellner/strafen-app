//
//  FirebaseListType.swift
//  Strafen
//
//  Created by Steven on 04.05.21.
//

import Foundation

/// Type of Firebase List
protocol FirebaseListType: Decodable, Identifiable {
    
    /// Url from club to list in firebase database
    static var urlFromClub: URL { get }
}
