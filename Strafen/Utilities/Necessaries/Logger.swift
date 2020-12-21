//
//  Logger.swift
//  Strafen
//
//  Created by Steven on 12/17/20.
//

import Foundation
import OSLog

/// Used to log messages
struct Logging {
    
    /// Shared instance for singelton
    static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    let logLevelHigherEqual: OSLogType = .default
    
    /// Logges a message with given logging level
    func log(with level: OSLogType, _ messages: String..., file: String = #fileID, function: String = #function, line: Int = #line) {
//        guard level.rawValue >= logLevelHigherEqual.rawValue else { return }
//        let logger = Logger(subsystem: "Strafen-App", category: "File: \(file), in Function: \(function), at Line: \(line)")
//        let message = messages.joined(separator: "\n\t")
//        logger.log(level: level, "\(level.levelName.uppercased(), privacy: .public) | \(message, privacy: .public)")
    }
}

extension OSLogType {
    var levelName: String {
        switch self {
        case .default:
            return "(Default)"
        case .info:
            return "(Info)   "
        case .debug:
            return "(Debug)  "
        case .error:
            return "(Error)  "
        case .fault:
            return "(Fault)  "
        default:
            return "(Unknown)"
        }
    }
}
