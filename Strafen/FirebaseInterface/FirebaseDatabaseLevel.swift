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
}
