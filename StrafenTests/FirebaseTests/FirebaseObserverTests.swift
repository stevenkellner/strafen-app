//
//  FirebaseObserverTests.swift
//  StrafenTests
//
//  Created by Steven on 06.05.21.
//

import XCTest
import FirebaseFunctions
import FirebaseAuth
@testable import Strafen

// swiftlint:disable identifier_name
class FirebaseObserverTests: XCTestCase {

    let clubId = Club.ID(rawValue: UUID(uuidString: "d7b3c296-54cb-4417-8824-ecee22eb5eaf")!)

    // MARK: set up

    override func setUpWithError() throws {
        continueAfterFailure = false
        FirebaseFunctionCaller.shared.level = .testing
        FirebaseFetcher.shared.level = .testing
        FirebaseObserver.shared.level = .testing

        // Sign test user in
        let signInError: Error? = try waitExpectation { handler in
            Auth.auth().signIn(withEmail: "app.demo@web.de", password: "Demopw12") { _, error in
                handler(error)
            }
        }
        XCTAssertNil(signInError)

        // Delete old test club
        try _setUpDeleteOldTestClub()

        // Create new test club
        try _setUpCreateNewTestClub()

        // Check test club
        try _setUpCheckTestClub()
    }

    /// Set up: deletes old test club
    func _setUpDeleteOldTestClub() throws {
        let result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            let callItem = FFDeleteTestClubCall(clubId: clubId)
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        _ = try result.get()
    }

    /// Set up: creates new test club
    func _setUpCreateNewTestClub() throws {
        let result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            let callItem = FFNewTestClubCall(clubId: clubId, testClubType: .fetcherTestClub)
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        _ = try result.get()
    }

    /// Set up: Check test club
    func _setUpCheckTestClub() throws {
        let result: Result<TestClub, Error> = try waitExpectation { handler in
            FirebaseFetcher.shared.fetchClub(clubId).thenResult(handler)
        }
        let club = try result.get()
        XCTAssertEqual(club, TestClub.fetcherTestClub)
    }

    // MARK: tear down

    override func tearDownWithError() throws {

        // Delete created test club (same as delete old test club in setUp)
        try _setUpDeleteOldTestClub()
    }

    // MARK: observe object

    /// Test observe object
    func testObserveObject() throws {

        // Observe primitive type
        try _testObserveObjectPrimitiveType()

        // Observe removed observer
        try _testObserveObjectRemovedObserver()

        // Observe primitive type with wrong type
        try _testObserveObjectWrongTypePrimitiveType()

        // Observe object
        try _testObserveObjectObject()

        // Observe object with wrong type
        try _testObserveObjectWrongTypeObject()
    }

    /// Test observe object: observe primitive type
    func _testObserveObjectPrimitiveType() throws {

        // Observe value added
        try _testObserveObjectPrimitiveTypeAdded()

        // Observe value changed
        try _testObserveObjectPrimitiveTypeChanged()

        // Observe value removed
        try _testObserveObjectPrimitiveTypeRemoved()
    }

    /// Test observe object: observe primitive type added
    func _testObserveObjectPrimitiveTypeAdded() throws {
        var removeObserver: (() -> Void)?
        let observedResult: String = try waitExpectation { handler in
            removeObserver = FirebaseObserver.shared.observe(String.self, url: URL(string: "stringKey")!, clubId: clubId, onChange: handler)
            let callItem = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "stringKey")!, property: "value")
            FirebaseFunctionCaller.shared.call(callItem).thenResult { result in
                XCTAssertNil(result.error)
            }
        }
        if let removeObserver = removeObserver { removeObserver() }
        XCTAssertEqual(observedResult, "value")
    }

    /// Test observe object: observe primitive type changed
    func _testObserveObjectPrimitiveTypeChanged() throws {
        var removeObserver: (() -> Void)?
        let observedResult: String = try waitExpectation { handler in
            var numberObserved = 0
            removeObserver =  FirebaseObserver.shared.observe(String.self, url: URL(string: "stringKey")!, clubId: clubId) { value in
                numberObserved += 1
                guard numberObserved != 1 else { return }
                handler(value)
            }
            let callItem = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "stringKey")!, property: "newValue")
            FirebaseFunctionCaller.shared.call(callItem).thenResult { result in
                XCTAssertNil(result.error)
            }
        }
        if let removeObserver = removeObserver { removeObserver() }
        XCTAssertEqual(observedResult, "newValue")
    }

    /// Test observe object: observe primitive type removed
    func _testObserveObjectPrimitiveTypeRemoved() throws {
        var removeObserver: (() -> Void)?
        waitExpectation { handler in
            removeObserver = FirebaseObserver.shared.observe(String.self, url: URL(string: "stringKey")!, clubId: clubId, onRemove: handler)
            let callItem = FFDeleteTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "stringKey")!)
            FirebaseFunctionCaller.shared.call(callItem).thenResult { result in
                XCTAssertNil(result.error)
            }
        }
        if let removeObserver = removeObserver { removeObserver() }
    }

    /// Test observe object: observe removed observer
    func _testObserveObjectRemovedObserver() throws {
        var numberExecuted = 0
        let removeObserver = FirebaseObserver.shared.observe(String.self, url: URL(string: "otherKey")!, clubId: clubId) { value in
            XCTAssertEqual(value, "value")
            numberExecuted += 1
        }

        // Set value
        var result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            let setValueCallItem = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "otherKey")!, property: "value")
            FirebaseFunctionCaller.shared.call(setValueCallItem).thenResult(handler)
        }
        _ = try result.get()

        wait(1)

        // Remove observer
        removeObserver()

        // Update value
        result = try waitExpectation { handler in
            let changeValueCallItem = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "otherKey")!, property: "newValue")
            FirebaseFunctionCaller.shared.call(changeValueCallItem).thenResult(handler)
        }
        _ = try result.get()

        // Still wait 10sec for observed value
        wait(10)

        XCTAssertEqual(numberExecuted, 1)
    }

    /// Test observe object: observe wrong type primitive type
    func _testObserveObjectWrongTypePrimitiveType() throws {

        // Try observe bool as string
        waitNoData(timeout: 10) { handler in
            FirebaseObserver.shared.observe(String.self, url: URL(string: "inAppPaymentActive")!, clubId: clubId, onChange: handler)
        }

        // Try observe object as string
        waitNoData(timeout: 10) { handler in
            FirebaseObserver.shared.observe(String.self, url: URL(string: "fines/02462A8B-107F-4BAE-A85B-EFF1F727C00F")!, clubId: clubId, onChange: handler)
        }
    }

    /// Test observe object: observe object
    func _testObserveObjectObject() throws {
        var removeObserver: (() -> Void)?
        let observedResult: PersonName = try waitExpectation { handler in
            var numberObserved = 0
            removeObserver =  FirebaseObserver.shared.observe(PersonName.self, url: URL(string: "persons/D1852AC0-A0E2-4091-AC7E-CB2C23F708D9/name")!, clubId: clubId) { value in
                numberObserved += 1
                guard numberObserved != 1 else { return }
                handler(value)
            }
            let callItem = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "persons/D1852AC0-A0E2-4091-AC7E-CB2C23F708D9/name/first")!, property: "new First Name")
            FirebaseFunctionCaller.shared.call(callItem).thenResult { result in
                XCTAssertNil(result.error)
            }
        }
        if let removeObserver = removeObserver { removeObserver() }
        XCTAssertEqual(observedResult.firstName, "new First Name")
    }

    /// Test observe object: fetch wrong type object
    func _testObserveObjectWrongTypeObject() throws {

        // Try fetch string as object
        var removeObserver1: (() -> Void)?
        waitNoData(timeout: 10) { handler in
            removeObserver1 = FirebaseObserver.shared.observe(FirebasePerson.self, url: URL(string: "identifier")!, clubId: clubId, onChange: handler)
        }
        if let removeObserver1 = removeObserver1 { removeObserver1() }

        // Try fetch object as object
        var removeObserver2: (() -> Void)?
        waitNoData(timeout: 10) { handler in
            removeObserver2 = FirebaseObserver.shared.observe(FirebasePerson.self, url: URL(string: "fines/02462A8B-107F-4BAE-A85B-EFF1F727C00F")!, clubId: clubId, onChange: handler)
        }
        if let removeObserver2 = removeObserver2 { removeObserver2() }
    }

    // MARK: observe list

    /// Test observe list
    func testObserveList() throws {

        // Observe list
        try _testObserveList()

        // Observe list removed observer
        try _testObserveListRemovedObserver()

        // Observe list with wrong type
        // try _testObserveListWrongType()
    }

    /// Test observe list
    func _testObserveList() throws {

        // Observe value added
        try _testObserveListChildAdded()

        // Observe value changed
        try _testObserveListChildChanged()

        // Observe value removed
        try _testObserveListChildRemoved()

    }

    /// Test observe list: child added
    func _testObserveListChildAdded() throws {
        var removeObserver: (() -> Void)?
        let observedResult: FirebasePerson = try waitExpectation { handler in
            var numberObserved = 0
            removeObserver = FirebaseObserver.shared.observeList(FirebasePerson.self, event: .childAdded, clubId: clubId) { value in
                numberObserved += 1
                guard numberObserved > 3 else { return }
                handler(value)
            }
            let callItem = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "persons/13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!, property: ["name": ["first": "firstName", "last": "lastName"]])
            FirebaseFunctionCaller.shared.call(callItem).thenResult { result in
                XCTAssertNil(result.error)
            }
        }
        if let removeObserver = removeObserver { removeObserver() }
        XCTAssertEqual(observedResult, FirebasePerson(id: FirebasePerson.ID(rawValue: UUID(uuidString: "13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!), name: PersonName(firstName: "firstName", lastName: "lastName"), signInData: nil))
    }

    /// Test observe list: child changed
    func _testObserveListChildChanged() throws {
        var removeObserver: (() -> Void)?
        let observedResult: FirebasePerson = try waitExpectation { handler in
            removeObserver = FirebaseObserver.shared.observeList(FirebasePerson.self, event: .childChanged, clubId: clubId, handler: handler)
            let callItem = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "persons/13BC2D6B-13FE-4874-AFD9-8351FB79B5D5/name/first")!, property: "newFirstName")
            FirebaseFunctionCaller.shared.call(callItem).thenResult { result in
                XCTAssertNil(result.error)
            }
        }
        if let removeObserver = removeObserver { removeObserver() }
        XCTAssertEqual(observedResult, FirebasePerson(id: FirebasePerson.ID(rawValue: UUID(uuidString: "13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!), name: PersonName(firstName: "newFirstName", lastName: "lastName"), signInData: nil))
    }

    /// Test observe list: child removed
    func _testObserveListChildRemoved() throws {
        var removeObserver: (() -> Void)?
        let observedResult: FirebasePerson = try waitExpectation { handler in
            removeObserver = FirebaseObserver.shared.observeList(FirebasePerson.self, event: .childRemoved, clubId: clubId, handler: handler)
            let callItem = FFDeleteTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "persons/13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!)
            FirebaseFunctionCaller.shared.call(callItem).thenResult { result in
                XCTAssertNil(result.error)
            }
        }
        if let removeObserver = removeObserver { removeObserver() }
        XCTAssertEqual(observedResult, FirebasePerson(id: FirebasePerson.ID(rawValue: UUID(uuidString: "13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!), name: PersonName(firstName: "newFirstName", lastName: "lastName"), signInData: nil))
    }

    /// Test observe list: removed observer
    func _testObserveListRemovedObserver() throws {
        var numberExecuted = 0
        let removeObserver = FirebaseObserver.shared.observeList(FirebasePerson.self, event: .childChanged, clubId: clubId) { value in
            XCTAssertEqual(value, FirebasePerson(id: FirebasePerson.ID(rawValue: UUID(uuidString: "D1852AC0-A0E2-4091-AC7E-CB2C23F708D9")!), name: PersonName(firstName: "first", lastName: "Doe"), signInData: nil))
            numberExecuted += 1
        }

        // Update value
        var result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            let callItem = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "persons/D1852AC0-A0E2-4091-AC7E-CB2C23F708D9/name/first")!, property: "first")
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        _ = try result.get()

        wait(1)

        // Remove observer
        removeObserver()

        // Update value
        result = try waitExpectation { handler in
            let callItem = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "persons/D1852AC0-A0E2-4091-AC7E-CB2C23F708D9/name/last")!, property: "last")
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        _ = try result.get()

        // Still wait 10sec for observed value
        wait(10)

        XCTAssertEqual(numberExecuted, 1)
    }

    /// Test observe list: wrong type
    func _testObserveListWrongType() throws {

        // Set non person list to person list
        let result: Result<HTTPSCallableResult, Error> = try waitExpectation { handler in
            let callItem = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "persons")!, property: ["id": ["test": "value"]])
            FirebaseFunctionCaller.shared.call(callItem).thenResult(handler)
        }
        _ = try result.get()

        // Try observe person list
        var removeObserver: (() -> Void)?
        waitNoData(timeout: 10) { handler in
            removeObserver = FirebaseObserver.shared.observeList(FirebasePerson.self, event: .childAdded, clubId: clubId, handler: handler)
        }
        if let removeObserver = removeObserver { removeObserver() }
    }

    // MARK: observe list all events

    /// Test observe list all events
    func testObserveListAllEvents() throws {

        // Observe value added
        try _testObserveListAllEventsChildAdded()

        // Observe value changed
        try _testObserveListAllEventsChildChanged()

        // Observe value removed
        try _testObserveListAllEventsChildRemoved()

        // Observe value added same id
        try _testObserveListAllEventsAlreadySameId()
    }

    /// Test observe list all events: child added
    func _testObserveListAllEventsChildAdded() throws {
        var removeObserver: (() -> Void)?
        let personList: [FirebasePerson] = try waitExpectation { handler in
            var personList = [FirebasePerson]()
            var numberObserved = 0
            removeObserver = FirebaseObserver.shared.observeList(FirebasePerson.self, clubId: clubId) { changeList in
                numberObserved += 1
                guard numberObserved > 3 else { return }
                changeList(&personList)
                handler(personList)
            }
            let callItem = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "persons/13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!, property: ["name": ["first": "firstName", "last": "lastName"]])
            FirebaseFunctionCaller.shared.call(callItem).thenResult { result in
                XCTAssertNil(result.error)
            }
        }
        if let removeObserver = removeObserver { removeObserver() }
        XCTAssertEqual(personList, [FirebasePerson(id: FirebasePerson.ID(rawValue: UUID(uuidString: "13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!), name: PersonName(firstName: "firstName", lastName: "lastName"), signInData: nil)])
    }

    /// Test observe list all events: child changed
    func _testObserveListAllEventsChildChanged() throws {
        var removeObserver: (() -> Void)?
        let personList: [FirebasePerson] = try waitExpectation { handler in
            var personList = [FirebasePerson(id: FirebasePerson.ID(rawValue: UUID(uuidString: "CEECA214-BA2B-4CEA-914D-6C12F5BD7C1F")!), name: PersonName(firstName: "otherFirstName", lastName: "otherLastName"), signInData: nil),
                              FirebasePerson(id: FirebasePerson.ID(rawValue: UUID(uuidString: "13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!), name: PersonName(firstName: "firstName", lastName: "lastName"), signInData: nil)]
            var numberObserved = 0
            removeObserver = FirebaseObserver.shared.observeList(FirebasePerson.self, clubId: clubId) { changeList in
                numberObserved += 1
                guard numberObserved > 4 else { return }
                changeList(&personList)
                handler(personList)
            }
            let callItem = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "persons/13BC2D6B-13FE-4874-AFD9-8351FB79B5D5/name/first")!, property: "newFirstName")
            FirebaseFunctionCaller.shared.call(callItem).thenResult { result in
                XCTAssertNil(result.error)
            }
        }
        if let removeObserver = removeObserver { removeObserver() }
        XCTAssertEqual(personList, [FirebasePerson(id: FirebasePerson.ID(rawValue: UUID(uuidString: "CEECA214-BA2B-4CEA-914D-6C12F5BD7C1F")!), name: PersonName(firstName: "otherFirstName", lastName: "otherLastName"), signInData: nil),
                                    FirebasePerson(id: FirebasePerson.ID(rawValue: UUID(uuidString: "13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!), name: PersonName(firstName: "newFirstName", lastName: "lastName"), signInData: nil)])
    }

    /// Test observe list all events: child removed
    func _testObserveListAllEventsChildRemoved() throws {
        var removeObserver: (() -> Void)?
        let personList: [FirebasePerson] = try waitExpectation { handler in
            var personList = [FirebasePerson(id: FirebasePerson.ID(rawValue: UUID(uuidString: "13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!), name: PersonName(firstName: "firstName", lastName: "lastName"), signInData: nil)]
            var numberObserved = 0
            removeObserver = FirebaseObserver.shared.observeList(FirebasePerson.self, clubId: clubId) { changeList in
                numberObserved += 1
                guard numberObserved > 4 else { return }
                changeList(&personList)
                handler(personList)
            }
            let callItem = FFDeleteTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "persons/13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!)
            FirebaseFunctionCaller.shared.call(callItem).thenResult { result in
                XCTAssertNil(result.error)
            }
        }
        if let removeObserver = removeObserver { removeObserver() }
        XCTAssertEqual(personList, [])
    }

    /// Test observe list all events: already same id
    func _testObserveListAllEventsAlreadySameId() throws {
        var removeObserver: (() -> Void)?
        let personList: [FirebasePerson] = try waitExpectation { handler in
            var personList = [FirebasePerson(id: FirebasePerson.ID(rawValue: UUID(uuidString: "13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!), name: PersonName(firstName: "firstName", lastName: "lastName"), signInData: nil)]
            var numberObserved = 0
            removeObserver = FirebaseObserver.shared.observeList(FirebasePerson.self, clubId: clubId) { changeList in
                numberObserved += 1
                guard numberObserved > 3 else { return }
                changeList(&personList)
                handler(personList)
            }
            let callItem = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "persons/13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!, property: ["name": ["first": "newFirstName", "last": "lastName"]])
            FirebaseFunctionCaller.shared.call(callItem).thenResult { result in
                XCTAssertNil(result.error)
            }
        }
        if let removeObserver = removeObserver { removeObserver() }
        XCTAssertEqual(personList, [FirebasePerson(id: FirebasePerson.ID(rawValue: UUID(uuidString: "13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!), name: PersonName(firstName: "firstName", lastName: "lastName"), signInData: nil)])
    }
}
