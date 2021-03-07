//
//  Payment.swift
//  Strafen
//
//  Created by Steven on 3/5/21.
//

import SwiftUI
import Braintree
import BraintreeDropIn


/// Used to pay with Braintree
class Payment {
    
    var dataCollector: BTDataCollector? = nil
    
    /// Shared instance for singelton
    static let shared = Payment()
    
    /// Private init for singleton
    private init() {
        fetchClientToken { [weak self] token in
            guard let token = token, let apiClient = BTAPIClient(authorization: token) else { return }
            self?.dataCollector = BTDataCollector(apiClient: apiClient)
        }
    }
    
    /// Fetches client token for payment
    func fetchClientToken(handler completionHandler: @escaping (String?) -> Void) {
        let url = URL(string: "https://strafen-app.ew.r.appspot.com/client_token")!
        var request = URLRequest(url: url)
        request.setValue("text/plain", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, let token = String(data: data, encoding: .utf8), error == nil else { return completionHandler(nil) }
            completionHandler(token)
        }.resume()
    }
    
    func checkout(nonce: String) {
        dataCollector?.collectCardFraudData { deviceData in
            let url = URL(string: "https://strafen-app.ew.r.appspot.com/checkout")!
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = try! JSONEncoder().encode([
                "paymentMethodNonce": nonce,
                "amount": "10.00",
                "deviceData": deviceData
            ])
            URLSession.shared.dataTask(with: request) { data, response, error in
                let text = String(data: data, encoding: .utf8)
                print(text)
                print(data)
                print(response)
                print(error)
            }.resume()
        }
    }
    
    var readyForPayment: Bool {
        dataCollector != nil
    }
}

/// Braintree Drop in view controller
struct BraintreeDropIn: UIViewControllerRepresentable {
    
    /// Controller
    let controller: BTDropInController
    
    init?(clientToken: String, handler resultHandler: @escaping (BTDropInResult?) -> Void) {
        let request = BTDropInRequest()
        let controller = BTDropInController(authorization: clientToken, request: request) { _, result, error in
            guard let result = result, !result.isCancelled, error == nil else { return resultHandler(nil) }
            resultHandler(result)
        }
        guard let controller = controller else { return nil }
        self.controller = controller
    }
    
    /// make view
    func makeUIViewController(context: Context) -> BTDropInController { controller }
    
    /// update view
    func updateUIViewController(_ uiViewController: BTDropInController, context: Context) {}
}
