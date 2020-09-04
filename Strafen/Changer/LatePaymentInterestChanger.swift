//
//  LatePaymentInterestChanger.swift
//  Strafen
//
//  Created by Steven on 9/4/20.
//

import Foundation

/// Used to change late payment interest
struct LatePaymentInterestChanger {
    
    /// Shared instance for singelton
    static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    /// Change late payment interest
    func change(_ latePaymentInterest: Settings.LatePaymentInterest?, completionHandler: @escaping (TaskState) -> ()) {
        
        // Get POST parameters
        var parameters: [String : Any] = [
            "key": AppUrls.shared.key,
            "clubId": Settings.shared.person!.clubId.uuidString
        ]
        if let latePaymentInterest = latePaymentInterest {
            parameters.merge(latePaymentInterest.parameters) { firstValue, _ in firstValue }
        }
        
        // Url Request
        var request = URLRequest(url: AppUrls.shared.changer.latePaymentInterest)
        request.setValue("Basic \(AppUrls.shared.loginString)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = parameters.percentEncoded
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        // Execute dataTask
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else { return completionHandler(.failed) }
            completionHandler(String(data: data, encoding: .utf8) ?? "" == "success" ? .passed : .failed)
        }.resume()
    }
}
