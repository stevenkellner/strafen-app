//
//  AppTypes.swift
//  Strafen
//
//  Created by Steven on 02.07.20.
//

import Foundation

/// Protocol for all app types (club / fine / reason / person)
protocol AppTypes: Decodable {
    
    /// Url to list on server
    static var serverListUrl: KeyPath<AppUrls, URL?> { get }
}
