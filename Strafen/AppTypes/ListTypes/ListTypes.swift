//
//  ListstTypes.swift
//  Strafen
//
//  Created by Steven on 02.07.20.
//

import Foundation

/// Protocol for all list types (club / fine / reason / person)
protocol ListTypes: Decodable, Identifiable {
    
    /// Url to list on server
    static var serverListUrl: KeyPath<AppUrls, URL?> { get }
    
    /// List data of this server list type
    static var listData: ListDataListType<Self> { get }
    
    /// Url to changer on server
    static var changerUrl: KeyPath<AppUrls, URL>? { get }
    
    /// Parameters for POST method
    var postParameters: [String : Any]? { get }
}

/// Protocol for all local list types (notes)
protocol LocalListTypes: Codable, Identifiable {
    
    /// Url to local list
    static var localListUrl: KeyPath<AppUrls, URL> { get }
    
    /// List data of this local list type
    static var listData: ListDataLocalListType<Self> { get }
}
