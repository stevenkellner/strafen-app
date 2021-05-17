//
//  FirebaseFunctionCallerTests.swift
//  StrafenTests
//
//  Created by Steven on 17.05.21.
//

import XCTest
import FirebaseFunctions
@testable import Strafen

// swiftlint:disable identifier_name
class FirebaseFunctionCallerTests: XCTestCase {

    // MARK: set up
    /// Create a test club
    override func setUpWithError() throws {
        continueAfterFailure = false
        FirebaseFunctionCaller.shared.level = .testing
        FirebaseFetcher.shared.level = .testing

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
        let clubId = TestProperty.shared.testClub.id
        let personId = TestProperty.shared.testPersonFirst.id
        let clubName = TestProperty.shared.testClub.name
        let regionCode = TestProperty.shared.testClub.regionCode
        let clubIdentifier = TestProperty.shared.testClub.identifier
        let signInProperty = SignInProperty.UserIdName(userId: TestProperty.shared.testPersonFirst.userId, name: TestProperty.shared.testPersonFirst.name)
        let callItem = FFNewClubCall(signInProperty: signInProperty, clubId: clubId, personId: personId, clubName: clubName, regionCode: regionCode, clubIdentifier: clubIdentifier, inAppPayment: true)

        // Function call to create test club
        let result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        _ = try result.get()
    }

    /// Check properties of test club
    private func _setUpCheckClubPropertries() throws {
        let clubId = TestProperty.shared.testClub.id
        let clubResult: Result<TestClub.Properties, Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetch(TestClub.Properties.self, url: nil, clubId: clubId).thenResult(handler)
        }
        XCTAssertEqual(try clubResult.get().club(with: clubId), TestProperty.shared.testClub.club)
    }

    /// Check person list of test club
    private func _setUpCheckPersonList() throws {
        let clubId = TestProperty.shared.testClub.id
        let personListResult: Result<[FirebasePerson], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId).thenResult(handler)
        }
        let personList = try personListResult.get()
        XCTAssertEqual(personList.count, 1)
        XCTAssertEqual(personList.first!.id, TestProperty.shared.testPersonFirst.id)
        XCTAssertEqual(personList.first!.name, TestProperty.shared.testPersonFirst.name)
        XCTAssertEqual(personList.first!.signInData?.isCashier, true)
        XCTAssertEqual(personList.first!.signInData?.userId, TestProperty.shared.testPersonFirst.userId)
    }

    /// Check reason list of test club
    private func _setUpCheckReasonList() throws {
        let clubId = TestProperty.shared.testClub.id
        let reasonListResult: Result<[FirebaseReasonTemplate], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebaseReasonTemplate.self, clubId: clubId).thenResult(handler)
        }
        XCTAssertEqual(try reasonListResult.get(), [])
    }

    /// Check fine list of test club
    private func _setUpCheckFineList() throws {
        let clubId = TestProperty.shared.testClub.id
        let fineListResult: Result<[FirebaseFine], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebaseFine.self, clubId: clubId).thenResult(handler)
        }
        XCTAssertEqual(try fineListResult.get(), [])
    }

    // MARK: tear down
    /// Delete test club and all associated data
    override func tearDownWithError() throws {

        // Delete test club
        try _tearDownDeleteClub()

        // Check if test club is deleted
        try _tearDownCheckClub()

    }

    /// Delete test club
    private func _tearDownDeleteClub() throws {
        let clubId = TestProperty.shared.testClub.id
        let result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            let callItem = FFDeleteTestClubCall(clubId: clubId)
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        _ = try result.get()
    }

    /// Check if test club is deleted
    private func _tearDownCheckClub() throws {
        let clubId = TestProperty.shared.testClub.id
        let result: Result<TestClub.Properties, Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetch(TestClub.Properties.self, url: nil, clubId: clubId).thenResult(handler)
        }
        XCTAssertEqual(result.error as? FirebaseFetcher.FetchError, .noData)
    }
}

// MARK: new club call
/// Test all functions of NewClubCall
extension FirebaseFunctionCallerTests {

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
        let identifierResult: Result<String, Error> = try waitExpectation { handler in
            let url = URL(string: "identifier")!
            FirebaseFetcher.shared.fetch(String.self, url: url, clubId: clubId).thenResult(handler)
        }
        XCTAssertEqual(try identifierResult.get(), TestProperty.shared.testClub.identifier)

        // Check name
        let nameResult: Result<String, Error> = try waitExpectation { handler in
            let url = URL(string: "name")!
            FirebaseFetcher.shared.fetch(String.self, url: url, clubId: clubId).thenResult(handler)
        }
        XCTAssertEqual(try nameResult.get(), TestProperty.shared.testClub.name)

        // Check region code
        let regionCodeResult: Result<String, Error> = try waitExpectation { handler in
            let url = URL(string: "regionCode")!
            FirebaseFetcher.shared.fetch(String.self, url: url, clubId: clubId).thenResult(handler)
        }
        XCTAssertEqual(try regionCodeResult.get(), TestProperty.shared.testClub.regionCode)

        // Check person user ids
        let personIdResult: Result<String, Error> = try waitExpectation { handler in
            let url = URL(string: "personUserIds/\(TestProperty.shared.testPersonFirst.userId)")!
            FirebaseFetcher.shared.fetch(String.self, url: url, clubId: clubId).thenResult(handler)
        }
        XCTAssertEqual(try personIdResult.get(), TestProperty.shared.testPersonFirst.id.uuidString)
    }

    /// Create new club with already existing identifier
    private func _testNewClubCallExistingIdentifier() throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let personId = TestProperty.shared.testPersonFirst.id
        let clubName = TestProperty.shared.testClub.name
        let regionCode = TestProperty.shared.testClub.regionCode
        let clubIdentifier = TestProperty.shared.testClub.identifier
        let signInProperty = SignInProperty.UserIdName(userId: TestProperty.shared.testPersonFirst.userId, name: TestProperty.shared.testPersonFirst.name)
        let callItem = FFNewClubCall(signInProperty: signInProperty, clubId: clubId, personId: personId, clubName: clubName, regionCode: regionCode, clubIdentifier: clubIdentifier, inAppPayment: true)

        // Call function
        let errorCode: FunctionsErrorCode? = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult { result in
                guard let error = result.error as NSError?, error.domain == FunctionsErrorDomain else { return handler(nil) }
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
        let personId = TestProperty.shared.testPersonFirst.id
        let clubName = TestProperty.shared.testClub.name
        let regionCode = TestProperty.shared.testClub.regionCode
        let clubIdentifier = "different identifier"
        let signInProperty = SignInProperty.UserIdName(userId: TestProperty.shared.testPersonFirst.userId, name: TestProperty.shared.testPersonFirst.name)
        let callItem = FFNewClubCall(signInProperty: signInProperty, clubId: clubId, personId: personId, clubName: clubName, regionCode: regionCode, clubIdentifier: clubIdentifier, inAppPayment: true)

        // Call function
        let error: Error? = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult { result in
                handler(result.error)
            }
        }
        XCTAssertNil(error)
        let identifierAfterSameIdResult: Result<String, Error> = try waitExpectation { handler in
            let url = URL(string: "identifier")!
            FirebaseFetcher.shared.fetch(String.self, url: url, clubId: clubId).thenResult(handler)
        }
        XCTAssertEqual(try identifierAfterSameIdResult.get(), TestProperty.shared.testClub.identifier)
    }

    /// Delete club and check if it's deleted
    private func _testNewClubCallDeleteClub() throws {
        let clubId = TestProperty.shared.testClub.id
        let callItem = FFDeleteTestClubCall(clubId: clubId)
        let error: Error? = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult { result in
                handler(result.error)
            }
        }
        XCTAssertNil(error)

        let result: Result<TestClub.Properties, Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetch(TestClub.Properties.self, url: nil, clubId: clubId).thenResult(handler)
        }
        XCTAssertEqual(result.error as? FirebaseFetcher.FetchError, .noData)
    }

    /// Create club with person with only first name
    private func _testNewClubCallPersonName() throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let personId = TestProperty.shared.testPersonSecond.id
        let clubName = TestProperty.shared.testClub.name
        let regionCode = TestProperty.shared.testClub.regionCode
        let clubIdentifier = TestProperty.shared.testClub.identifier
        let signInProperty = SignInProperty.UserIdName(userId: TestProperty.shared.testPersonSecond.userId, name: TestProperty.shared.testPersonSecond.name)
        let callItem = FFNewClubCall(signInProperty: signInProperty, clubId: clubId, personId: personId, clubName: clubName, regionCode: regionCode, clubIdentifier: clubIdentifier, inAppPayment: true)

        // Call function
        let error: Error? = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult { result in
                handler(result.error)
            }
        }
        XCTAssertNil(error)

        // Check person
        let personListResult: Result<[FirebasePerson], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId).thenResult(handler)
        }
        let personList = try personListResult.get()
        XCTAssertEqual(personList.count, 1)
        XCTAssertEqual(personList.first!.id, TestProperty.shared.testPersonSecond.id)
        XCTAssertEqual(personList.first!.name, TestProperty.shared.testPersonSecond.name)
        XCTAssertEqual(personList.first!.signInData?.isCashier, true)
        XCTAssertEqual(personList.first!.signInData?.userId, TestProperty.shared.testPersonSecond.userId)
    }
}

// MARK: late payment interest call
/// Test all functions of LatePaymentInterestCall
extension FirebaseFunctionCallerTests {

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
    private func _testLatePaymentInterestSet(_ _latePaymentInterest: LatePaymentInterest? = nil) throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let latePaymentInterest = _latePaymentInterest ?? TestProperty.shared.testLatePaymentInterestFirst.latePaymentInterest
        let callItem = FFChangeLatePaymentInterestCall(clubId: clubId, interest: latePaymentInterest)

        // Call function
        let result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        XCTAssertNil(result.error)

        // Check late payment interest
        let latePaymentInterestResult: Result<LatePaymentInterest, Error> = try waitExpectation { handler in
            let url = URL(string: "latePaymentInterest")!
            FirebaseFetcher.shared.fetch(LatePaymentInterest.self, url: url, clubId: clubId).thenResult(handler)
        }
        XCTAssertEqual(try latePaymentInterestResult.get(), latePaymentInterest)
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
        let callItem = FFChangeLatePaymentInterestCall(clubId: clubId)

        // Call function
        let result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        XCTAssertNil(result.error)

        // Check late payment interest
        let latePaymentInterestResult: Result<LatePaymentInterest, Error> = try waitExpectation { handler in
            let url = URL(string: "latePaymentInterest")!
            FirebaseFetcher.shared.fetch(LatePaymentInterest.self, url: url, clubId: clubId).thenResult(handler)
        }
        XCTAssertEqual(latePaymentInterestResult.error as? FirebaseFetcher.FetchError, .noData)
    }
}

// MARK: register person call
/// Test all functions of RegisterPersonCall
extension FirebaseFunctionCallerTests {

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
        let signInProperty = SignInProperty.UserIdNameClubId(.init(userId: userId, name: personName), clubId: clubId)
        let callItem = FFRegisterPersonCall(signInProperty: signInProperty, personId: personId)

        // Call function
        let callResult: Result<FFRegisterPersonCall.CallResult, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        XCTAssertEqual(try callResult.get().clubIdentifier, TestProperty.shared.testClub.identifier)
        XCTAssertEqual(try callResult.get().clubName, TestProperty.shared.testClub.name)
        XCTAssertEqual(try callResult.get().regionCode, TestProperty.shared.testClub.regionCode)
        XCTAssertEqual(try callResult.get().inAppPaymentActive, true)

        // Check person properties
        let personListResult: Result<[FirebasePerson], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId).thenResult(handler)
        }
        let person = try personListResult.get().first { $0.id == personId }
        XCTAssertEqual(person?.name, personName)
        XCTAssertEqual(person?.signInData?.isCashier, false)
        XCTAssertEqual(person?.signInData?.userId, userId)

        // Check person user ids
        let userIdResult: Result<String, Error> = try waitExpectation { handler in
            let url = URL(string: "personUserIds/\(TestProperty.shared.testPersonSecond.userId)")!
            FirebaseFetcher.shared.fetch(String.self, url: url, clubId: clubId).thenResult(handler)
        }
        XCTAssertEqual(try userIdResult.get(), TestProperty.shared.testPersonSecond.id.uuidString)
    }
}

// MARK: force sign out call
/// Test all functions of ForceSignOutCall
extension FirebaseFunctionCallerTests {

    /// Test force sign out
    func testForceSignOut() throws {

        // Call item
        let personId = TestProperty.shared.testPersonFirst.id
        let clubId = TestProperty.shared.testClub.id
        let callItem = FFForceSignOutCall(clubId: clubId, personId: personId)

        // Call function
        let result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        XCTAssertNil(result.error)

        // Check sign in data
        let signInDataResult: Result<FirebasePerson.SignInData, Error> = try waitExpectation { handler in
            let url = URL(string: "persons/\(personId)/signInData")!
            FirebaseFetcher.shared.fetch(FirebasePerson.SignInData.self, url: url, clubId: clubId).thenResult(handler)
        }
        XCTAssertEqual(signInDataResult.error as? FirebaseFetcher.FetchError, .noData)
    }
}

// MARK: change list call with person
/// Test all functions of ChangeListCall with person
extension FirebaseFunctionCallerTests {

    /// Test change list person
    func testChangeListPerson() throws {

        // Set person
        try _testChangeListPersonSet()

        // Update person
        try _testChangeListPersonUpdate()

        // Delete person
        try _testChangeListPersonDelete()

        // Delete person again
        try _testChangeListPersonDelete()

        // Delete registered person
        try _testChangeListPersonDeleteRegistered()

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
        let callItem = FFChangeListCall(clubId: clubId, item: person)

        // Call function
        let result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        XCTAssertNil(result.error)

        // Check person
        let personListResult: Result<[FirebasePerson], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId).thenResult(handler)
        }
        let fetchedPerson = try personListResult.get().first { $0.id == person.id }
        XCTAssertEqual(fetchedPerson?.name, person.name)
        XCTAssertNil(fetchedPerson?.signInData)
    }

    /// Update person and check if
    func _testChangeListPersonUpdate() throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let personId = TestProperty.shared.testPersonThird.id
        let personName = PersonName(firstName: "abc", lastName: "def")
        let person = FirebasePerson(id: personId, name: personName, signInData: nil)
        let callItem = FFChangeListCall(clubId: clubId, item: person)

        // Call function
        let result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        XCTAssertNil(result.error)

        // Check person
        let personListResult: Result<[FirebasePerson], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId).thenResult(handler)
        }
        let fetchedPerson = try personListResult.get().first { $0.id == person.id }
        XCTAssertEqual(fetchedPerson?.name, person.name)
        XCTAssertNil(fetchedPerson?.signInData)
    }

    /// Delete person
    func _testChangeListPersonDelete() throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let person = TestProperty.shared.testPersonThird.person
        let callItem = FFChangeListCall<FirebasePerson>(clubId: clubId, id: person.id)

        // Call function
        let result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        XCTAssertNil(result.error)

        // Check person
        let personListResult: Result<[FirebasePerson], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId).thenResult(handler)
        }
        let fetchedPerson = try personListResult.get().first { $0.id == person.id }
        XCTAssertNil(fetchedPerson)
    }

    /// Try delete registered person
    func _testChangeListPersonDeleteRegistered() throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let person = TestProperty.shared.testPersonFirst.person
        let callItem = FFChangeListCall<FirebasePerson>(clubId: clubId, id: person.id)

        // Call function
        let result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        let error = result.error as NSError?
        XCTAssertEqual(error?.domain, FunctionsErrorDomain)
        let errorCode = FunctionsErrorCode(rawValue: error!.code)
        XCTAssertEqual(errorCode, .unavailable)

        // Check person
        let personListResult: Result<[FirebasePerson], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId).thenResult(handler)
        }
        let fetchedPerson = try personListResult.get().first { $0.id == person.id }
        XCTAssertEqual(fetchedPerson?.name, person.name)
        XCTAssertEqual(fetchedPerson?.signInData?.userId, TestProperty.shared.testPersonFirst.userId)
        XCTAssertEqual(fetchedPerson?.signInData?.isCashier, true)
    }

    /// Set person with only first name and check it
    func _testChangeListPersonFirstName() throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let person = TestProperty.shared.testPersonSecond.person
        let callItem = FFChangeListCall(clubId: clubId, item: person)

        // Call function
        let result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        XCTAssertNil(result.error)

        // Check person
        let personListResult: Result<[FirebasePerson], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId).thenResult(handler)
        }
        let fetchedPerson = try personListResult.get().first { $0.id == person.id }
        XCTAssertEqual(fetchedPerson?.name, person.name)
        XCTAssertNil(fetchedPerson?.signInData)
    }
}

// MARK: change list call with reason
/// Test all functions of ChangeListCall with reason
extension FirebaseFunctionCallerTests {

    /// Test change list reason
    func testChangeListReason() throws {

        // Set reason
        try _testChangeListReasonSet()

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
        let callItem = FFChangeListCall(clubId: clubId, item: reason)

        // Call function
        let result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        XCTAssertNil(result.error)

        // Check reason
        let reasonListResult: Result<[FirebaseReasonTemplate], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebaseReasonTemplate.self, clubId: clubId).thenResult(handler)
        }
        let fetchedReason = try reasonListResult.get().first { $0.id == reason.id }
        XCTAssertEqual(fetchedReason, reason)
    }

    /// Update reason and check if
    func _testChangeListReasonUpdate() throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let reason = TestProperty.shared.testReason.updatedReasonTemplate
        let callItem = FFChangeListCall(clubId: clubId, item: reason)

        // Call function
        let result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        XCTAssertNil(result.error)

        // Check reason
        let reaspnListResult: Result<[FirebaseReasonTemplate], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebaseReasonTemplate.self, clubId: clubId).thenResult(handler)
        }
        let fetchedReason = try reaspnListResult.get().first { $0.id == reason.id }
        XCTAssertEqual(fetchedReason, reason)
    }

    /// Delete reason
    func _testChangeListReasonDelete() throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let reason = TestProperty.shared.testReason.updatedReasonTemplate
        let callItem = FFChangeListCall<FirebaseReasonTemplate>(clubId: clubId, id: reason.id)

        // Call function
        let result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        XCTAssertNil(result.error)

        // Check reason
        let reasonListResult: Result<[FirebaseReasonTemplate], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebaseReasonTemplate.self, clubId: clubId).thenResult(handler)
        }
        let fetchedReason = try reasonListResult.get().first { $0.id == reason.id }
        XCTAssertNil(fetchedReason)
    }
}

// MARK: change list call with fine
/// Test all functions of ChangeListCall with fine
extension FirebaseFunctionCallerTests {

    /// Test change list fine
    func testChangeListFine() throws {

        // Set fine with template id
        try _testChangeListFineSet()

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
        let callItem = FFChangeListCall(clubId: clubId, item: fine)

        // Call function
        let result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        XCTAssertNil(result.error)

        // Check fine
        let fineListResult: Result<[FirebaseFine], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebaseFine.self, clubId: clubId).thenResult(handler)
        }
        let fetchedFine = try fineListResult.get().first { $0.id == fine.id }
        XCTAssertEqual(fetchedFine, fine)
    }

    /// Update fine with custom reason and check if
    func _testChangeListFineUpdateCustomReason() throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let fine = TestProperty.shared.testFine.withReasonCustom
        let callItem = FFChangeListCall(clubId: clubId, item: fine)

        // Call function
        let result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        XCTAssertNil(result.error)

        // Check fine
        let fineListResult: Result<[FirebaseFine], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebaseFine.self, clubId: clubId).thenResult(handler)
        }
        let fetchedFine = try fineListResult.get().first { $0.id == fine.id }
        XCTAssertEqual(fetchedFine, fine)
    }

    /// Delete fine
    func _testChangeListFineDelete() throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let fine = TestProperty.shared.testFine.withReasonCustom
        let callItem = FFChangeListCall<FirebaseFine>(clubId: clubId, id: fine.id)

        // Call function
        let result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        XCTAssertNil(result.error)

        // Check fine
        let fineListResult: Result<[FirebaseFine], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebaseFine.self, clubId: clubId).thenResult(handler)
        }
        let fetchedFine = try fineListResult.get().first { $0.id == fine.id }
        XCTAssertNil(fetchedFine)
    }

    /// Update fine with template reason and check if
    func _testChangeListFineUpdateTemplateReason() throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let fine = TestProperty.shared.testFine.withReasonTemplate
        let callItem = FFChangeListCall(clubId: clubId, item: fine)

        // Call function
        let result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        XCTAssertNil(result.error)

        // Check fine
        let fineListResult: Result<[FirebaseFine], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebaseFine.self, clubId: clubId).thenResult(handler)
        }
        let fetchedFine = try fineListResult.get().first { $0.id == fine.id }
        XCTAssertEqual(fetchedFine, fine)
    }
}

// MARK: change fine payed call
/// Test all functions of ChangeFinePayedCall
extension FirebaseFunctionCallerTests {

    /// Test change fine payed
    func testChangeFinePayed() throws {

        // Change payed of not existing fine
        try _testChangeFinePayedNoFine()

        // Add fine with unpayed
        try _testChangeListFineSet()

        // Change to payed
        try _testChangeFinePayed(.payed(date: Date(timeIntervalSinceReferenceDate: 12345), inApp: false))

        // Change to payed
        try _testChangeFinePayed(.payed(date: Date(timeIntervalSinceReferenceDate: 54321), inApp: true))

        // Change to unpayed
        try _testChangeFinePayed(.unpayed)

        // Change to settled
        try _testChangeFinePayed(.settled)
    }

    /// Change payed of not existing fine
    func _testChangeFinePayedNoFine() throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let fineId = TestProperty.shared.testFine.withReasonTemplate.id
        let payed: Payed = .unpayed
        let callItem = FFChangeFinePayed(clubId: clubId, fineId: fineId, newState: payed)

        // Call function
        let result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        XCTAssertNil(result.error)
    }

    /// Change to unpayed
    func _testChangeFinePayed(_ state: Payed) throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let fineId = TestProperty.shared.testFine.withReasonTemplate.id
        let callItem = FFChangeFinePayed(clubId: clubId, fineId: fineId, newState: state)

        // Call function
        let result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        XCTAssertNil(result.error)

        // Check payed
        let fineListResult: Result<[FirebaseFine], Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchList(FirebaseFine.self, clubId: clubId).thenResult(handler)
        }
        let fetchedFine = try fineListResult.get().first { $0.id == fineId }
        XCTAssertEqual(fetchedFine?.payed, state)
    }
}

// MARK: get person properties call
/// Test all functions of GetPersonPropertiesCall
extension FirebaseFunctionCallerTests {

    /// Test get person properties
    func testGetPersonProperties() throws {

        // Try to get properties of not existing person
        try _testGetPersonPropertiesNotExistingPerson()

        // Get properties of person
        let firstPerson = TestProperty.shared.testPersonFirst
        try _testGetPersonPropertiesPerson(firstPerson.userId, person: firstPerson.person, isCashier: true)

        // Register person with only first name
        try _testRegisterPerson(TestProperty.shared.testPersonSecond.name)
    }

    /// With not existing person
    func _testGetPersonPropertiesNotExistingPerson() throws {

        // Call item
        let userId = TestProperty.shared.testPersonThird.userId
        let callItem = FFGetPersonPropertiesCall(userId: userId)

        // Call function
        let result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        let error = result.error as NSError?
        XCTAssertEqual(error?.domain, FunctionsErrorDomain)
        let errorCode = FunctionsErrorCode(rawValue: error!.code)
        XCTAssertEqual(errorCode, .notFound)
    }

    /// Get properties of person
    func _testGetPersonPropertiesPerson(_ userId: String, person: FirebasePerson, isCashier: Bool) throws {

        // Call item
        let callItem = FFGetPersonPropertiesCall(userId: userId)

        // Call function
        let result: Result<FFGetPersonPropertiesCall.CallResult, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }

        // Check properties
        let properties = try result.get()
        XCTAssertEqual(properties.clubProperties.id, TestProperty.shared.testClub.id)
        XCTAssertEqual(properties.clubProperties.identifier, TestProperty.shared.testClub.identifier)
        XCTAssertEqual(properties.clubProperties.name, TestProperty.shared.testClub.name)
        XCTAssertEqual(properties.clubProperties.regionCode, TestProperty.shared.testClub.regionCode)
        XCTAssertEqual(properties.id, person.id)
        XCTAssertEqual(properties.name, person.name)
        XCTAssertEqual(properties.isCashier, isCashier)
    }
}

// MARK: get club id call
/// Test all functions of GetClubIdCall
extension FirebaseFunctionCallerTests {

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
        let callItem = FFGetClubIdCall(identifier: "asdf")

        // Call function
        let result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        let error = result.error as NSError?
        XCTAssertEqual(error?.domain, FunctionsErrorDomain)
        let errorCode = FunctionsErrorCode(rawValue: error!.code)
        XCTAssertEqual(errorCode, .notFound)
    }

    /// Get properties of person
    func _testGetClubIdClub() throws {

        // Call item
        let identifier = TestProperty.shared.testClub.identifier
        let callItem = FFGetClubIdCall(identifier: identifier)

        // Call function
        let result: Result<Club.ID, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        XCTAssertEqual(try result.get(), TestProperty.shared.testClub.id)
    }
}

// MARK: club identifier already exists call
/// Test all functions of ClubIdentifierAlreadyExistsCall
extension FirebaseFunctionCallerTests {

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
        let callItem = FFExistsClubWithIdentifierCall(identifier: "asdf")

        // Call function
        let result: Result<Bool, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        XCTAssertFalse(try result.get())
    }

    /// Of existing club
    func _testExistsClubWithIdentifierExisting() throws {

        // Call item
        let identifier = TestProperty.shared.testClub.identifier
        let callItem = FFExistsClubWithIdentifierCall(identifier: identifier)

        // Call function
        let result: Result<Bool, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        XCTAssertTrue(try result.get())
    }
}

// MARK: exists person properties call
/// Test all functions of GetPersonPropertiesCall
extension FirebaseFunctionCallerTests {

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
        let callItem = FFExistsPersonWithUserIdCall(userId: "asdf")

        // Call function
        let result: Result<Bool, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        XCTAssertFalse(try result.get())
    }

    /// Of existing person
    func _testExistsPersonWithUserIdExisting() throws {

        // Call item
        let userId = TestProperty.shared.testPersonFirst.userId
        let callItem = FFExistsPersonWithUserIdCall(userId: userId)

        // Call function
        let result: Result<Bool, Error> = try waitExpectation { handler in
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        XCTAssertTrue(try result.get())
    }
}
