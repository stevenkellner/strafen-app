//
//  Utilities.swift
//  StrafenTests
//
//  Created by Steven on 1/9/21.
//

import XCTest
import FirebaseDatabase
import CodableFirebase
import FirebaseAuth
@testable import Strafen

/// Properties for all test data
struct TestProperty {
    
    /// Shared instance for singelton
    static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    /// Properties for the test club
    struct TestClub {
        
        /// Id of the test club
        let id = Club.ID(rawValue: UUID(uuidString: "1e917710-4f69-11eb-ae93-0242ac130002")!)
        
        /// Name of the test club
        let name = "Test Club"
        
        /// Identifier of the test club
        let identifier = "test-club"
        
        /// Region code of the test club
        let regionCode = "DE"
        
        /// Credentials for the creation of the test club
        var credentials: SignInClubInput.ClubCredentials {
            .init(clubName: name, clubIdentifier: identifier, regionCode: regionCode, inAppPaymentActive: true)
        }
        
        /// Club
        var club: Club {
            .init(id: id, name: name, identifier: identifier, regionCode: regionCode, inAppPaymentActive: true)
        }
    }
    
    /// Properties for the first test person
    struct TestPersonFirst {
        
        /// Id of the first test person
        let id = Person.ID(rawValue: UUID(uuidString: "5bf1ffda-4f69-11eb-ae93-0242ac130002")!)
        
        /// User id of the first test person
        let userId = Auth.auth().currentUser!.uid
        
        /// Name of the first test person
        let name = PersonName(firstName: "First Person First Name", lastName: "First Person Last Name")
        
        /// Person
        var person: Person {
            .init(id: id, name: name, signInData: nil)
        }
    }
    
    /// Properties for the second test person
    struct TestPersonSecond {
        
        /// Id of the first test person
        let id = Person.ID(rawValue: UUID(uuidString: "3530d06e-8c79-4375-ae4c-3b9d1fdd6e28")!)
        
        /// User id of the first test person
        let userId = Auth.auth().currentUser!.uid
        
        /// Name of the first test person
        let name = PersonName(firstName: "Second Person First Name")
        
        /// Person
        var person: Person {
            .init(id: id, name: name, signInData: nil)
        }
    }
    
    /// Properties for the third test person
    struct TestPersonThird {
        
        /// Id of the first test person
        let id = Person.ID(rawValue: UUID(uuidString: "96a9c7c4-5f7b-4ea8-aac5-8ec7f0403960")!)
        
        /// User id of the first test person
        let userId = "Third_Person_User_Id"
        
        /// Name of the first test person
        let name = PersonName(firstName: "Third Person First Name", lastName: "Third Person Last Name")
        
        /// Person
        var person: Person {
            .init(id: id, name: name, signInData: nil)
        }
    }
    
    /// Properties for test reason
    struct TestReason {
        
        /// Id of the test reason
        let id = ReasonTemplate.ID(rawValue: UUID(uuidString: "9d0681f0-2045-4a1d-abbc-6bb289934ff9")!)
        
        /// Reason
        let reason = "Test Reason 1"
        
        /// Updated reason
        let updatedReason = "Test Reason 2"
        
        /// Importance
        let importance = Importance.low
        
        /// Updated importance
        let updatedImportance = Importance.medium
        
        /// Amount
        let amount = Amount(2, subUnit: 50)
        
        /// Updated amount
        let updatedAmount = Amount(10, subUnit: 99)
        
        /// Reason
        var reasonTemplate: ReasonTemplate {
            .init(id: id, reason: reason, importance: importance, amount: amount)
        }
        
        /// Updated reason
        var updatedReasonTemplate: ReasonTemplate {
            .init(id: id, reason: updatedReason, importance: updatedImportance, amount: updatedAmount)
        }
    }
    
    /// Properties for test fine
    struct TestFine {
        
        /// Id of the test fine
        let id = Fine.ID(rawValue: UUID(uuidString: "637d6187-68d2-4000-9cb8-7dfc3877d5ba")!)
        
        /// Assoiated person id
        let assoiatedPersonId = Person.ID(rawValue: UUID(uuidString: "5bf1ffda-4f69-11eb-ae93-0242ac130002")!)
        
        /// Date
        let date = Date(timeIntervalSinceReferenceDate: 9284765)
        
        /// Fine reason template
        let reasonTemplate = FineReasonTemplate(templateId: ReasonTemplate.ID(rawValue: UUID(uuidString: "9d0681f0-2045-4a1d-abbc-6bb289934ff9")!))
        
        /// Fine reason custom
        let reasonCustom = FineReasonCustom(reason: "Reason", amount: Amount(1, subUnit: 50), importance: .high)
        
        /// Fine with reason template
        var withReasonTemplate: Fine {
            .init(id: id, assoiatedPersonId: assoiatedPersonId, date: date, payed: .unpayed, number: 2, fineReason: reasonTemplate)
        }
        
        /// Fine with reason custom
        var withReasonCustom: Fine {
            .init(id: id, assoiatedPersonId: assoiatedPersonId, date: date, payed: .payed(date: Date(timeIntervalSinceReferenceDate: 234689), inApp: false), number: 10, fineReason: reasonCustom)
        }
        
        /// Fine with reason custom
        func withReasonCustom(_ payedTimeInterval: TimeInterval) -> Fine {
            .init(id: id, assoiatedPersonId: assoiatedPersonId, date: date, payed: .payed(date: Date(timeIntervalSinceReferenceDate: payedTimeInterval), inApp: false), number: 10, fineReason: reasonCustom)
        }
    }
    
    /// Propertries for the first test late payment interest
    struct TestLatePaymentInterestFirst {
        
        /// Interest free period
        let interestFreePeriod = Settings.LatePaymentInterest.TimePeriod(value: 2, unit: .day)
        
        /// Interest rate
        let interestRate = 0.05
        
        /// Interest Period
        let interestPeriod = Settings.LatePaymentInterest.TimePeriod(value: 1, unit: .month)
        
        /// Compound interest
        let compuondInterest = false
        
        /// Late payment interest
        var latePaymentInterest: Settings.LatePaymentInterest {
            .init(interestFreePeriod: interestFreePeriod, interestRate: interestRate, interestPeriod: interestPeriod, compoundInterest: compuondInterest)
        }
    }
    
    /// Propertries for the second test late payment interest
    struct TestLatePaymentInterestSecond {
        
        /// Interest free period
        let interestFreePeriod = Settings.LatePaymentInterest.TimePeriod(value: 5, unit: .month)
        
        /// Interest rate
        let interestRate = 0.25
        
        /// Interest Period
        let interestPeriod = Settings.LatePaymentInterest.TimePeriod(value: 2, unit: .year)
        
        /// Compound interest
        let compuondInterest = true
        
        /// Late payment interest
        var latePaymentInterest: Settings.LatePaymentInterest {
            .init(interestFreePeriod: interestFreePeriod, interestRate: interestRate, interestPeriod: interestPeriod, compoundInterest: compuondInterest)
        }
    }
    
    /// Properties for the test club
    let testClub = TestClub()
    
    /// Properties for the first test person
    let testPersonFirst = TestPersonFirst()
    
    /// Properties for the second test person
    let testPersonSecond = TestPersonSecond()
    
    /// Properties for the third test person
    let testPersonThird = TestPersonThird()
    
    /// Properties for reason
    let testReason = TestReason()
    
    /// Properties for test fine
    let testFine = TestFine()
    
    /// Propertries for the first test late payment interest
    let testLatePaymentInterestFirst = TestLatePaymentInterestFirst()
    
    /// Propertries for the second test late payment interest
    let testLatePaymentInterestSecond = TestLatePaymentInterestSecond()
}

// Extension of XCTestCase to wait for synchronous tasks
extension XCTestCase {
    
    /// Timeout for data task expired error
    enum TimeoutError: Error {
        
        /// Data task expired error
        case dataTaskExpired
    }
    
    /// Wait for synchronous tasks
    func awaitValue<ReturnValue>(timeout: TimeInterval = 60, _ handler: (@escaping (ReturnValue) -> Void) throws -> Void) throws -> ReturnValue {
        let expectation = self.expectation(description: "expecation")
        var result: ReturnValue?
        try handler { value in
            if result == nil {
                result = value
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        guard let unwrappedResult = result else { throw TimeoutError.dataTaskExpired }
        return unwrappedResult
    }
    
    func awaitResult<ReturnValue>(timeout: TimeInterval = 60, _ handler: (@escaping (Result<ReturnValue, Error>) -> Void) throws -> Void) throws -> ReturnValue {
        let result: Result<ReturnValue, Error> = try awaitValue(timeout: timeout, handler)
        return try result.get()
    }
    
    func awaitExistsNoData(timeout: TimeInterval = 60, _ handler: (@escaping (Any?) -> Void) throws -> Void) throws {
        let result: Any? = try awaitValue(timeout: timeout, handler)
        XCTAssertNil(result)
    }
}

protocol FetchedItemType: Identifiable where ID: ListTypeId {
    
    /// Codable list type
    associatedtype CodableSelf: Decodable
    
    /// Init with id and codable self
    init(with id: ID, codableSelf: CodableSelf)
}

extension Person: FetchedItemType {}
extension Fine: FetchedItemType {}
extension ReasonTemplate: FetchedItemType {}
extension Club: FetchedItemType, Equatable {
    struct CodableSelf: Decodable {
        let name: String
        let identifier: String
        var regionCode: String
        var inAppPaymentActive: Bool?
    }
    init(with id: ID, codableSelf: CodableSelf) {
        self = .init(id: id, name: codableSelf.name, identifier: codableSelf.identifier, regionCode: codableSelf.regionCode, inAppPaymentActive: codableSelf.inAppPaymentActive)
    }
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.identifier == rhs.identifier &&
            lhs.regionCode == rhs.regionCode &&
            lhs.isInAppPaymentActive == rhs.isInAppPaymentActive
    }
}

extension Fetcher {
    
    enum FetchError: Error {
        case noData
    }
    
    func fetchItem<Type>(from url: URL, handler completionHandler: @escaping (Result<Type, Error>) -> Void) where Type: FetchedItemType {
        Database.database().reference(withPath: url.path).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(), let data = snapshot.value else { return completionHandler(.failure(FetchError.noData)) }
            do {
                let item: Type = try decodeFetchedItem(from: data, key: snapshot.key)
                completionHandler(.success(item))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }
    
    func fetchPrmitiveItem<Type>(from url: URL, handler completionHandler: @escaping (Result<Type, Error>) -> Void) where Type: Decodable {
        Database.database().reference(withPath: url.path).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(), let data = snapshot.value else { return completionHandler(.failure(FetchError.noData)) }
            do {
                let decoder = FirebaseDecoder()
                let item = try decoder.decode(Type.self, from: data)
                completionHandler(.success(item))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }
    
    func fetchList<Type>(from url: URL, handler completionHandler: @escaping (Result<[Type], Error>) -> Void) where Type: FetchedItemType {
        Database.database().reference(withPath: url.path).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(), let data = snapshot.value else { return completionHandler(.failure(FetchError.noData)) }
            do {
                let list: [Type] = try self.decodeFetchedList(from: data)
                completionHandler(.success(list))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }
    
    func existsNoData(at url: URL, handler completionHandler: @escaping (Any?) -> Void) {
        var state: ConnectionState = .loading
        Database.database().reference(withPath: url.path).observeSingleEvent(of: .value) { snapshot in
            if state == .loading {
                state = .passed
                guard snapshot.exists() else { return completionHandler(nil) }
                completionHandler(snapshot.value)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if state == .loading {
                state = .failed
                completionHandler(nil)
            }
        }
    }
    
    func decodeFetchedItem<Type>(from data: Any, key: String) throws -> Type where Type: FetchedItemType {
        let decoder = FirebaseDecoder()
        let item = try decoder.decode(Type.CodableSelf.self, from: data)
        let id = Type.ID(rawId: key)
        return Type.init(with: id, codableSelf: item)
    }
    
    func decodeFetchedList<Type>(from data: Any) throws -> [Type] where Type: FetchedItemType {
        let decoder = FirebaseDecoder()
        let dictionary = try decoder.decode(Dictionary<String, Type.CodableSelf>.self, from: data)
        let list = dictionary.map { idString, item -> Type in
            let id = Type.ID(rawId: idString)
            return Type.init(with: id, codableSelf: item)
        }
        return list
    }
}

extension PersonName: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.firstName == rhs.firstName && lhs.lastName == rhs.lastName
    }
}

extension FunctionCaller {
    func call<CallType>(_ item: CallType, errorHandler: @escaping (Error?) -> Void) where CallType: FunctionCallable {
        call(item) { _ in
            errorHandler(nil)
        } failedHandler: { error in
            errorHandler(error)
        }
    }
}

extension ReasonTemplate: Equatable {
    public static func ==(lhs: ReasonTemplate, rhs: ReasonTemplate) -> Bool {
        lhs.id == rhs.id &&
            lhs.reason == rhs.reason &&
            lhs.importance == rhs.importance &&
            lhs.amount == rhs.amount
    }
}

extension Fine: Equatable {
    public static func ==(lhs: Fine, rhs: Fine) -> Bool {
        guard lhs.id == rhs.id &&
            lhs.assoiatedPersonId == rhs.assoiatedPersonId &&
            lhs.date == rhs.date &&
            lhs.payed == rhs.payed &&
            lhs.number == rhs.number else { return false }
        if let lhsReason = lhs.fineReason as? FineReasonTemplate,
           let rhsReason = rhs.fineReason as? FineReasonTemplate,
           lhsReason == rhsReason { return true }
        if let lhsReason = lhs.fineReason as? FineReasonCustom,
           let rhsReason = rhs.fineReason as? FineReasonCustom,
           lhsReason == rhsReason { return true }
        return false
    }
}
