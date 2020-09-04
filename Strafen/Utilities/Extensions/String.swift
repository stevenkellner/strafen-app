//
//  String.swift
//  Strafen
//
//  Created by Steven on 16.07.20.
//

import CryptoSwift

// Extension of String to validate if string is an email
extension String {
    
    /// Check if string is valid emial
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}

// Extension of String to de- / encrypt it
extension String {
    
    /// Encrypted String with base 64 cipher
    var encrypted: String {
        let base64cipher = try! Rabbit(key: AppUrls.shared.cipherKey)
        return try! encryptToBase64(cipher: base64cipher)!
    }
    
    /// Encrypted String with base 64 cipher
    ///
    /// nil if error in decrypting
    var decrypted: String? {
        let base64cipher = try! Rabbit(key: AppUrls.shared.cipherKey)
        return try? decryptBase64ToString(cipher: base64cipher)
    }
}

// Extension of String to check if this String contains a substring
extension String {
    
    /// Checks if this string contains a substring
    func hasSubstring(_ substring: String) -> Bool {
        let stringToTest = filter({ !$0.isWhitespace }).lowercased()
        let substring = substring.filter({ !$0.isWhitespace }).lowercased()
        return stringToTest.contains(substring)
    }
    
    /// Checks if seachText is empty or this string contains the searchText
    func searchFor(_ searchText: String) -> Bool {
        searchText == "" || hasSubstring(searchText)
    }
}

// Extension of String for formatted as an Euro value
extension String {
    
    /// Formatted as an Euro value
    var euroValue: Euro {
        
        var commaPassed = false
        var newString = ""
        
        // Filter all invalid characters out
        let validCharacters = Array(0..<11).map({ $0 != 10 ? Character(String($0)) : "," })
        for char in self where validCharacters.contains(char) {
            if char == "," && commaPassed {
                continue
            } else if char == "," && !commaPassed {
                commaPassed = true
            }
            newString.append(char)
        }
        
        // No cent value
        if !commaPassed && !newString.isEmpty { return Euro(euro: UInt(newString)!, cent: .zero)  }
        
        // With cent value
        if commaPassed && newString.count != 1 {
            
            // Get euro and cent value
            let components = newString.components(separatedBy: ",")
            let euro = components.first!.isEmpty ? .zero : UInt(components.first!)!
            let centString = components[1]
            
            // Empty cent string
            if centString.isEmpty { return Euro(euro: euro, cent: .zero) }
                
            // Only decimal digit
            if centString.count == 1 { return Euro(euro: euro, cent: UInt(centString)! * 10) }
                
            // Both digits
            if centString.count == 2 { return Euro(euro: euro, cent: UInt(centString)!) }
                
            // More than two digit
            let decimal = UInt(String(centString.first!))! * 10 + UInt(String(centString[centString.index(after: centString.startIndex)]))!
            if Int(String(centString[centString.index(after: centString.index(after: centString.startIndex))]))! >= 5 {
                if decimal == 99 {
                    return Euro(euro: euro + 1, cent: .zero)
                }
                return Euro(euro: euro, cent: decimal + 1)
            }
            return Euro(euro: euro, cent: decimal)
            
        }
        
        // Empty string or only comma
        return .zero
    }
}

// Extension of String for formatted as a positive integer
extension String {
    
    /// Formatted as a positive integer
    var positiveInt: Int {
        var newString = ""
        
        // Filter all invalid characters out
        let validCharacters = Array(0..<11).map({ $0 != 10 ? Character(String($0)) : "," })
        for char in self where validCharacters.contains(char) {
            if char == "," {
                break
            }
            newString.append(char)
        }
        return Int(newString) ?? .zero
    }
}

// Extension of String for formatted as interest rate
extension String {
    
    /// Formatted as interest rate
    var interestRateValue: Double {
        
        var commaPassed = false
        var newString = ""
        
        // Filter all invalid characters out
        let validCharacters = Array(0..<11).map({ $0 != 10 ? Character(String($0)) : "," })
        for char in self where validCharacters.contains(char) {
            if char == "," {
                if !commaPassed {
                    commaPassed = true
                    newString.append(".")
                }
                continue
            }
            newString.append(char)
        }
        
        return min(Double(newString) ?? .zero, 100)
    }
}
