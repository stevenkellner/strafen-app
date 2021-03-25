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
        if Bundle.main.firebaseDebugEnabled {
            parameters["debug"] = "true"
        }
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
            guard let clubId = Settings.shared.person?.clubProperties.id else { return completionHandler(nil) }
            let parameters = [
                "paymentMethodNonce": nonce,
                "amount": amount.forPayment,
                "deviceData": deviceData,
                "clubId": clubId.uuidString,
                "fineIds": "[" + fineIds.map { "\"" + $0.uuidString + "\"" }.joined(separator: ", ") + "]"
            ].compactMapValues { $0 }
            self.callServer(name: "checkout", parameters: parameters, handler: completionHandler)
        }
    }
    
    func checkTransactions() {
        guard let clubId = Settings.shared.person?.clubProperties.id else { return }
        let callItem = CheckTransactionsCall(clubId: clubId)
        FunctionCaller.shared.call(callItem) { _ in }
    }
    
    func getTransaction(transactionId: String, handler completionHandler: @escaping (PaymentTransaction?) -> Void) {
        callServer(name: "get_transaction", parameters: ["transactionId": transactionId], handler: completionHandler)
    }
    
    func allTransactions(clubId: Club.ID, handler completionHandler: @escaping ([PaymentTransaction]?) -> Void) {
        callServer(name: "all_transactions", parameters: ["clubId": clubId.uuidString], handler: completionHandler)
    }
    
    var readyForPayment: Bool {
        dataCollector != nil
    }
    
    struct CheckoutResult: Decodable {
        let transaction: PaymentTransaction
        let success: Bool
    }
}
