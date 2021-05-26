//
//  FunctionCaller.swift
//  Strafen
//
//  Created by Steven on 11/8/20.
//

import FirebaseFunctions
import CodableFirebase

/// Calls firebase functions
struct FunctionCaller {
    
    /// Shared instance for singelton
    static var shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    public var forTesting = false
    
    /// Call errors
    enum CallErrors: Error {
        
        /// Could find private key for function call
        case noPrivateKey
    }
    
    /// Change given item on server and local
    func call<CallType>(_ item: CallType, passedHandler: @escaping (HTTPSCallableResult) -> Void, failedHandler: @escaping (Error) -> Void) where CallType: FunctionCallable {
        guard let privateKey = Bundle.keysPropertyList.privateFirebaseFunctionCallerKey as? String else { return failedHandler(CallErrors.noPrivateKey) }
        var parameters = item.parameters
        parameters.add(privateKey, for: "privateKey")
        parameters.add(forTesting ? "testing" : Bundle.main.firebaseDebugEnabled ? "debug" : "regular", for: "clubLevel")
        Functions.functions(region: "europe-west1").httpsCallable(item.functionName).call(parameters.parameterableObject) { result, error in
            if let result = result {
                item.successHandler()
                passedHandler(result)
            } else if let error = error {
                item.failedHandler()
                failedHandler(error)
            } else {
                fatalError("Function call returns no result and no error.")
            }
        }
    }
    
    /// Change given item on server and local
    func call<CallType>(_ item: CallType, passedHandler: @escaping (CallType.CallResult) -> Void, failedHandler: @escaping (Error) -> Void) where CallType: FunctionCallable & FunctionCallResult {
        call(item) { (result: HTTPSCallableResult) in
            let decoder = FirebaseDecoder()
            do {
                let decodedResult = try decoder.decode(CallType.CallResult.self, from: result.data)
                passedHandler(decodedResult)
            } catch {
                failedHandler(error)
            }
        } failedHandler: { error in
            failedHandler(error)
        }
    }
    
    /// Change given item on server and local
    func call<CallType>(_ item: CallType, taskStateHandler: @escaping (TaskState) -> Void) where CallType: FunctionCallable {
        call(item) { _ in
            taskStateHandler(.passed)
        } failedHandler: { _ in
            taskStateHandler(.failed)
        }
    }
}
