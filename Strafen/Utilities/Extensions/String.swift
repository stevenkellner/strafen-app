//
//  String.swift
//  Strafen
//
//  Created by Steven on 16.07.20.
//

import Foundation

// Extension of String to validate if string is an email
extension String {
    
    /// Check if string is valid emial
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
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

// Extension of String for formatted as an Amount value
extension String {
    
    /// Formatted as an Amount value
    var amountValue: Amount {
        
        var commaPassed = false
        var newString = ""
        
        // Filter all invalid characters out
        let validCharacters = (0..<10).map({ Character(String($0)) }).appending(",")
        for char in self where validCharacters.contains(char) {
            if char == "," && commaPassed {
                continue
            } else if char == "," && !commaPassed {
                commaPassed = true
            }
            newString.append(char)
        }
        
        // No subunit value
        if !commaPassed && !newString.isEmpty {
            guard let value = Int(newString) else { return .zero }
            return Amount(value, subUnit: .zero)
        }
        
        // With subunit value
        if commaPassed && newString.count != 1 {
            
            // Get value and subunit value
            var componentsIterator = newString.components(separatedBy: ",").makeIterator()
            guard let valueString = componentsIterator.next(),
                  let value = valueString.isEmpty ? .zero : Int(valueString),
                  let subUnitString = componentsIterator.next() else { return .zero }
            
            // Empty subunit string
            if subUnitString.isEmpty { return Amount(value, subUnit: .zero) }
            
            // Only decimal digit
            if subUnitString.count == 1 {
                guard let subUnitValue = Int(subUnitString) else { return .zero }
                return Amount(value, subUnit: subUnitValue * 10)
                
            }
                
            // Both digits
            if subUnitString.count == 2 {
                guard let subUnitValue = Int(subUnitString) else { return .zero }
                return Amount(value, subUnit: subUnitValue)
            }
            
            // More than two digit
            var subUnitIterator = subUnitString.makeIterator()
            guard let tenthCharacter = subUnitIterator.next(),
                  let hundredthCharacter = subUnitIterator.next(),
                  let thousandthCharacter = subUnitIterator.next(),
                  let tenth = Int(String(tenthCharacter)),
                  let hundredth = Int(String(hundredthCharacter)),
                  let thousandth = Int(String(thousandthCharacter))
                  else { return .zero }
            let decimal = tenth * 10 + hundredth
            if thousandth >= 5 {
                if decimal == 99 {
                    return Amount(value + 1, subUnit: .zero)
                }
                return Amount(value, subUnit: decimal + 1)
            }
            return Amount(value, subUnit: decimal)
            
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

extension String {
    init?(data: Data?, encoding: Encoding) {
        guard let data = data else { return nil }
        self.init(data: data, encoding: encoding)
    }
}
