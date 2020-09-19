//
//  SendCodeMailChange.swift
//  Strafen
//
//  Created by Steven on 9/19/20.
//

import Foundation

/// Send code mail change
struct SendCodeMailChange: Changeable, Parameterable {
    
    /// Email address
    let address: String
    
    /// Path from AppUrls to changer url
    var urlPath: KeyPath<AppUrls, URL> = \.changer.mailCode
    
    /// Parameters
    var parameters: Parameters {
        Parameters { parameters in
            parameters["code"] = ConfirmCode.shared.code
            parameters["email"] = address
        }
    }
}

/// Code send per email to confirm email-address
struct ConfirmCode {
    
    /// Shared instance for singelton
    static var shared = Self()
    
    /// Private init for singleton
    private init() {
        code = ConfirmCode.generatedCode
    }
    
    /// Confirm code
    var code: String
    
    /// Generate new code
    mutating func generateCode() {
        code = ConfirmCode.generatedCode
    }
    
    /// Generated code
    private static var generatedCode: String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<8).map{ _ in letters.randomElement()! })
    }
}
