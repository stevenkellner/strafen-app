//
//  FirebaseListType.swift
//  Strafen
//
//  Created by Steven on 04.05.21.
//

import Foundation

/// Type of Firebase List
protocol FirebaseListType: Decodable, Identifiable where ID: FirebaseParameterable {

    /// Url from club to list in firebase database
    static var urlFromClub: URL { get }

    /// List type to change in database
    static var listType: String { get }

    /// Set of parameters to call a firebase function
    var parameterSet: FirebaseCallParameterSet { get }
}
