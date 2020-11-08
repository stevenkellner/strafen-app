//
//  Parameters.swift
//  Strafen
//
//  Created by Steven on 9/18/20.
//

import Foundation

/// Parameters
struct Parameters {
    
    /// Parameters
    private var parameters: [String : Any]
    
    init(_ parameters: [String : Any] = [:], _ adding: ((inout [String : Any]) -> Void)? = nil) {
        self.parameters = parameters
        self.parameters["key"] = AppUrls.shared.key
        if let adding = adding {
            adding(&self.parameters)
        }
    }
    
    /// Add single value
    mutating func add(_ value: Any, for key: String) {
        parameters[key] = value
    }
    
    /// Add more values
    mutating func add(_ moreParameters: [String : Any]) {
        parameters.merge(moreParameters) { firstValue, _ in firstValue}
    }
    
    /// Parameters data for POST method
    fileprivate var data: Data? {
        parameters.percentEncoded
    }
    
    /// Encoded for image
    func encodedForImage(boundaryId: UUID) -> Data {
        parameters.encodedForImage(boundaryId: boundaryId)
    }
}


/// Have parameters
protocol Parameterable {
    
    /// Parameters
    var parameters: Parameters { get }
}

// Extension of Changeable for default body with parameters
extension Changeable where Self: Parameterable {
    
    /// http body
    var body: Data? {
        parameters.data
    }
}
