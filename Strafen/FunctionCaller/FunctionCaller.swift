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
    static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    /// Change given item on server and local
    func call(_ item: FunctionCallable, passedHandler: @escaping (HTTPSCallableResult) -> Void, failedHandler: @escaping (Error) -> Void) {
        Functions.functions(region: "europe-west1").httpsCallable(item.functionName).call(item.parameters.parameterableObject) { result, error in
            if let result = result {
                passedHandler(result)
            } else if let error = error {
                failedHandler(error)
            } else {
                fatalError("Function call returns no result and no error.")
            }
        }
    }
    
    /// Change given item on server and local
    func call<CallType>(_ item: CallType, passedHandler: @escaping (CallType.CallResult) -> Void, failedHandler: @escaping (Error) -> Void) where CallType: FunctionCallable & FunctionCallResult {
        call(item) { result in
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
    func call(_ item: FunctionCallable, taskStateHandler: @escaping (TaskState) -> Void) {
        call(item) { _ in
            taskStateHandler(.passed)
        } failedHandler: { _ in
            taskStateHandler(.failed)
        }
    }
}
