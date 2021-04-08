//
//  SaveCreditCardCall.swift
//  Strafen
//
//  Created by Steven on 3/16/21.
//

import Foundation

/// Used to save credit card in the database
struct SaveCreditCardCall: FunctionCallable {
    
    /// Club id
    let clubId: Club.ID
    
    /// Person id
    let personId: Person.ID
    
    /// Informations
    let information: String
    
    /// Function name
    let functionName: String = "saveCreditCard"
    
    /// Parameters
    var parameters: Parameters {
        Parameters { parameters in
            parameters["clubId"] = clubId
            parameters["personId"] = personId
            parameters["information"] = information
        }
    }
}

struct CreditCardInformation: Codable {
    
    let firstName: String?
    
    let lastName: String?
    
    let cardNumber: String
    
    let expirationDate: String
    
    let cvv: String
    
    var formattedName: String? {
        switch (firstName, lastName) {
        case (nil, nil): return nil
        case (let firstName, nil): return firstName
        case (nil, let lastName): return lastName
        case (let firstName, let lastName): return "\(firstName!) \(lastName!)"
        }
    }
    
    var maskedCardNumber: String {
        var cardNumber = cardNumber
        var index = 0
        var unmaskedNumbers = ""
        while index < 4, let char = cardNumber.popLast() {
            unmaskedNumbers.append(char)
            if char != " " { index += 1 }
        }
        cardNumber = String(cardNumber.map { $0 == " " ? " " : "X" })
        return cardNumber + unmaskedNumbers
    }
}

extension CreditCardInformation {
    init?(encrypted encryptedByteList: Array<UInt8>) {
        guard let byteList = encryptedByteList.decrypted else { return nil }
        let decoder = JSONDecoder()
        guard let information = try? decoder.decode(Self.self, from: Data(byteList)) else { return nil }
        self = information
    }
    
    var encrypted: Array<UInt8>? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else { return nil }
        return [UInt8](data).encrypted
    }
}
