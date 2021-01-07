//
//  CallerTest.swift
//  StrafenTests
//
//  Created by Steven on 1/5/21.
//

import XCTest
import FirebaseDatabase
import CodableFirebase
@testable import Strafen

class CallerTest: XCTestCase {
    
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
                .init(clubName: name, clubIdentifier: identifier, regionCode: regionCode)
            }
            
            /// Club
            var club: Club {
                .init(id: id, name: name, identifier: identifier, regionCode: regionCode)
            }
        }
        
        /// Properties for the first test person
        struct TestPersonFirst {
            
            /// Id of the first test person
            let id = Person.ID(rawValue: UUID(uuidString: "5bf1ffda-4f69-11eb-ae93-0242ac130002")!)
            
            /// User id of the first test person
            let userId = "First Person User Id"
            
            /// Name of the first test person
            let name = PersonName(firstName: "First Person First Name", lastName: "First Person Last Name")
        }
        
        /// Properties for the test club
        let testClub = TestClub()
        
        /// Properties for the first test person
        let testPersonFirst = TestPersonFirst()
    }
    
    /// Create a test club
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        // Create test club
        // Call Item for creating test club
        let cachedProperty = SignInCache.PropertyUserIdName(userId: TestProperty.shared.testPersonFirst.userId, name: TestProperty.shared.testPersonFirst.name)
        let clubCredentials = TestProperty.shared.testClub.credentials
        let clubId = TestProperty.shared.testClub.id
        let personId = TestProperty.shared.testPersonFirst.id
        let createTestClubCallItem = NewClubCall(cachedProperties: cachedProperty, clubCredentials: clubCredentials, clubId: clubId, personId: personId)
        
        // Function call to create test club
        try await { handler in
            FunctionCaller.shared.call(createTestClubCallItem, taskStateHandler: handler)
        }
        
        // Check if club is created
        // Check properties of test club
        let clubProperties: Club? = try await { handler in
            let url = URL(string: "clubs/\(clubId)")!
            Fetcher.shared.fetchItem(from: url, handler: handler)
        }
        XCTAssertEqual(clubProperties, TestProperty.shared.testClub.club)
        
        // Check person list of test club
        let personList: [Person]? = try await { handler in
            let url = URL(string: "clubs/\(clubId)/persons")!
            Fetcher.shared.fetchList(from: url, handler: handler)
        }
        XCTAssertEqual(personList?.count, 1)
        let isEqual = personList!.first!.id == TestProperty.shared.testPersonFirst.id &&
            personList!.first!.name == TestProperty.shared.testPersonFirst.name &&
            personList!.first!.signInData?.isCashier == true &&
            personList!.first!.signInData?.userId == TestProperty.shared.testPersonFirst.userId
        XCTAssertTrue(isEqual)
        
        // Check reason list of test club
        let reasonList: [ReasonTemplate]? = try await { handler in
            let url = URL(string: "clubs/\(clubId)/reasons")!
            Fetcher.shared.fetchList(from: url, handler: handler)
        }
        XCTAssertNil(reasonList)
        
        // Check fine list of test club
        let fineList: [Fine]? = try await { handler in
            let url = URL(string: "clubs/\(clubId)/fines")!
            Fetcher.shared.fetchList(from: url, handler: handler)
        }
        XCTAssertNil(fineList)
    }
    
    /// Delete test club and all associated data
    override func tearDownWithError() throws {
     
        // Delete test club
        let clubId = TestProperty.shared.testClub.id
        let deleteClubCallItem = DeleteClubCall(clubId: clubId)
        try await { handler in
            FunctionCaller.shared.call(deleteClubCallItem, taskStateHandler: handler)
        }
        
        // Check if test club is deleted
        let club: Club? = try await { handler in
            let url = URL(string: "clubs/\(clubId)")!
            Fetcher.shared.fetchItem(from: url, handler: handler)
        }
        XCTAssertNil(club)
        
    }
    
    func testSomething() {
        print(1)
    }
}

// Extension of XCTestCase to wait for synchronous tasks
extension XCTestCase {
    
    /// Timeout for data task expired error
    fileprivate enum TimeoutError: Error {
        
        /// Data task expired error
        case dataTaskExpired
    }
    
    /// Wait for synchronous tasks
    @discardableResult fileprivate func await<ReturnValue>(timeout: TimeInterval = 60, _ handler: (@escaping (ReturnValue) -> Void) -> Void) throws -> ReturnValue {
        let expectation = self.expectation(description: "expecation")
        var result: ReturnValue?
        handler { value in
            if result == nil {
                result = value
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        guard let unwrappedResult = result else { throw TimeoutError.dataTaskExpired }
        return unwrappedResult
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
    }
    init(with id: ID, codableSelf: CodableSelf) {
        self = .init(id: id, name: codableSelf.name, identifier: codableSelf.identifier, regionCode: codableSelf.regionCode)
    }
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.identifier == rhs.identifier &&
            lhs.regionCode == rhs.regionCode
    }
}

extension Fetcher {
    fileprivate func fetchItem<Type>(from url: URL, handler completionHandler: @escaping (Type?) -> Void) where Type: FetchedItemType {
        Database.database().reference(withPath: url.path).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(), let data = snapshot.value else { return completionHandler(nil) }
            let item: Type? = decodeFetchedItem(from: data, key: snapshot.key)
            completionHandler(item)
        }
    }
    
    fileprivate func fetchList<Type>(from url: URL, handler completionHandler: @escaping ([Type]?) -> Void) where Type: FetchedItemType {
        Database.database().reference(withPath: url.path).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(), let data = snapshot.value else { return completionHandler(nil) }
            let list: [Type]? = decodeFetchedList(from: data)
            completionHandler(list)
        }
    }
    
    fileprivate func decodeFetchedItem<Type>(from data: Any, key: String) -> Type? where Type: FetchedItemType {
        let decoder = FirebaseDecoder()
        guard let item = try? decoder.decode(Type.CodableSelf.self, from: data) else { return nil }
        let id = Type.ID(rawValue: UUID(uuidString: key)!)
        return Type.init(with: id, codableSelf: item)
    }
    
    fileprivate func decodeFetchedList<Type>(from data: Any) -> [Type]? where Type: FetchedItemType {
        let decoder = FirebaseDecoder()
        let dictionary = try? decoder.decode(Dictionary<String, Type.CodableSelf>.self, from: data)
        let list = dictionary.map { dictionary in
            dictionary.map { idString, item -> Type in
                let id = Type.ID(rawValue: UUID(uuidString: idString)!)
                return Type.init(with: id, codableSelf: item)
            }
        }
        return list
    }
}

extension PersonName: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.firstName == rhs.firstName && lhs.lastName == rhs.lastName
    }
}
