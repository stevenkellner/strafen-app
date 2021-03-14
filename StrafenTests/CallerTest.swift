//
//  CallerTest.swift
//  StrafenTests
//
//  Created by Steven on 1/5/21.
//

import XCTest
import FirebaseStorage
import FirebaseFunctions
@testable import Strafen

/// Test all functions of FunctionCaller
class CallerTest: XCTestCase {
    
    // MARK: set up
    /// Create a test club
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        // Create test club
        try _setUpCreateClub()
        
        // Check if club is created
        try _setUpCheckClubPropertries()
        try _setUpCheckPersonList()
        try _setUpCheckReasonList()
        try _setUpCheckFineList()
        
    }
    
    /// Create test club
    private func _setUpCreateClub() throws {
        
        // Call Item for creating test club
        let cachedProperty = SignInCache.PropertyUserIdName(userId: TestProperty.shared.testPersonFirst.userId, name: TestProperty.shared.testPersonFirst.name)
        let clubCredentials = TestProperty.shared.testClub.credentials
        let clubId = TestProperty.shared.testClub.id
        let personId = TestProperty.shared.testPersonFirst.id
        let callItem = NewClubCall(cachedProperties: cachedProperty, clubCredentials: clubCredentials, clubId: clubId, personId: personId)
        
        // Function call to create test club
        let error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        XCTAssertNil(error)
    }
    
    /// Check properties of test club
    private func _setUpCheckClubPropertries() throws {
        let clubId = TestProperty.shared.testClub.id
        let clubProperties: Club = try awaitResult { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)")!
            Fetcher.shared.fetchItem(from: url, handler: handler)
        }
        XCTAssertEqual(clubProperties, TestProperty.shared.testClub.club)
    }
    
    /// Check person list of test club
    private func _setUpCheckPersonList() throws {
        let clubId = TestProperty.shared.testClub.id
        let personList: [Person] = try awaitResult { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/persons")!
            Fetcher.shared.fetchList(from: url, handler: handler)
        }
        XCTAssertEqual(personList.count, 1)
        XCTAssertEqual(personList.first!.id, TestProperty.shared.testPersonFirst.id)
        XCTAssertEqual(personList.first!.name, TestProperty.shared.testPersonFirst.name)
        XCTAssertEqual(personList.first!.signInData?.isCashier, true)
        XCTAssertEqual(personList.first!.signInData?.userId, TestProperty.shared.testPersonFirst.userId)
    }
    
    /// Check reason list of test club
    private func _setUpCheckReasonList() throws {
        let clubId = TestProperty.shared.testClub.id
        try awaitExistsNoData { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/reasons")!
            Fetcher.shared.existsNoData(at: url, handler: handler)
        }
    }
        
    /// Check fine list of test club
    private func _setUpCheckFineList() throws {
        let clubId = TestProperty.shared.testClub.id
        try awaitExistsNoData { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/fines")!
            Fetcher.shared.existsNoData(at: url, handler: handler)
        }
    }
        
    // MARK: tear down
    /// Delete test club and all associated data
    override func tearDownWithError() throws {
        
        // Delete test club
        try _tearDownDeleteClub()
        
        // Check if test club is deleted
        try _tearDownCheckClub()
        
        // Check if club image is deleted
        try _tearDownCheckClubImage()
        
    }
    
    /// Delete test club
    private func _tearDownDeleteClub() throws {
        let clubId = TestProperty.shared.testClub.id
        let callItem = DeleteClubCall(clubId: clubId)
        let error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        XCTAssertNil(error)
    }
    
    /// Check if test club is deleted
    private func _tearDownCheckClub() throws {
        let clubId = TestProperty.shared.testClub.id
        try awaitExistsNoData { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)")!
            Fetcher.shared.existsNoData(at: url, handler: handler)
        }
    }
    
    /// Check if club image is deleted
    private func _tearDownCheckClubImage() throws {
        let clubId = TestProperty.shared.testClub.id
        let imageExists: Bool = try awaitValue { handler in
            let imageUrl = URL.clubImage(with: clubId.uuidString)
            Storage.storage(url: ImageStorage.shared.storageBucketUrl).reference(withPath: imageUrl.path).downloadURL { _, error in
                guard let error = error as NSError?, error.domain == StorageErrorDomain else { return handler(true) }
                let errorCode = StorageErrorCode(rawValue: error.code)
                handler(errorCode != .objectNotFound)
            }
        }
        XCTAssertFalse(imageExists)
    }
}

// MARK: new club call
/// Test all functions of NewClubCall
extension CallerTest {
    
    /// Test new club call
    func testNewClubCall() throws {
        
        // Check identifier, name and region code of test club
        try _testNewClubCallCheckIdentiferNameRegionCode()
        
        // Create new club with already existing identifier
        try _testNewClubCallExistingIdentifier()
        
        // Create new club with same id but different identifier
        try _testNewClubCallSameId()
        
        // Delete club and check if it's deleted
        try _testNewClubCallDeleteClub()
        
        // Create club with person with only first name
        try _testNewClubCallPersonName()
    }
    
    /// Check identifier, name and region code of test club
    private func _testNewClubCallCheckIdentiferNameRegionCode() throws {
        let clubId = TestProperty.shared.testClub.id
        
        // Check identifier
        let identifier: String = try awaitResult { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/identifier")!
            Fetcher.shared.fetchPrmitiveItem(from: url, handler: handler)
        }
        XCTAssertEqual(identifier, TestProperty.shared.testClub.identifier)
        
        // Check name
        let name: String = try awaitResult { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/name")!
            Fetcher.shared.fetchPrmitiveItem(from: url, handler: handler)
        }
        XCTAssertEqual(name, TestProperty.shared.testClub.name)
        
        // Check region code
        let regionCode: String = try awaitResult { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/regionCode")!
            Fetcher.shared.fetchPrmitiveItem(from: url, handler: handler)
        }
        XCTAssertEqual(regionCode, TestProperty.shared.testClub.regionCode)
    }
    
    /// Create new club with already existing identifier
    private func _testNewClubCallExistingIdentifier() throws {
        
        // Call item
        let clubId = TestProperty.shared.testClub.id
        let cachedProperty = SignInCache.PropertyUserIdName(userId: TestProperty.shared.testPersonFirst.userId, name: TestProperty.shared.testPersonFirst.name)
        let clubCredentials = TestProperty.shared.testClub.credentials
        let personId = TestProperty.shared.testPersonFirst.id
        let callItem = NewClubCall(cachedProperties: cachedProperty, clubCredentials: clubCredentials, clubId: clubId, personId: personId)
        
        // Call function
        let errorCode: FunctionsErrorCode? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem) { _ in
                handler(nil)
            } failedHandler: { error in
                guard let error = error as NSError?, error.domain == FunctionsErrorDomain else { return handler(nil) }
                let errorCode = FunctionsErrorCode(rawValue: error.code)
                handler(errorCode)
            }
        }
        XCTAssertEqual(errorCode, .alreadyExists)
    }
    
    /// Create new club with same id but different identifier
    private func _testNewClubCallSameId() throws {
        
        // Call item
        let clubId = TestProperty.shared.testClub.id
        let cachedProperty = SignInCache.PropertyUserIdName(userId: TestProperty.shared.testPersonFirst.userId, name: TestProperty.shared.testPersonFirst.name)
        var clubCredentials = TestProperty.shared.testClub.credentials
        clubCredentials.clubIdentifier = "different identifier"
        let personId = TestProperty.shared.testPersonFirst.id
        let callItem = NewClubCall(cachedProperties: cachedProperty, clubCredentials: clubCredentials, clubId: clubId, personId: personId)
        
        // Call function
        let error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        XCTAssertNil(error)
        let identifierAfterSameId: String = try awaitResult { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/identifier")!
            Fetcher.shared.fetchPrmitiveItem(from: url, handler: handler)
        }
        XCTAssertEqual(identifierAfterSameId, TestProperty.shared.testClub.identifier)
    }
    
    /// Delete club and check if it's deleted
    private func _testNewClubCallDeleteClub() throws {
        let clubId = TestProperty.shared.testClub.id
        let callItem = DeleteClubCall(clubId: clubId)
        let error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        XCTAssertNil(error)
        try awaitExistsNoData { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)")!
            Fetcher.shared.existsNoData(at: url, handler: handler)
        }
    }
    
    /// Create club with person with only first name
    private func _testNewClubCallPersonName() throws {
        
        // Call item
        let clubId = TestProperty.shared.testClub.id
        let cachedProperty = SignInCache.PropertyUserIdName(userId: TestProperty.shared.testPersonSecond.userId, name: TestProperty.shared.testPersonSecond.name)
        let clubCredentials = TestProperty.shared.testClub.credentials
        let personId = TestProperty.shared.testPersonSecond.id
        let callItem = NewClubCall(cachedProperties: cachedProperty, clubCredentials: clubCredentials, clubId: clubId, personId: personId)
        
        // Call function
        let error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        XCTAssertNil(error)
        
        // Check person
        let personList: [Person] = try awaitResult { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/persons")!
            Fetcher.shared.fetchList(from: url, handler: handler)
        }
        XCTAssertEqual(personList.count, 1)
        XCTAssertEqual(personList.first!.id, TestProperty.shared.testPersonSecond.id)
        XCTAssertEqual(personList.first!.name, TestProperty.shared.testPersonSecond.name)
        XCTAssertEqual(personList.first!.signInData?.isCashier, true)
        XCTAssertEqual(personList.first!.signInData?.userId, TestProperty.shared.testPersonSecond.userId)
    }
}

// MARK: late payment interest call
/// Test all functions of LatePaymentInterestCall
extension CallerTest {
    
    /// Test late payment interest change
    func testLatePaymentInterest() throws {
        
        // Set late payment interest
        try _testLatePaymentInterestSet()
        
        // Update late payment interest
        try _testLatePaymentInterestUpdate()
        
        // Remove late payment interest
        try _testLatePaymentInterestRemove()
        
        // Remove late payment interest again
        try _testLatePaymentInterestRemove()
        
    }
    
    /// Set late payment interest and check it
    private func _testLatePaymentInterestSet(_ _latePaymentInterest: Settings.LatePaymentInterest? = nil) throws {
        
        // Call item
        let clubId = TestProperty.shared.testClub.id
        let latePaymentInterest = _latePaymentInterest ?? TestProperty.shared.testLatePaymentInterestFirst.latePaymentInterest
        let callItem = LatePaymentInterestCall(latePaymentInterest: latePaymentInterest, clubId: clubId)
        
        // Call function
        let error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        XCTAssertNil(error)
        
        // Check late payment interest
        let fetchedLatePaymentInterest: Settings.LatePaymentInterest = try awaitResult { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/latePaymentInterest")!
            Fetcher.shared.fetchPrmitiveItem(from: url, handler: handler)
        }
        XCTAssertEqual(fetchedLatePaymentInterest, latePaymentInterest)
    }
    
    /// Update late payment interest and check it
    private func _testLatePaymentInterestUpdate() throws {
        let latePaymentInterest = TestProperty.shared.testLatePaymentInterestSecond.latePaymentInterest
        try _testLatePaymentInterestSet(latePaymentInterest)
    }
    
    /// Remove late payment interest and check it
    private func _testLatePaymentInterestRemove() throws {
        
        // Call item
        let clubId = TestProperty.shared.testClub.id
        let callItem = LatePaymentInterestCall(latePaymentInterest: nil, clubId: clubId)
        
        // Call function
        let error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        XCTAssertNil(error)
        
        // Check late payment interest
        try awaitExistsNoData { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/latePaymentInterest")!
            Fetcher.shared.existsNoData(at: url, handler: handler)
        }
    }
}

// MARK: register person call
/// Test all functions of RegisterPersonCall
extension CallerTest {
    
    /// Test register person
    func testRegisterPerson() throws {
        
        // Register person
        try _testRegisterPerson(TestProperty.shared.testPersonFirst.name)
        
        // Register person with same id, but only first name
        try _testRegisterPerson(TestProperty.shared.testPersonSecond.name)
    }
    
    /// Register person and check it
    private func _testRegisterPerson(_ personName: PersonName) throws {
        
        // Call item
        let clubId = TestProperty.shared.testClub.id
        let personId = TestProperty.shared.testPersonSecond.id
        let userId = TestProperty.shared.testPersonSecond.userId
        let userIdName = SignInCache.PropertyUserIdName(userId: userId, name: personName)
        let cachedProperties = SignInCache.PropertyUserIdNameClubId(userIdName: userIdName, clubId: clubId)
        let callItem = RegisterPersonCall(cachedProperties: cachedProperties, personId: personId)
        
        // Call function
        let callResult: RegisterPersonCall.CallResult? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem) { result in
                handler(result)
            } failedHandler: { _ in
                handler(nil)
            }
        }
        XCTAssertEqual(callResult?.clubIdentifier, TestProperty.shared.testClub.identifier)
        XCTAssertEqual(callResult?.clubName, TestProperty.shared.testClub.name)
        XCTAssertEqual(callResult?.regionCode, TestProperty.shared.testClub.regionCode)
        
        // Check person properties
        let person: Person = try awaitResult { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/persons/\(personId)")!
            Fetcher.shared.fetchItem(from: url, handler: handler)
        }
        XCTAssertEqual(person.name, personName)
        XCTAssertEqual(person.signInData?.isCashier, false)
        XCTAssertEqual(person.signInData?.userId, userId)
    }
}

// MARK: force sign out call
/// Test all functions of ForceSignOutCall
extension CallerTest {
    
    /// Test force sign out
    func testForceSignOut() throws {
        
        // Call item
        let personId = TestProperty.shared.testPersonFirst.id
        let clubId = TestProperty.shared.testClub.id
        let callItem = ForceSignOutCall(personId: personId, clubId: clubId)
        
        // Call function
        let error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        XCTAssertNil(error)
        
        // Check sign in data
        try awaitExistsNoData { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/persons/\(personId)/signInData")!
            Fetcher.shared.existsNoData(at: url, handler: handler)
        }
    }
}

// MARK: change list call with person
/// Test all functions of ChangeListCall with person
extension CallerTest {
    
    /// Test change list person
    func testChangeListPerson() throws {
        
        // Set person
        try _testChangeListPersonSet()
        
        // Set person with same id
        try _testChangeListPersonSetSameId()
        
        // Update person
        try _testChangeListPersonUpdate()
        
        // Delete person
        try _testChangeListPersonDelete()
        
        // Delete person again
        try _testChangeListPersonDelete()
        
        // Delete registered person
        try _testChangeListPersonDeleteRegistred()
        
        // Set person with only first name
        try _testChangeListPersonFirstName()
        
        // Update not existing person
        try _testChangeListPersonUpdate()
    }
    
    /// Set person and check it
    func _testChangeListPersonSet() throws {
        
        // Call item
        let clubId = TestProperty.shared.testClub.id
        let person = TestProperty.shared.testPersonThird.person
        let callItem = ChangeListCall(clubId: clubId, changeType: .add, changeItem: person)
        
        // Call function
        let error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        XCTAssertNil(error)
        
        // Check person
        let fetchedPerson: Person = try awaitResult { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/persons/\(person.id)")!
            Fetcher.shared.fetchItem(from: url, handler: handler)
        }
        XCTAssertEqual(fetchedPerson.id, person.id)
        XCTAssertEqual(fetchedPerson.name, person.name)
        XCTAssertNil(fetchedPerson.signInData)
    }
    
    /// Set person with same id
    func _testChangeListPersonSetSameId() throws {
        
        // Call item
        let clubId = TestProperty.shared.testClub.id
        let personId = TestProperty.shared.testPersonThird.id
        let personName = PersonName(firstName: "abc", lastName: "def")
        let person = Person(id: personId, name: personName, signInData: nil)
        let callItem = ChangeListCall(clubId: clubId, changeType: .add, changeItem: person)
        
        // Call function
        let error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        XCTAssertNil(error)
        
        // Check person
        let fetchedPerson: Person = try awaitResult { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/persons/\(person.id)")!
            Fetcher.shared.fetchItem(from: url, handler: handler)
        }
        XCTAssertEqual(fetchedPerson.id, person.id)
        XCTAssertEqual(fetchedPerson.name, TestProperty.shared.testPersonThird.name)
        XCTAssertNil(fetchedPerson.signInData)
    }
    
    /// Update person and check if
    func _testChangeListPersonUpdate() throws {
        
        // Call item
        let clubId = TestProperty.shared.testClub.id
        let personId = TestProperty.shared.testPersonThird.id
        let personName = PersonName(firstName: "abc", lastName: "def")
        let person = Person(id: personId, name: personName, signInData: nil)
        let callItem = ChangeListCall(clubId: clubId, changeType: .update, changeItem: person)
        
        // Call function
        let error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        XCTAssertNil(error)
        
        // Check person
        let fetchedPerson: Person = try awaitResult { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/persons/\(person.id)")!
            Fetcher.shared.fetchItem(from: url, handler: handler)
        }
        XCTAssertEqual(fetchedPerson.id, person.id)
        XCTAssertEqual(fetchedPerson.name, person.name)
        XCTAssertNil(fetchedPerson.signInData)
    }
    
    /// Delete person
    func _testChangeListPersonDelete() throws {
        
        // Call item
        let clubId = TestProperty.shared.testClub.id
        let person = TestProperty.shared.testPersonThird.person
        let callItem = ChangeListCall(clubId: clubId, changeType: .delete, changeItem: person)
        
        // Call function
        let error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        XCTAssertNil(error)
        
        // Check person
        try awaitExistsNoData { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/persons/\(person.id)")!
            Fetcher.shared.existsNoData(at: url, handler: handler)
        }
    }
    
    /// Try delete registered person
    func _testChangeListPersonDeleteRegistred() throws {
        
        // Call item
        let clubId = TestProperty.shared.testClub.id
        let person = TestProperty.shared.testPersonFirst.person
        let callItem = ChangeListCall(clubId: clubId, changeType: .delete, changeItem: person)
        
        // Call function
        let _error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        guard let error = _error as NSError?, error.domain == FunctionsErrorDomain else { return XCTAssert(false) }
        let errorCode = FunctionsErrorCode(rawValue: error.code)
        XCTAssertEqual(errorCode, .unavailable)
        
        // Check person
        let fetchedPerson: Person = try awaitResult { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/persons/\(person.id)")!
            Fetcher.shared.fetchItem(from: url, handler: handler)
        }
        XCTAssertEqual(fetchedPerson.id, person.id)
        XCTAssertEqual(fetchedPerson.name, person.name)
        XCTAssertEqual(fetchedPerson.signInData?.userId, TestProperty.shared.testPersonFirst.userId)
        XCTAssertEqual(fetchedPerson.signInData?.isCashier, true)
    }
    
    /// Set person with only first name and check it
    func _testChangeListPersonFirstName() throws {
        
        // Call item
        let clubId = TestProperty.shared.testClub.id
        let person = TestProperty.shared.testPersonSecond.person
        let callItem = ChangeListCall(clubId: clubId, changeType: .add, changeItem: person)
        
        // Call function
        let error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        XCTAssertNil(error)
        
        // Check person
        let fetchedPerson: Person = try awaitResult { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/persons/\(person.id)")!
            Fetcher.shared.fetchItem(from: url, handler: handler)
        }
        XCTAssertEqual(fetchedPerson.id, person.id)
        XCTAssertEqual(fetchedPerson.name, person.name)
        XCTAssertNil(fetchedPerson.signInData)
    }
}

// MARK: change list call with reason
/// Test all functions of ChangeListCall with reason
extension CallerTest {
    
    /// Test change list reason
    func testChangeListReason() throws {
        
        // Set reason
        try _testChangeListReasonSet()
        
        // Set reason with same id
        try _testChangeListReasonSetSameId()
        
        // Update reason
        try _testChangeListReasonUpdate()
        
        // Delete reason
        try _testChangeListReasonDelete()
        
        // Delete reason again
        try _testChangeListReasonDelete()
        
        // Update not existing reason
        try _testChangeListReasonUpdate()
    }
    
    /// Set reason and check it
    func _testChangeListReasonSet() throws {
        
        // Call item
        let clubId = TestProperty.shared.testClub.id
        let reason = TestProperty.shared.testReason.reasonTemplate
        let callItem = ChangeListCall(clubId: clubId, changeType: .add, changeItem: reason)
        
        // Call function
        let error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        XCTAssertNil(error)
        
        // Check reason
        let fetchedReason: ReasonTemplate = try awaitResult { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/reasons/\(reason.id)")!
            Fetcher.shared.fetchItem(from: url, handler: handler)
        }
        XCTAssertEqual(fetchedReason, reason)
    }
    
    /// Set reason with same id
    func _testChangeListReasonSetSameId() throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let reason = TestProperty.shared.testReason.updatedReasonTemplate
        let callItem = ChangeListCall(clubId: clubId, changeType: .add, changeItem: reason)

        // Call function
        let error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        XCTAssertNil(error)

        // Check reason
        let fetchedReason: ReasonTemplate = try awaitResult { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/reasons/\(reason.id)")!
            Fetcher.shared.fetchItem(from: url, handler: handler)
        }
        XCTAssertEqual(fetchedReason, TestProperty.shared.testReason.reasonTemplate)
    }

    /// Update reason and check if
    func _testChangeListReasonUpdate() throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let reason = TestProperty.shared.testReason.updatedReasonTemplate
        let callItem = ChangeListCall(clubId: clubId, changeType: .update, changeItem: reason)

        // Call function
        let error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        XCTAssertNil(error)

        // Check reason
        let fetchedReason: ReasonTemplate = try awaitResult { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/reasons/\(reason.id)")!
            Fetcher.shared.fetchItem(from: url, handler: handler)
        }
        XCTAssertEqual(fetchedReason, reason)
    }

    /// Delete reason
    func _testChangeListReasonDelete() throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let reason = TestProperty.shared.testReason.updatedReasonTemplate
        let callItem = ChangeListCall(clubId: clubId, changeType: .delete, changeItem: reason)

        // Call function
        let error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        XCTAssertNil(error)

        // Check reason
        try awaitExistsNoData { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/reasons/\(reason.id)")!
            Fetcher.shared.existsNoData(at: url, handler: handler)
        }
    }
}

// MARK: change list call with fine
/// Test all functions of ChangeListCall with fine
extension CallerTest {
    
    /// Test change list fine
    func testChangeListFine() throws {
        
        // Set fine with template id
        try _testChangeListFineSet()
        
        // Set fine with same id
        try _testChangeListFineSetSameId()
        
        // Update fine with reason, importance and amount
        try _testChangeListFineUpdateCustomReason()
        
        // Delete fine
        try _testChangeListFineDelete()
        
        // Delete fine again
        try _testChangeListFineDelete()
        
        // Update not exsisting fine with reason, importance and amount
        try _testChangeListFineUpdateCustomReason()
        
        // Update fine with template id
        try _testChangeListFineUpdateTemplateReason()
    }
    
    /// Set fine and check it
    func _testChangeListFineSet() throws {
        
        // Call item
        let clubId = TestProperty.shared.testClub.id
        let fine = TestProperty.shared.testFine.withReasonTemplate
        let callItem = ChangeListCall(clubId: clubId, changeType: .add, changeItem: fine)
        
        // Call function
        let error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        XCTAssertNil(error)
        
        // Check fine
        let fetchedFine: Fine = try awaitResult { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/fines/\(fine.id)")!
            Fetcher.shared.fetchItem(from: url, handler: handler)
        }
        XCTAssertEqual(fetchedFine, fine)
    }
    
    /// Set fine with same id
    func _testChangeListFineSetSameId() throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let fine = TestProperty.shared.testFine.withReasonCustom
        let callItem = ChangeListCall(clubId: clubId, changeType: .add, changeItem: fine)

        // Call function
        let error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        XCTAssertNil(error)

        // Check fine
        let fetchedFine: Fine = try awaitResult { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/fines/\(fine.id)")!
            Fetcher.shared.fetchItem(from: url, handler: handler)
        }
        XCTAssertEqual(fetchedFine, TestProperty.shared.testFine.withReasonTemplate)
    }
    
    /// Update fine with custom reason and check if
    func _testChangeListFineUpdateCustomReason() throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let fine = TestProperty.shared.testFine.withReasonCustom
        let callItem = ChangeListCall(clubId: clubId, changeType: .update, changeItem: fine)

        // Call function
        let error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        XCTAssertNil(error)

        // Check fine
        let fetchedFine: Fine = try awaitResult { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/fines/\(fine.id)")!
            Fetcher.shared.fetchItem(from: url, handler: handler)
        }
        XCTAssertEqual(fetchedFine, fine)
    }
    
    /// Delete fine
    func _testChangeListFineDelete() throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let fine = TestProperty.shared.testFine.withReasonCustom
        let callItem = ChangeListCall(clubId: clubId, changeType: .delete, changeItem: fine)

        // Call function
        let error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        XCTAssertNil(error)

        // Check fine
        try awaitExistsNoData { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/fines/\(fine.id)")!
            Fetcher.shared.existsNoData(at: url, handler: handler)
        }
    }
    
    /// Update fine with template reason and check if
    func _testChangeListFineUpdateTemplateReason() throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let fine = TestProperty.shared.testFine.withReasonTemplate
        let callItem = ChangeListCall(clubId: clubId, changeType: .update, changeItem: fine)

        // Call function
        let error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        XCTAssertNil(error)

        // Check fine
        let fetchedFine: Fine = try awaitResult { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/fines/\(fine.id)")!
            Fetcher.shared.fetchItem(from: url, handler: handler)
        }
        XCTAssertEqual(fetchedFine, fine)
    }
}

// MARK: change fine payed call
/// Test all functions of ChangeFinePayedCall
extension CallerTest {
    
    /// Test change fine payed
    func testChangeFinePayed() throws {
        
        // Change payed of not existing fine
        try _testChangeFinePayedNoFine()
        
        // Add fine with unpayed
        try _testChangeListFineSet()
        
        // Change to payed
        try _testChangeFinePayedToPayed(12345)
        
        // Change to payed
        try _testChangeFinePayedToPayed(54321)
        
        // Change to unpayed
        try _testChangeFinePayedToUnpayed()
        
        // Change to unpayed
        try _testChangeFinePayedToUnpayed()
    }
    
    /// Change payed of not existing fine
    func _testChangeFinePayedNoFine() throws {
        
        // Call item
        let clubId = TestProperty.shared.testClub.id
        let fineId = TestProperty.shared.testFine.withReasonTemplate.id
        let payed: Payed = .unpayed
        let callItem = ChangeFinePayedCall(clubId: clubId, fineId: fineId, payed: payed)
        
        // Call function
        let error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        XCTAssertNil(error)
    }
    
    /// Change to payed
    func _testChangeFinePayedToPayed(_ payedTimeInterval: TimeInterval) throws {
        
        // Call item
        let clubId = TestProperty.shared.testClub.id
        let fineId = TestProperty.shared.testFine.withReasonTemplate.id
        let payed: Payed = .payed(date: Date(timeIntervalSinceReferenceDate: payedTimeInterval))
        let callItem = ChangeFinePayedCall(clubId: clubId, fineId: fineId, payed: payed)
        
        // Call function
        let error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        XCTAssertNil(error)
        
        // Check payed
        let fetchedPayed: Payed = try awaitResult { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/fines/\(fineId)/payed")!
            Fetcher.shared.fetchPrmitiveItem(from: url, handler: handler)
        }
        XCTAssertEqual(payed, fetchedPayed)
    }
    
    /// Change to unpayed
    func _testChangeFinePayedToUnpayed() throws {
        
        // Call item
        let clubId = TestProperty.shared.testClub.id
        let fineId = TestProperty.shared.testFine.withReasonTemplate.id
        let payed: Payed = .unpayed
        let callItem = ChangeFinePayedCall(clubId: clubId, fineId: fineId, payed: payed)
        
        // Call function
        let error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        XCTAssertNil(error)
        
        // Check payed
        let fetchedPayed: Payed = try awaitResult { handler in
            let url = URL(string: "\(Bundle.main.firebaseClubsComponent)/\(clubId)/fines/\(fineId)/payed")!
            Fetcher.shared.fetchPrmitiveItem(from: url, handler: handler)
        }
        XCTAssertEqual(payed, fetchedPayed)
    }
}

// MARK: get person properties call
/// Test all functions of GetPersonPropertiesCall
extension CallerTest {
    
    /// Test get person properties
    func testGetPersonProperties() throws {
        
        // Try to get properties of not existing person
        try _testGetPersonPropertiesNotExistingPerson()
        
        // Get properties of person
        let firstPerson = TestProperty.shared.testPersonFirst
        try _testGetPersonPropertiesPerson(firstPerson.userId, person: firstPerson.person, isCashier: true)
        
        // Register person with only first name
        try _testRegisterPerson(TestProperty.shared.testPersonSecond.name)
        
        // Get properties of person with only first name
        let secondPerson = TestProperty.shared.testPersonSecond
        try _testGetPersonPropertiesPerson(secondPerson.userId, person: secondPerson.person, isCashier: false)
    }
    
    /// With not existing person
    func _testGetPersonPropertiesNotExistingPerson() throws {
        
        // Call item
        let userId = TestProperty.shared.testPersonSecond.userId
        let callItem = GetPersonPropertiesCall(userId: userId)
        
        // Call function
        let _error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        guard let error = _error as NSError?, error.domain == FunctionsErrorDomain else { return XCTAssert(false) }
        let errorCode = FunctionsErrorCode(rawValue: error.code)
        XCTAssertEqual(errorCode, .notFound)
    }
    
    /// Get properties of person
    func _testGetPersonPropertiesPerson(_ userId: String, person: Person, isCashier: Bool) throws {
        
        // Call item
        let callItem = GetPersonPropertiesCall(userId: userId)
        
        // Call function
        let personProperties: Settings.Person? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem) { propertries in
                handler(propertries)
            } failedHandler: { _ in
                handler(nil)
            }
        }
        
        // Check properties
        XCTAssertEqual(personProperties?.clubProperties.id, TestProperty.shared.testClub.id)
        XCTAssertEqual(personProperties?.clubProperties.identifier, TestProperty.shared.testClub.identifier)
        XCTAssertEqual(personProperties?.clubProperties.name, TestProperty.shared.testClub.name)
        XCTAssertEqual(personProperties?.clubProperties.regionCode, TestProperty.shared.testClub.regionCode)
        XCTAssertEqual(personProperties?.id, person.id)
        XCTAssertEqual(personProperties?.name, person.name)
        XCTAssertEqual(personProperties?.isCashier, isCashier)
    }
}

// MARK: get club id call
/// Test all functions of GetClubIdCall
extension CallerTest {
    
    /// Test get club id
    func testGetClubId() throws {
        
        // Try to get club id of not existing club
        try _testGetClubIdNotExistingClub()
        
        // Get id of club
        try _testGetClubIdClub()
    }
    
    /// With not existing club
    func _testGetClubIdNotExistingClub() throws {
        
        // Call item
        let callItem = GetClubIdCall(identifier: "asdf")
        
        // Call function
        let _error: Error? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem, errorHandler: handler)
        }
        guard let error = _error as NSError?, error.domain == FunctionsErrorDomain else { return XCTAssert(false) }
        let errorCode = FunctionsErrorCode(rawValue: error.code)
        XCTAssertEqual(errorCode, .notFound)
    }
    
    /// Get properties of person
    func _testGetClubIdClub() throws {
        
        // Call item
        let identifier = TestProperty.shared.testClub.identifier
        let callItem = GetClubIdCall(identifier: identifier)
        
        // Call function
        let clubId: Club.ID? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem) { id in
                handler(id)
            } failedHandler: { _ in
                handler(nil)
            }
        }
        XCTAssertEqual(clubId, TestProperty.shared.testClub.id)
    }
}

// MARK: club identifier already exists call
/// Test all functions of ClubIdentifierAlreadyExistsCall
extension CallerTest {
    
    /// Test exists club with identifier
    func testExistsClubWithIdentifier() throws {
        
        // Of not existing club
        try _testExistsClubWithIdentifierNotExisting()
        
        // Of existing club
        try _testExistsClubWithIdentifierExisting()
    }
    
    /// Of not existing club
    func _testExistsClubWithIdentifierNotExisting() throws {
        
        // Call item
        let callItem = ClubIdentifierAlreadyExistsCall(identifier: "asdf")
        
        // Call function
        let existsClub: Bool? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem) { exists in
                handler(exists)
            } failedHandler: { _ in
                handler(nil)
            }
        }
        XCTAssertNotNil(existsClub)
        XCTAssertFalse(existsClub!)
    }
    
    /// Of existing club
    func _testExistsClubWithIdentifierExisting() throws {
        
        // Call item
        let identifier = TestProperty.shared.testClub.identifier
        let callItem = ClubIdentifierAlreadyExistsCall(identifier: identifier)
        
        // Call function
        let existsClub: Bool? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem) { exists in
                handler(exists)
            } failedHandler: { _ in
                handler(nil)
            }
        }
        XCTAssertNotNil(existsClub)
        XCTAssertTrue(existsClub!)
    }
}

// MARK: get person properties call
/// Test all functions of GetPersonPropertiesCall
extension CallerTest {
    
    /// Test exists person with user id
    func testExistsPersonWithUserId() throws {
        
        // Of not existing person
        try _testExistsPersonWithUserIdNotExisting()
        
        // Of existing person
        try _testExistsPersonWithUserIdExisting()
    }
    
    /// Of not existing person
    func _testExistsPersonWithUserIdNotExisting() throws {
        
        // Call item
        let callItem = UserIdAlreadyExistsCall(userId: "asdf")
        
        // Call function
        let existsPerson: Bool? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem) { exists in
                handler(exists)
            } failedHandler: { _ in
                handler(nil)
            }
        }
        XCTAssertNotNil(existsPerson)
        XCTAssertFalse(existsPerson!)
    }
    
    /// Of existing person
    func _testExistsPersonWithUserIdExisting() throws {
        
        // Call item
        let userId = TestProperty.shared.testPersonFirst.userId
        let callItem = UserIdAlreadyExistsCall(userId: userId)
        
        // Call function
        let existsPerson: Bool? = try awaitValue { handler in
            FunctionCaller.shared.call(callItem) { exists in
                handler(exists)
            } failedHandler: { _ in
                handler(nil)
            }
        }
        XCTAssertNotNil(existsPerson)
        XCTAssertTrue(existsPerson!)
    }
}
