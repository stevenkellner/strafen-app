//
//  Payment.swift
//  Strafen
//
//  Created by Steven on 3/5/21.
//

import SwiftUI
import Braintree


/// Used to pay with Braintree
class Payment {
    
    struct ReturnResult<Result>: Decodable where Result: Decodable {
        let result: Result
    }
    
    var dataCollector: BTDataCollector? = nil
    
    /// Shared instance for singelton
    static let shared = Payment()
    
    /// Private init for singleton
    private init() {}
    
    func setup(){
        fetchClientToken { [weak self] token in
            guard let token = token, let apiClient = BTAPIClient(authorization: token) else { return }
            self?.dataCollector = BTDataCollector(apiClient: apiClient)
        }
    }
    
    func callServer<Result>(name: String, parameters: [String: String]? = nil, handler completionHandler: @escaping (Result?) -> Void) where Result: Decodable {
        guard let privateKey = Bundle.keysPropertyList.privatePaymentKey as? String else { return completionHandler(nil) }
        let url = URL(string: "https://strafen-app.ew.r.appspot.com/" + name)!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("text/plain", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        var parameters = parameters ?? [:]
        parameters["privateKey"] = privateKey
        request.httpBody = try! JSONEncoder().encode(parameters)
        URLSession.shared.dataTask(with: request) { data, _, error in
            let decoder = JSONDecoder()
            guard error == nil,
                  let data = data,
                  let result = try? decoder.decode(ReturnResult<Result>.self, from: data).result else { return completionHandler(nil) }
            completionHandler(result)
        }.resume()
    }
    
    /// Fetches client token for payment
    @inlinable func fetchClientToken(handler completionHandler: @escaping (String?) -> Void) {
        callServer(name: "client_token", handler: completionHandler)
    }
    
    func checkout(nonce: String, amount: Amount, fineIds: [Fine.ID], handler completionHandler: @escaping (CheckoutResult?) -> Void) {
        dataCollector?.collectDeviceData { deviceData in
            let parameters = [
                "paymentMethodNonce": nonce,
                "amount": amount.forPayment,
                "deviceData": deviceData,
                "clubId": "das_ist_ein_test",
                "fineIds": "[" + fineIds.map { "\"" + $0.uuidString + "\"" }.joined(separator: ", ") + "]"
            ]
            self.callServer(name: "checkout", parameters: parameters, handler: completionHandler)
        }
    }
    
    var readyForPayment: Bool {
        dataCollector != nil
    }
    
    struct CheckoutResult: Decodable {
        struct Transaction: Decodable {
//            struct CreditCard: Decodable {
//                let bin: String
//                let last4: String
//                let cardType: String
//                let maskedNumber: String
//            }
            struct CustomFields: Decodable {
                enum CodingKeys: String, CodingKey {
                    case clubId
                    case _fineIds = "fineIds"
                }
                let clubId: String
                private let _fineIds: String
                var fineIds: [Fine.ID] {
                    try! JSONDecoder().decode([Fine.ID].self, from: _fineIds.data(using: .utf8)!)
                }
            }
            let id: String
//            let status: String
//            let currencyIsoCode: String
//            let amount: String
            let customFields: CustomFields
//            let cvvResponseCode: String
//            let creditCard: CreditCard
//            let paymentInstrumentType: String
        }
        let transaction: Transaction
        let success: Bool
    }
}
