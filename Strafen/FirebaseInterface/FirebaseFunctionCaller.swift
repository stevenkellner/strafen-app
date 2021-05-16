//
//  FirebaseFunctionCaller.swift
//  Strafen
//
//  Created by Steven on 05.05.21.
//

import FirebaseFunctions
import Hydra

/// Used to call firebase functions
struct FirebaseFunctionCaller {
    
    /// Level of a firebase function call
    public var level: FirebaseDatabaseLevel = .defaultValue
    
    /// Shared instance for singelton
    static var shared = FirebaseFunctionCaller()
    
    /// Private init for singleton
    private init() {}
    
    /// An error that occurs during calling function
    enum CallError: Error {
        
        /// Couldn't find private key for function call
        case noPrivateKey
    }
    
    /// Calls a firebase function with given callable item
    /// - Parameters:
    ///   - item: callable item for firebase function call
    /// - Returns: Promise of HTTPS call result
    func call<CallType>(_ item: CallType) -> Promise<HTTPSCallableResult> where CallType: FirebaseFunctionCallable {
        Promise<HTTPSCallableResult>(in: .main) { resolve, reject, _ in
            guard let privateKey = Bundle.keysPropertyList.privateFirebaseFunctionCallerKey as? String else { throw CallError.noPrivateKey }
            let parameters = FirebaseCallParameterSet(item.parameters) { parameters in
                parameters["privateKey"] = privateKey
                parameters["clubLevel"] = level.rawValue
            }
            Functions.functions(region: "europe-west1").httpsCallable(item.functionName).call(parameters.primordialParameter) { result, error in
                if let result = result {
                    item.successHandler()
                    resolve(result)
                } else if let error = error {
                    item.failedHandler()
                    reject(error)
                }
            }
        }
    }
    
    /// Calls a firebase function with given callable item
    /// - Parameters:
    ///   - item: callable item for firebase function call
    /// - Returns: Promise of decoded call result
    func call<CallType>(_ item: CallType) -> Promise<CallType.CallResult> where CallType: FirebaseFunctionCallable & FirebaseFunctionCallResult {
        call(item).then { (result: HTTPSCallableResult) in
            try FirebaseDecoder.shared.decodeOrThrow(CallType.CallResult.self, result.data)
        }
    }
}
