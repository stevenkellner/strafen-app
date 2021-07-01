//
//  FirebaseFunctionCallerTests.swift
//  StrafenTests
//
//  Created by Steven on 17.05.21.
//

import XCTest
import FirebaseFunctions
import FirebaseAuth
@testable import Strafen

// swiftlint:disable identifier_name
class FirebaseFunctionCallerTests: XCTestCase {

    // MARK: set up
    /// Create a test club
    @MainActor override func setUpWithError() throws {
        continueAfterFailure = false
        FirebaseFunctionCaller.shared.level = .testing
        FirebaseFetcher.shared.level = .testing

        waitExpectation { handler in
            async {

                // Sign test user in
                try await Auth.auth().signIn(withEmail: "app.demo@web.de", password: "Demopw12")

                // Create test club
                try await _setUpCreateClub()

                // Check if club is created
                try await _setUpCheckClubPropertries()
                try await _setUpCheckPersonList()
                try await _setUpCheckReasonList()
                try await _setUpCheckFineList()

                handler()
            }
        }
        try Task.checkCancellation()
    }

    /// Create test club
    private func _setUpCreateClub() async throws {

        // Call Item for creating test club
        let clubId = TestProperty.shared.testClub.id
        let personId = TestProperty.shared.testPersonFirst.id
        let clubName = TestProperty.shared.testClub.name
        let regionCode = TestProperty.shared.testClub.regionCode
        let clubIdentifier = TestProperty.shared.testClub.identifier
        let signInProperty = SignInProperty.UserIdName(userId: TestProperty.shared.testPersonFirst.userId, name: TestProperty.shared.testPersonFirst.name)
        let callItem = FFNewClubCall(signInProperty: signInProperty, clubId: clubId, personId: personId, clubName: clubName, regionCode: regionCode, clubIdentifier: clubIdentifier, inAppPayment: true)

        // Function call to create test club
        try await FirebaseFunctionCaller.shared.call(callItem)
    }

    /// Check properties of test club
    private func _setUpCheckClubPropertries() async throws {
        let clubId = TestProperty.shared.testClub.id
        let club = try await FirebaseFetcher.shared.fetch(TestClub.Properties.self, url: nil, clubId: clubId)
        XCTAssertEqual(club.club(with: clubId), TestProperty.shared.testClub.club)
    }

    /// Check person list of test club
    private func _setUpCheckPersonList() async throws {
        let clubId = TestProperty.shared.testClub.id
        let personList = try await FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId)
        XCTAssertEqual(personList.count, 1)
        XCTAssertEqual(personList.first!.id, TestProperty.shared.testPersonFirst.id)
        XCTAssertEqual(personList.first!.name, TestProperty.shared.testPersonFirst.name)
        XCTAssertEqual(personList.first!.signInData?.isCashier, true)
        XCTAssertEqual(personList.first!.signInData?.userId, TestProperty.shared.testPersonFirst.userId)
    }

    /// Check reason list of test club
    private func _setUpCheckReasonList() async throws {
        let clubId = TestProperty.shared.testClub.id
        let reasonList = try await FirebaseFetcher.shared.fetchList(FirebaseReasonTemplate.self, clubId: clubId)
        XCTAssertEqual(reasonList, [])
    }

    /// Check fine list of test club
    private func _setUpCheckFineList() async throws {
        let clubId = TestProperty.shared.testClub.id
        let fineList = try await FirebaseFetcher.shared.fetchList(FirebaseFine.self, clubId: clubId)
        XCTAssertEqual(fineList, [])
    }

    // MARK: tear down
    /// Delete test club and all associated data
    override func tearDownWithError() throws {
        waitExpectation { handler in
            async {

                // Delete test club
                try await _tearDownDeleteClub()

                // Check if test club is deleted
                try await _tearDownCheckClub()

                handler()
            }
        }
        try Task.checkCancellation()
    }

    /// Delete test club
    private func _tearDownDeleteClub() async throws {
        let clubId = TestProperty.shared.testClub.id
        let callItem = FFDeleteTestClubCall(clubId: clubId)
        try await FirebaseFunctionCaller.shared.call(callItem)
    }

    /// Check if test club is deleted
    private func _tearDownCheckClub() async throws {
        do {
            let clubId = TestProperty.shared.testClub.id
            _ = try await FirebaseFetcher.shared.fetch(TestClub.Properties.self, url: nil, clubId: clubId)
            XCTFail() // swiftlint:disable:this xctfail_message
        } catch {
            XCTAssertEqual(error as? FirebaseFetcher.FetchError, .noData)
        }
    }
}

// MARK: new club call
/// Test all functions of NewClubCall
extension FirebaseFunctionCallerTests {

    /// Test new club call
    func testNewClubCall() async throws {

        // Check identifier, name and region code of test club
        try await _testNewClubCallCheckIdentiferNameRegionCode()

        // Create new club with already existing identifier
        try await _testNewClubCallExistingIdentifier()

        // Create new club with same id but different identifier
        try await _testNewClubCallSameId()

        // Delete club and check if it's deleted
        try await _testNewClubCallDeleteClub()

        // Create club with person with only first name
        try await _testNewClubCallPersonName()

        // Check statistics
        try await _testNewClubCheckStatistics()
    }

    /// Check identifier, name and region code of test club
    private func _testNewClubCallCheckIdentiferNameRegionCode() async throws {
        let clubId = TestProperty.shared.testClub.id

        // Check identifier
        let identifier = try await FirebaseFetcher.shared.fetch(String.self, url: URL(string: "identifier")!, clubId: clubId)
        XCTAssertEqual(identifier, TestProperty.shared.testClub.identifier)

        // Check name
        let name = try await FirebaseFetcher.shared.fetch(String.self, url: URL(string: "name")!, clubId: clubId)
        XCTAssertEqual(name, TestProperty.shared.testClub.name)

        // Check region code
        let regionCode = try await FirebaseFetcher.shared.fetch(String.self, url: URL(string: "regionCode")!, clubId: clubId)
        XCTAssertEqual(regionCode, TestProperty.shared.testClub.regionCode)

        // Check person user ids
        let url = URL(string: "personUserIds/\(TestProperty.shared.testPersonFirst.userId)")!
        let personId = try await FirebaseFetcher.shared.fetch(String.self, url: url, clubId: clubId)
        XCTAssertEqual(personId, TestProperty.shared.testPersonFirst.id.uuidString)
    }

    /// Create new club with already existing identifier
    private func _testNewClubCallExistingIdentifier() async throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let personId = TestProperty.shared.testPersonFirst.id
        let clubName = TestProperty.shared.testClub.name
        let regionCode = TestProperty.shared.testClub.regionCode
        let clubIdentifier = TestProperty.shared.testClub.identifier
        let signInProperty = SignInProperty.UserIdName(userId: TestProperty.shared.testPersonFirst.userId, name: TestProperty.shared.testPersonFirst.name)
        let callItem = FFNewClubCall(signInProperty: signInProperty, clubId: clubId, personId: personId, clubName: clubName, regionCode: regionCode, clubIdentifier: clubIdentifier, inAppPayment: true)

        // Call function
        do {
            try await FirebaseFunctionCaller.shared.call(callItem)
            XCTFail() // swiftlint:disable:this xctfail_message
        } catch {
            guard let error = error as NSError?, error.domain == FunctionsErrorDomain else { return }
            let errorCode = FunctionsErrorCode(rawValue: error.code)
            XCTAssertEqual(errorCode, .alreadyExists)
        }
    }

    /// Create new club with same id but different identifier
    private func _testNewClubCallSameId() async throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let personId = TestProperty.shared.testPersonFirst.id
        let clubName = TestProperty.shared.testClub.name
        let regionCode = TestProperty.shared.testClub.regionCode
        let clubIdentifier = "different identifier"
        let signInProperty = SignInProperty.UserIdName(userId: TestProperty.shared.testPersonFirst.userId, name: TestProperty.shared.testPersonFirst.name)
        let callItem = FFNewClubCall(signInProperty: signInProperty, clubId: clubId, personId: personId, clubName: clubName, regionCode: regionCode, clubIdentifier: clubIdentifier, inAppPayment: true)

        // Call function
        try await FirebaseFunctionCaller.shared.call(callItem)
        let identifierAfterSameId = try await FirebaseFetcher.shared.fetch(String.self, url: URL(string: "identifier")!, clubId: clubId)
        XCTAssertEqual(identifierAfterSameId, TestProperty.shared.testClub.identifier)
    }

    /// Delete club and check if it's deleted
    private func _testNewClubCallDeleteClub() async throws {
        let clubId = TestProperty.shared.testClub.id
        let callItem = FFDeleteTestClubCall(clubId: clubId)
        try await FirebaseFunctionCaller.shared.call(callItem)

        do {
            _ = try await FirebaseFetcher.shared.fetch(TestClub.Properties.self, url: nil, clubId: clubId)
            XCTFail() // swiftlint:disable:this xctfail_message
        } catch {
            XCTAssertEqual(error as? FirebaseFetcher.FetchError, .noData)
        }
    }

    /// Create club with person with only first name
    private func _testNewClubCallPersonName() async throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let personId = TestProperty.shared.testPersonSecond.id
        let clubName = TestProperty.shared.testClub.name
        let regionCode = TestProperty.shared.testClub.regionCode
        let clubIdentifier = TestProperty.shared.testClub.identifier
        let signInProperty = SignInProperty.UserIdName(userId: TestProperty.shared.testPersonSecond.userId, name: TestProperty.shared.testPersonSecond.name)
        let callItem = FFNewClubCall(signInProperty: signInProperty, clubId: clubId, personId: personId, clubName: clubName, regionCode: regionCode, clubIdentifier: clubIdentifier, inAppPayment: true)

        // Call function
        try await FirebaseFunctionCaller.shared.call(callItem)

        // Check person
        let personList = try await FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId)
        XCTAssertEqual(personList.count, 1)
        XCTAssertEqual(personList.first!.id, TestProperty.shared.testPersonSecond.id)
        XCTAssertEqual(personList.first!.name, TestProperty.shared.testPersonSecond.name)
        XCTAssertEqual(personList.first!.signInData?.isCashier, true)
        XCTAssertEqual(personList.first!.signInData?.userId, TestProperty.shared.testPersonSecond.userId)
    }

    private func _testNewClubCheckStatistics() async throws {
        let statisticList = try await FirebaseFetcher.shared.fetchStatistics(clubId: TestProperty.shared.testClub.id, before: nil, number: 1_000)
        let property = statisticList.lazy
            .sorted { $0.timestamp < $1.timestamp }
            .compactMap { $0.property.rawProperty as? SPNewClub }
            .first
        XCTAssertNotNil(property)
        XCTAssertEqual(property?.identifier, "test-club")
        XCTAssertEqual(property?.inAppPaymentActive, true)
        XCTAssertEqual(property?.name, "Test Club")
        XCTAssertEqual(property?.regionCode, "DE")
        XCTAssertEqual(property?.person.name, TestProperty.shared.testPersonSecond.name)
    }
}

// MARK: late payment interest call
/// Test all functions of LatePaymentInterestCall
extension FirebaseFunctionCallerTests {

    /// Test late payment interest change
    func testLatePaymentInterest() async throws {

        // Set late payment interest
        try await _testLatePaymentInterestSet()

        // Update late payment interest
        try await _testLatePaymentInterestUpdate()

        // Remove late payment interest
        try await _testLatePaymentInterestRemove()

        // Remove late payment interest again
        try await _testLatePaymentInterestRemove()

        // Check statistics
        try await _testChangeLatePaymentInterestCheckStatistics()
    }

    /// Set late payment interest and check it
    private func _testLatePaymentInterestSet(_ _latePaymentInterest: LatePaymentInterest? = nil) async throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let latePaymentInterest1 = _latePaymentInterest ?? TestProperty.shared.testLatePaymentInterestFirst.latePaymentInterest
        let callItem = FFChangeLatePaymentInterestCall(clubId: clubId, interest: latePaymentInterest1)

        // Call function
        try await FirebaseFunctionCaller.shared.call(callItem)

        // Check late payment interest
        let latePaymentInterest2 = try await FirebaseFetcher.shared.fetch(LatePaymentInterest.self, url: URL(string: "latePaymentInterest")!, clubId: clubId)
        XCTAssertEqual(latePaymentInterest2, latePaymentInterest1)
    }

    /// Update late payment interest and check it
    private func _testLatePaymentInterestUpdate() async throws {
        let latePaymentInterest = TestProperty.shared.testLatePaymentInterestSecond.latePaymentInterest
        try await _testLatePaymentInterestSet(latePaymentInterest)
    }

    /// Remove late payment interest and check it
    private func _testLatePaymentInterestRemove() async throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let callItem = FFChangeLatePaymentInterestCall(clubId: clubId)

        // Call function
        try await FirebaseFunctionCaller.shared.call(callItem)

        // Check late payment interest
        do {
            _ = try await FirebaseFetcher.shared.fetch(LatePaymentInterest.self, url: URL(string: "latePaymentInterest")!, clubId: clubId)
            XCTFail() // swiftlint:disable:this xctfail_message
        } catch {
            XCTAssertEqual(error as? FirebaseFetcher.FetchError, .noData)
        }
    }

    /// Checks statistics of change late payment interest
    func _testChangeLatePaymentInterestCheckStatistics() async throws {
        let statisticList = try await FirebaseFetcher.shared.fetchStatistics(clubId: TestProperty.shared.testClub.id, before: nil, number: 1_000)
        let propertyList = statisticList.lazy
            .sorted { $0.timestamp < $1.timestamp }
            .compactMap { $0.property.rawProperty as? SPChangeLatePaymentInterest }
        XCTAssertEqual(propertyList.count, 4)

        // Check first interest
        XCTAssertNil(propertyList[0].previousInterest)
        XCTAssertEqual(propertyList[0].changedInterest, TestProperty.shared.testLatePaymentInterestFirst.latePaymentInterest)

        // Check second interest
        XCTAssertEqual(propertyList[1].previousInterest, TestProperty.shared.testLatePaymentInterestFirst.latePaymentInterest)
        XCTAssertEqual(propertyList[1].changedInterest, TestProperty.shared.testLatePaymentInterestSecond.latePaymentInterest)

        // Check third interest
        XCTAssertEqual(propertyList[2].previousInterest, TestProperty.shared.testLatePaymentInterestSecond.latePaymentInterest)
        XCTAssertNil(propertyList[2].changedInterest)

        // Check fourth interest
        XCTAssertNil(propertyList[3].previousInterest)
        XCTAssertNil(propertyList[3].changedInterest)
    }
}

// MARK: register person call
/// Test all functions of RegisterPersonCall
extension FirebaseFunctionCallerTests {

    /// Test register person
    func testRegisterPerson() async throws {

        // Register person
        try await _testRegisterPerson(TestProperty.shared.testPersonFirst.name)

        // Register person with same id, but only first name
        try await _testRegisterPerson(TestProperty.shared.testPersonSecond.name)

        // Check statistics
        try await _testRegisterPersonCheckStatistics()
    }

    /// Register person and check it
    private func _testRegisterPerson(_ personName: PersonName) async throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let personId = TestProperty.shared.testPersonSecond.id
        let userId = TestProperty.shared.testPersonSecond.userId
        let signInProperty = SignInProperty.UserIdNameClubId(.init(userId: userId, name: personName), clubId: clubId)
        let callItem = FFRegisterPersonCall(signInProperty: signInProperty, personId: personId)

        // Call function
        let callResult = try await FirebaseFunctionCaller.shared.call(callItem)
        XCTAssertEqual(callResult.clubIdentifier, TestProperty.shared.testClub.identifier)
        XCTAssertEqual(callResult.clubName, TestProperty.shared.testClub.name)
        XCTAssertEqual(callResult.regionCode, TestProperty.shared.testClub.regionCode)
        XCTAssertEqual(callResult.inAppPaymentActive, true)

        // Check person properties
        let personList = try await FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId)
        let person = personList.first { $0.id == personId }
        XCTAssertEqual(person?.name, personName)
        XCTAssertEqual(person?.signInData?.isCashier, false)
        XCTAssertEqual(person?.signInData?.userId, userId)

        // Check person user ids
        let url = URL(string: "personUserIds/\(TestProperty.shared.testPersonSecond.userId)")!
        let userId2 = try await FirebaseFetcher.shared.fetch(String.self, url: url, clubId: clubId)
        XCTAssertEqual(userId2, TestProperty.shared.testPersonSecond.id.uuidString)
    }

    /// Checks statistics of change late payment interest
    func _testRegisterPersonCheckStatistics() async throws {
        let statisticList = try await FirebaseFetcher.shared.fetchStatistics(clubId: TestProperty.shared.testClub.id, before: nil, number: 1_000)
        let propertyList = statisticList.lazy
            .sorted { $0.timestamp < $1.timestamp }
            .compactMap { $0.property.rawProperty as? SPRegisterPerson }
        XCTAssertEqual(propertyList.count, 2)
        XCTAssertEqual(propertyList[0].person.name, TestProperty.shared.testPersonFirst.name)
        XCTAssertEqual(propertyList[1].person.name, TestProperty.shared.testPersonSecond.name)
    }
}

// MARK: force sign out call
/// Test all functions of ForceSignOutCall
extension FirebaseFunctionCallerTests {

    /// Test force sign out
    func testForceSignOut() async throws {

        // Call item
        let personId = TestProperty.shared.testPersonFirst.id
        let clubId = TestProperty.shared.testClub.id
        let callItem = FFForceSignOutCall(clubId: clubId, personId: personId)

        // Call function
        try await FirebaseFunctionCaller.shared.call(callItem)

        // Check sign in data
        do {
            _ = try await FirebaseFetcher.shared.fetch(FirebasePerson.SignInData.self, url: URL(string: "persons/\(personId)/signInData")!, clubId: clubId)
            XCTFail() // swiftlint:disable:this xctfail_message
        } catch {
            XCTAssertEqual(error as? FirebaseFetcher.FetchError, .noData)
        }
    }
}

// MARK: change list call with person
/// Test all functions of ChangeListCall with person
extension FirebaseFunctionCallerTests {

    /// Test change list person
    func testChangeListPerson() async throws {

        // Set person
        try await _testChangeListPersonSet()

        // Update person
        try await _testChangeListPersonUpdate()

        // Delete person
        try  await _testChangeListPersonDelete()

        // Delete person again
        try await _testChangeListPersonDelete()

        // Delete registered person
        try await _testChangeListPersonDeleteRegistered()

        // Set person with only first name
        try await _testChangeListPersonFirstName()

        // Update not existing person
        try await _testChangeListPersonUpdate()
    }

    /// Set person and check it
    func _testChangeListPersonSet() async throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let person = TestProperty.shared.testPersonThird.person
        let callItem = FFChangeListCall(clubId: clubId, item: person)

        // Call function
        try await FirebaseFunctionCaller.shared.call(callItem)

        // Check person
        let personList = try await FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId)
        let fetchedPerson = personList.first { $0.id == person.id }
        XCTAssertEqual(fetchedPerson?.name, person.name)
        XCTAssertNil(fetchedPerson?.signInData)
    }

    /// Update person and check if
    func _testChangeListPersonUpdate() async throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let personId = TestProperty.shared.testPersonThird.id
        let personName = PersonName(firstName: "abc", lastName: "def")
        let person = FirebasePerson(id: personId, name: personName, signInData: nil)
        let callItem = FFChangeListCall(clubId: clubId, item: person)

        // Call function
        try await FirebaseFunctionCaller.shared.call(callItem)

        // Check person
        let personList = try await FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId)
        let fetchedPerson = personList.first { $0.id == person.id }
        XCTAssertEqual(fetchedPerson?.name, person.name)
        XCTAssertNil(fetchedPerson?.signInData)
    }

    /// Delete person
    func _testChangeListPersonDelete() async throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let person = TestProperty.shared.testPersonThird.person
        let callItem = FFChangeListCall<FirebasePerson>(clubId: clubId, id: person.id)

        // Call function
        try await FirebaseFunctionCaller.shared.call(callItem)

        // Check person
        let personList = try await FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId)
        let fetchedPerson = personList.first { $0.id == person.id }
        XCTAssertNil(fetchedPerson)
    }

    /// Try delete registered person
    func _testChangeListPersonDeleteRegistered() async throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let person = TestProperty.shared.testPersonFirst.person
        let callItem = FFChangeListCall<FirebasePerson>(clubId: clubId, id: person.id)

        // Call function
        do {
            try await FirebaseFunctionCaller.shared.call(callItem)
            XCTFail() // swiftlint:disable:this xctfail_message
        } catch {
            XCTAssertEqual((error as NSError?)?.domain, FunctionsErrorDomain)
            let errorCode = FunctionsErrorCode(rawValue: (error as NSError?)!.code)
            XCTAssertEqual(errorCode, .unavailable)
        }

        // Check person
        let personList = try await FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId)
        let fetchedPerson = personList.first { $0.id == person.id }
        XCTAssertEqual(fetchedPerson?.name, person.name)
        XCTAssertEqual(fetchedPerson?.signInData?.userId, TestProperty.shared.testPersonFirst.userId)
        XCTAssertEqual(fetchedPerson?.signInData?.isCashier, true)
    }

    /// Set person with only first name and check it
    func _testChangeListPersonFirstName() async throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let person = TestProperty.shared.testPersonSecond.person
        let callItem = FFChangeListCall(clubId: clubId, item: person)

        // Call function
        try await FirebaseFunctionCaller.shared.call(callItem)

        // Check person
        let personList = try await FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: clubId)
        let fetchedPerson = personList.first { $0.id == person.id }
        XCTAssertEqual(fetchedPerson?.name, person.name)
        XCTAssertNil(fetchedPerson?.signInData)
    }
}

// MARK: change list call with reason
/// Test all functions of ChangeListCall with reason
extension FirebaseFunctionCallerTests {

    /// Test change list reason
    func testChangeListReason() async throws {

        // Set reason
        try await _testChangeListReasonSet()

        // Update reason
        try await _testChangeListReasonUpdate()

        // Delete reason
        try await _testChangeListReasonDelete()

        // Delete reason again
        try await _testChangeListReasonDelete()

        // Update not existing reason
        try await _testChangeListReasonUpdate()
    }

    /// Set reason and check it
    func _testChangeListReasonSet() async throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let reason = TestProperty.shared.testReason.reasonTemplate
        let callItem = FFChangeListCall(clubId: clubId, item: reason)

        // Call function
        try await FirebaseFunctionCaller.shared.call(callItem)

        // Check reason
        let reasonList = try await FirebaseFetcher.shared.fetchList(FirebaseReasonTemplate.self, clubId: clubId)
        let fetchedReason = reasonList.first { $0.id == reason.id }
        XCTAssertEqual(fetchedReason, reason)
    }

    /// Update reason and check if
    func _testChangeListReasonUpdate() async throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let reason = TestProperty.shared.testReason.updatedReasonTemplate
        let callItem = FFChangeListCall(clubId: clubId, item: reason)

        // Call function
        try await FirebaseFunctionCaller.shared.call(callItem)

        // Check reason
        let reasonList = try await FirebaseFetcher.shared.fetchList(FirebaseReasonTemplate.self, clubId: clubId)
        let fetchedReason = reasonList.first { $0.id == reason.id }
        XCTAssertEqual(fetchedReason, reason)
    }

    /// Delete reason
    func _testChangeListReasonDelete() async throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let reason = TestProperty.shared.testReason.updatedReasonTemplate
        let callItem = FFChangeListCall<FirebaseReasonTemplate>(clubId: clubId, id: reason.id)

        // Call function
        try await FirebaseFunctionCaller.shared.call(callItem)

        // Check reason
        let reasonList = try await FirebaseFetcher.shared.fetchList(FirebaseReasonTemplate.self, clubId: clubId)
        let fetchedReason = reasonList.first { $0.id == reason.id }
        XCTAssertNil(fetchedReason)
    }
}

// MARK: change list call with fine
/// Test all functions of ChangeListCall with fine
extension FirebaseFunctionCallerTests {

    /// Test change list fine
    func testChangeListFine() async throws {

        // Set fine with template id
        try await _testChangeListFineSet()

        // Update fine with reason, importance and amount
        try await _testChangeListFineUpdateCustomReason()

        // Delete fine
        try await _testChangeListFineDelete()

        // Delete fine again
        try await _testChangeListFineDelete()

        // Update not exsisting fine with reason, importance and amount
        try await _testChangeListFineUpdateCustomReason()

        // Update fine with template id
        try await _testChangeListFineUpdateTemplateReason()
    }

    /// Set fine and check it
    func _testChangeListFineSet() async throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let fine = TestProperty.shared.testFine.withReasonTemplate
        let callItem = FFChangeListCall(clubId: clubId, item: fine)

        // Call function
        try await FirebaseFunctionCaller.shared.call(callItem)

        // Check fine
        let fineList = try await FirebaseFetcher.shared.fetchList(FirebaseFine.self, clubId: clubId)
        let fetchedFine = fineList.first { $0.id == fine.id }
        XCTAssertEqual(fetchedFine, fine)
    }

    /// Update fine with custom reason and check if
    func _testChangeListFineUpdateCustomReason() async throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let fine = TestProperty.shared.testFine.withReasonCustom
        let callItem = FFChangeListCall(clubId: clubId, item: fine)

        // Call function
        try await FirebaseFunctionCaller.shared.call(callItem)

        // Check fine
        let fineList = try await FirebaseFetcher.shared.fetchList(FirebaseFine.self, clubId: clubId)
        let fetchedFine = fineList.first { $0.id == fine.id }
        XCTAssertEqual(fetchedFine, fine)
    }

    /// Delete fine
    func _testChangeListFineDelete() async throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let fine = TestProperty.shared.testFine.withReasonCustom
        let callItem = FFChangeListCall<FirebaseFine>(clubId: clubId, id: fine.id)

        // Call function
        try await FirebaseFunctionCaller.shared.call(callItem)

        // Check fine
        let fineList = try await FirebaseFetcher.shared.fetchList(FirebaseFine.self, clubId: clubId)
        let fetchedFine = fineList.first { $0.id == fine.id }
        XCTAssertNil(fetchedFine)
    }

    /// Update fine with template reason and check if
    func _testChangeListFineUpdateTemplateReason() async throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let fine = TestProperty.shared.testFine.withReasonTemplate
        let callItem = FFChangeListCall(clubId: clubId, item: fine)

        // Call function
        try await FirebaseFunctionCaller.shared.call(callItem)

        // Check fine
        let fineList = try await FirebaseFetcher.shared.fetchList(FirebaseFine.self, clubId: clubId)
        let fetchedFine = fineList.first { $0.id == fine.id }
        XCTAssertEqual(fetchedFine, fine)
    }
}

// MARK: change fine payed call
/// Test all functions of ChangeFinePayedCall
extension FirebaseFunctionCallerTests {

    /// Test change fine payed
    func testChangeFinePayed() async throws {

        // Change payed of not existing fine
        try await _testChangeFinePayedNoFine()

        // Add fines and reason
        try await _testChangeFinePayedAddFinesAndReason()

        // Change to payed
        try await _testChangeFinePayed(.payed(date: Date(timeIntervalSinceReferenceDate: 12345), inApp: false))

        // Change to payed
        try await _testChangeFinePayed(.payed(date: Date(timeIntervalSinceReferenceDate: 54321), inApp: true))

        // Change to unpayed
        try await _testChangeFinePayed(.unpayed)

        // Change to settled
        try await _testChangeFinePayed(.settled)

        // Checks statistics
        try await _testChangeFinePayedCheckStatistics()
    }

    /// Change payed of not existing fine
    func _testChangeFinePayedNoFine() async throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let fineId = TestProperty.shared.testFine.withReasonTemplate.id
        let payed: Payed = .unpayed
        let callItem = FFChangeFinePayed(clubId: clubId, fineId: fineId, newState: payed)

        // Call function
        do {
            try await FirebaseFunctionCaller.shared.call(callItem)
            XCTFail() // swiftlint:disable:this xctfail_message
        } catch {
            XCTAssertEqual((error as NSError).domain, FunctionsErrorDomain)
            XCTAssertEqual(FunctionsErrorCode(rawValue: (error as NSError).code), .failedPrecondition)
        }
    }

    /// Add fines and reason for test change fine payed
    func _testChangeFinePayedAddFinesAndReason() async throws {

        // Add fine with reason template
        let clubId = TestProperty.shared.testClub.id
        let fine1 = TestProperty.shared.testFine.withReasonTemplate
        let callItem1 = FFChangeListCall(clubId: clubId, item: fine1)
        try await FirebaseFunctionCaller.shared.call(callItem1)

        // Add fine with custom reason
        let fine2 = TestProperty.shared.testFine2.withReasonCustom
        let callItem2 = FFChangeListCall(clubId: clubId, item: fine2)
        try await FirebaseFunctionCaller.shared.call(callItem2)

        // Add reason
        let reason = FirebaseReasonTemplate(id: (fine1.fineReason as! FineReasonTemplate).templateId, // swiftlint:disable:this force_cast
                                            reason: "asldkfj", importance: .low, amount: Amount(12, subUnit: 98))
        let callItem3 = FFChangeListCall(clubId: clubId, item: reason)
        try await FirebaseFunctionCaller.shared.call(callItem3)

        // Check fines and reason
        let fineList: [FirebaseFine] = try await FirebaseFetcher.shared.fetchList(clubId: clubId)
        let fetchedFine1 = fineList.first { $0.id == fine1.id }
        let fetchedFine2 = fineList.first { $0.id == fine2.id }
        XCTAssertEqual(fetchedFine1, fine1)
        XCTAssertEqual(fetchedFine2, fine2)

        let reasonList: [FirebaseReasonTemplate] = try await FirebaseFetcher.shared.fetchList(clubId: clubId)
        let fetchedReason = reasonList.first { $0.id == reason.id }
        XCTAssertEqual(fetchedReason, reason)
    }

    /// Change to unpayed
    func _testChangeFinePayed(_ state: Payed) async throws {

        // Call item
        let clubId = TestProperty.shared.testClub.id
        let fineId = state.state == "payed" ? TestProperty.shared.testFine.withReasonTemplate.id : TestProperty.shared.testFine2.withReasonCustom.id
        let callItem = FFChangeFinePayed(clubId: clubId, fineId: fineId, newState: state)

        // Call function
        try await FirebaseFunctionCaller.shared.call(callItem)

        // Check payed
        let fineList = try await FirebaseFetcher.shared.fetchList(FirebaseFine.self, clubId: clubId)
        let fetchedFine = fineList.first { $0.id == fineId }
        XCTAssertEqual(fetchedFine?.payed, state)
    }

    /// Checks statistics of change fine payed
    func _testChangeFinePayedCheckStatistics() async throws { // swiftlint:disable:this function_body_length
        let statisticList = try await FirebaseFetcher.shared.fetchStatistics(clubId: TestProperty.shared.testClub.id, before: nil, number: 1_000)
        let propertyList = statisticList.lazy
            .sorted { $0.timestamp < $1.timestamp }
            .compactMap { $0.property.rawProperty as? SPChangeFinePayed }
        XCTAssertEqual(propertyList.count, 4)

        // Check first statistic
        XCTAssertEqual(propertyList[0].changedState.state, "payed")
        XCTAssertEqual(propertyList[0].changedState.payedInApp, false)
        XCTAssertEqual(propertyList[0].previousFine.id, FirebaseFine.ID(rawValue: UUID(uuidString: "637D6187-68D2-4000-9CB8-7DFC3877D5BA")!))
        XCTAssertEqual(propertyList[0].previousFine.person.id, FirebasePerson.ID(rawValue: UUID(uuidString: "5BF1FFDA-4F69-11EB-AE93-0242AC130002")!))
        XCTAssertEqual(propertyList[0].previousFine.person.name, PersonName(firstName: "First Person First Name", lastName: "First Person Last Name"))
        XCTAssertEqual(propertyList[0].previousFine.payed, .unpayed)
        XCTAssertEqual(propertyList[0].previousFine.number, 2)
        XCTAssertEqual(propertyList[0].previousFine.reason.id, FirebaseReasonTemplate.ID(rawValue: UUID(uuidString: "9d0681f0-2045-4a1d-abbc-6bb289934ff9")!))
        XCTAssertEqual(propertyList[0].previousFine.reason.reason, "asldkfj")
        XCTAssertEqual(propertyList[0].previousFine.reason.amount, Amount(12, subUnit: 98))
        XCTAssertEqual(propertyList[0].previousFine.reason.importance, .low)

        // Check second statistic
        XCTAssertEqual(propertyList[1].changedState.state, "payed")
        XCTAssertEqual(propertyList[1].changedState.payedInApp, true)
        XCTAssertEqual(propertyList[1].previousFine.id, FirebaseFine.ID(rawValue: UUID(uuidString: "637D6187-68D2-4000-9CB8-7DFC3877D5BA")!))
        XCTAssertEqual(propertyList[1].previousFine.person.id, FirebasePerson.ID(rawValue: UUID(uuidString: "5BF1FFDA-4F69-11EB-AE93-0242AC130002")!))
        XCTAssertEqual(propertyList[1].previousFine.person.name, PersonName(firstName: "First Person First Name", lastName: "First Person Last Name"))
        XCTAssertEqual(propertyList[1].previousFine.payed.state, "payed")
        XCTAssertEqual(propertyList[1].previousFine.payed.payedInApp, false)
        XCTAssertEqual(propertyList[1].previousFine.number, 2)
        XCTAssertEqual(propertyList[1].previousFine.reason.id, FirebaseReasonTemplate.ID(rawValue: UUID(uuidString: "9d0681f0-2045-4a1d-abbc-6bb289934ff9")!))
        XCTAssertEqual(propertyList[1].previousFine.reason.reason, "asldkfj")
        XCTAssertEqual(propertyList[1].previousFine.reason.amount, Amount(12, subUnit: 98))
        XCTAssertEqual(propertyList[1].previousFine.reason.importance, .low)

        // Check third statistic
        XCTAssertEqual(propertyList[2].changedState, .unpayed)
        XCTAssertEqual(propertyList[2].previousFine.id, FirebaseFine.ID(rawValue: UUID(uuidString: "137D6187-68D2-4000-9CB8-7DFC3877D5BA")!))
        XCTAssertEqual(propertyList[2].previousFine.person.id, FirebasePerson.ID(rawValue: UUID(uuidString: "5BF1FFDA-4F69-11EB-AE93-0242AC130002")!))
        XCTAssertEqual(propertyList[2].previousFine.person.name, PersonName(firstName: "First Person First Name", lastName: "First Person Last Name"))
        XCTAssertEqual(propertyList[2].previousFine.payed.state, "payed")
        XCTAssertEqual(propertyList[2].previousFine.payed.payedInApp, false)
        XCTAssertEqual(propertyList[2].previousFine.number, 10)
        XCTAssertEqual(propertyList[2].previousFine.reason.reason, "Reason")
        XCTAssertEqual(propertyList[2].previousFine.reason.amount, Amount(1, subUnit: 50))
        XCTAssertEqual(propertyList[2].previousFine.reason.importance, .high)

        // Check fourth statistic
        XCTAssertEqual(propertyList[3].changedState, .settled)
        XCTAssertEqual(propertyList[3].previousFine.id, FirebaseFine.ID(rawValue: UUID(uuidString: "137D6187-68D2-4000-9CB8-7DFC3877D5BA")!))
        XCTAssertEqual(propertyList[3].previousFine.person.id, FirebasePerson.ID(rawValue: UUID(uuidString: "5BF1FFDA-4F69-11EB-AE93-0242AC130002")!))
        XCTAssertEqual(propertyList[3].previousFine.person.name, PersonName(firstName: "First Person First Name", lastName: "First Person Last Name"))
        XCTAssertEqual(propertyList[3].previousFine.payed, .unpayed)
        XCTAssertEqual(propertyList[3].previousFine.number, 10)
        XCTAssertEqual(propertyList[3].previousFine.reason.reason, "Reason")
        XCTAssertEqual(propertyList[3].previousFine.reason.amount, Amount(1, subUnit: 50))
        XCTAssertEqual(propertyList[3].previousFine.reason.importance, .high)
    }
}

// MARK: get person properties call
/// Test all functions of GetPersonPropertiesCall
extension FirebaseFunctionCallerTests {

    /// Test get person properties
    func testGetPersonProperties() async throws {

        // Try to get properties of not existing person
        try await _testGetPersonPropertiesNotExistingPerson()

        // Get properties of person
        let firstPerson = TestProperty.shared.testPersonFirst
        try await _testGetPersonPropertiesPerson(firstPerson.userId, person: firstPerson.person, isCashier: true)

        // Register person with only first name
        try await _testRegisterPerson(TestProperty.shared.testPersonSecond.name)
    }

    /// With not existing person
    func _testGetPersonPropertiesNotExistingPerson() async throws {

        // Call item
        let userId = TestProperty.shared.testPersonThird.userId
        let callItem = FFGetPersonPropertiesCall(userId: userId)

        // Call function
        do {
            _ = try await FirebaseFunctionCaller.shared.call(callItem)
            XCTFail() // swiftlint:disable:this xctfail_message
        } catch {
            XCTAssertEqual((error as NSError?)?.domain, FunctionsErrorDomain)
            let errorCode = FunctionsErrorCode(rawValue: (error as NSError?)!.code)
            XCTAssertEqual(errorCode, .notFound)
        }
    }

    /// Get properties of person
    func _testGetPersonPropertiesPerson(_ userId: String, person: FirebasePerson, isCashier: Bool) async throws {

        // Call item
        let callItem = FFGetPersonPropertiesCall(userId: userId)

        // Call function
        let properties = try await FirebaseFunctionCaller.shared.call(callItem)

        // Check properties
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
    func testGetClubId() async throws {

        // Try to get club id of not existing club
        try await _testGetClubIdNotExistingClub()

        // Get id of club
        try await _testGetClubIdClub()
    }

    /// With not existing club
    func _testGetClubIdNotExistingClub() async throws {

        // Call item
        let callItem = FFGetClubIdCall(identifier: "asdf")

        // Call function
        do {
            _ = try await FirebaseFunctionCaller.shared.call(callItem)
            XCTFail() // swiftlint:disable:this xctfail_message
        } catch {
            XCTAssertEqual((error as NSError?)?.domain, FunctionsErrorDomain)
            let errorCode = FunctionsErrorCode(rawValue: (error as NSError?)!.code)
            XCTAssertEqual(errorCode, .notFound)
        }
    }

    /// Get properties of person
    func _testGetClubIdClub() async throws {

        // Call item
        let identifier = TestProperty.shared.testClub.identifier
        let callItem = FFGetClubIdCall(identifier: identifier)

        // Call function
        let result = try await FirebaseFunctionCaller.shared.call(callItem)
        XCTAssertEqual(result, TestProperty.shared.testClub.id)
    }
}

// MARK: club identifier already exists call
/// Test all functions of ClubIdentifierAlreadyExistsCall
extension FirebaseFunctionCallerTests {

    /// Test exists club with identifier
    func testExistsClubWithIdentifier() async throws {

        // Of not existing club
        try await _testExistsClubWithIdentifierNotExisting()

        // Of existing club
        try await _testExistsClubWithIdentifierExisting()
    }

    /// Of not existing club
    func _testExistsClubWithIdentifierNotExisting() async throws {

        // Call item
        let callItem = FFExistsClubWithIdentifierCall(identifier: "asdf")

        // Call function
        let result = try await FirebaseFunctionCaller.shared.call(callItem)
        XCTAssertFalse(result)
    }

    /// Of existing club
    func _testExistsClubWithIdentifierExisting() async throws {

        // Call item
        let identifier = TestProperty.shared.testClub.identifier
        let callItem = FFExistsClubWithIdentifierCall(identifier: identifier)

        // Call function
        let result = try await FirebaseFunctionCaller.shared.call(callItem)
        XCTAssertTrue(result)
    }
}

// MARK: exists person properties call
/// Test all functions of GetPersonPropertiesCall
extension FirebaseFunctionCallerTests {

    /// Test exists person with user id
    func testExistsPersonWithUserId() async throws {

        // Of not existing person
        try await _testExistsPersonWithUserIdNotExisting()

        // Of existing person
        try await _testExistsPersonWithUserIdExisting()
    }

    /// Of not existing person
    func _testExistsPersonWithUserIdNotExisting() async throws {

        // Call item
        let callItem = FFExistsPersonWithUserIdCall(userId: "asdf")

        // Call function
        let result = try await FirebaseFunctionCaller.shared.call(callItem)
        XCTAssertFalse(result)
    }

    /// Of existing person
    func _testExistsPersonWithUserIdExisting() async throws {

        // Call item
        let userId = TestProperty.shared.testPersonFirst.userId
        let callItem = FFExistsPersonWithUserIdCall(userId: userId)

        // Call function
        let result = try await FirebaseFunctionCaller.shared.call(callItem)
        XCTAssertTrue(result)
    }
}
