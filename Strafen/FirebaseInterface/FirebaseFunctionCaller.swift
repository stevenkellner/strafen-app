//
//  FirebaseFunctionCaller.swift
//  Strafen
//
//  Created by Steven on 05.05.21.
//

import FirebaseFunctions

/// Used to call firebase functions
@MainActor struct FirebaseFunctionCaller {

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
    /// - Returns: Result of the function call
    @discardableResult func call<CallType>(_ item: CallType) async throws -> HTTPSCallableResult where CallType: FFCallable {
        guard let privateKey = Bundle.keysPropertyList.privateFirebaseFunctionCallerKey as? String else { throw CallError.noPrivateKey }
        let parameters = FirebaseCallParameterSet(item.parameters) { parameters in
            parameters.setValue(privateKey, forKey: "privateKey")
            parameters.setValue(level.rawValue, forKey: "clubLevel")
        }
        return try await Functions.functions(region: "europe-west1").httpsCallable(item.functionName).call(parameters.primordialParameter)
    }

    /// Calls a firebase function with given callable item
    /// - Parameters:
    ///   - item: callable item for firebase function call
    /// - Returns: Decoded result of the function call
    func call<CallType>(_ item: CallType) async throws -> CallType.CallResult where CallType: FFCallable & FFCallResult {
        let result: HTTPSCallableResult = try await call(item)
        return try FirebaseDecoder.shared.decodeOrThrow(CallType.CallResult.self, result.data)
    }
}
