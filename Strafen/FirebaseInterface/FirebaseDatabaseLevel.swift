//
//  FirebaseDatabaseLevel.swift
//  Strafen
//
//  Created by Steven on 05.05.21.
//

import Foundation

/// Level of a firebase database and function
///
/// * `regular`: for default database to change the actual database
/// * `debug`: for debug database to change only the debug database
/// * `testing`: for test database to change only the testing database
enum FirebaseDatabaseLevel: String {
    
    /// For default database to change the actual database
    case regular
    
    /// For debug database to change only the debug database
    case debug
    
    /// For test database to change only the testing database
    case testing
    
    /// Club component
    var clubComponent: String {
        switch self {
        case .regular:
            return "clubs"
        case .debug:
            return "debugClubs"
        case .testing:
            return "testableClubs"
        }
    }
    
    /// `.debug` if build configuration is DEBUG, `.regular` otherwise
    static var defaultValue: FirebaseDatabaseLevel {
        Bundle.main.isDebug ? .debug : .regular
    }
}
