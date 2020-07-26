//
//  WidgetListTypes.swift
//  Strafen
//
//  Created by Steven on 25.07.20.
//

import Foundation

/// Protocol for all list types ( fine / reason / person)
protocol WidgetListTypes: Decodable, Identifiable {
    
    /// Url to list on server
    static var serverListUrl: KeyPath<WidgetUrls.ListTypesUrls, URL> { get }
}
