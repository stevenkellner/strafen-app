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

class FirebaseObserverTests: XCTestCase {

    let clubId = Club.ID(rawValue: UUID(uuidString: "d7b3c296-54cb-4417-8824-ecee22eb5eaf")!)

    // MARK: set up

    @MainActor override func setUpWithError() throws {
        continueAfterFailure = false
        FirebaseFunctionCaller.shared.level = .testing
        FirebaseFetcher.shared.level = .testing
        FirebaseObserver.shared.level = .testing

        waitExpectation(timeout: 60) { handler in
            async {

                // Sign test user in
                try await Auth.auth().signIn(withEmail: "app.demo@web.de", password: "Demopw12")

                // Delete old test club
                try await _setUpDeleteOldTestClub()

                // Create new test club
                try await _setUpCreateNewTestClub()

                // Check test club
                try await _setUpCheckTestClub()

                handler()
            }
        }
        try Task.checkCancellation()
    }

    /// Set up: deletes old test club
    func _setUpDeleteOldTestClub() async throws {
        let callItem = FFDeleteTestClubCall(clubId: clubId)
        try await FirebaseFunctionCaller.shared.call(callItem)
    }

    /// Set up: creates new test club
    func _setUpCreateNewTestClub() async throws {
        let callItem = FFNewTestClubCall(clubId: clubId, testClubType: .fetcherTestClub)
        try await FirebaseFunctionCaller.shared.call(callItem)
    }

    /// Set up: Check test club
    func _setUpCheckTestClub() async throws {
        let club = try await FirebaseFetcher.shared.fetchClub(clubId)
        XCTAssertEqual(club, TestClub.fetcherTestClub)
    }

    // MARK: tear down

    override func tearDownWithError() throws {

        // Delete created test club (same as delete old test club in setUp)
        waitExpectation { handler in
            async {
                try await _setUpDeleteOldTestClub()
                handler()
            }
        }
        try Task.checkCancellation()
    }

    // MARK: observe object

    /// Test observe object
    func testObserveObject() async throws {

        // Observe primitive type
        try await _testObserveObjectPrimitiveType()

        // Observe removed observer
        try await _testObserveObjectRemovedObserver()

        // Observe primitive type with wrong type
        try await _testObserveObjectWrongTypePrimitiveType()

        // Observe object
        try await _testObserveObjectObject()

        // Observe object with wrong type
        try await _testObserveObjectWrongTypeObject()
    }

    /// Test observe object: observe primitive type
    func _testObserveObjectPrimitiveType() async throws {

        // Observe value added
        try await _testObserveObjectPrimitiveTypeAdded()

        // Observe value changed
        try await _testObserveObjectPrimitiveTypeChanged()

        // Observe value removed
        try await _testObserveObjectPrimitiveTypeRemoved()
    }

    /// Test observe object: observe primitive type added
    func _testObserveObjectPrimitiveTypeAdded() async throws {
        var removeObserver: (() -> Void)?
        let observedResult: String = try await waitExpectation { handler in
            removeObserver = FirebaseObserver.shared.observe(String.self, url: URL(string: "stringKey")!, clubId: clubId, onChange: handler)
            let callItem = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "stringKey")!, property: "value")
            try await FirebaseFunctionCaller.shared.call(callItem)
        }
        removeObserver?()
        XCTAssertEqual(observedResult, "value")
    }

    /// Test observe object: observe primitive type changed
    func _testObserveObjectPrimitiveTypeChanged() async throws {
        var removeObserver: (() -> Void)?
        let observedResult: String = try await waitExpectation { handler in
            var numberObserved = 0
            removeObserver =  FirebaseObserver.shared.observe(String.self, url: URL(string: "stringKey")!, clubId: clubId) { value in
                numberObserved += 1
                guard numberObserved != 1 else { return }
                handler(value)
            }
            let callItem = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "stringKey")!, property: "newValue")
            try await FirebaseFunctionCaller.shared.call(callItem)
        }
        removeObserver?()
        XCTAssertEqual(observedResult, "newValue")
    }

    /// Test observe object: observe primitive type removed
    func _testObserveObjectPrimitiveTypeRemoved() async throws {
        var removeObserver: (() -> Void)?
        try await waitExpectation { handler in
            removeObserver = FirebaseObserver.shared.observe(String.self, url: URL(string: "stringKey")!, clubId: clubId, onRemove: handler)
            let callItem = FFDeleteTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "stringKey")!)
            try await FirebaseFunctionCaller.shared.call(callItem)
        }
        removeObserver?()
    }

    /// Test observe object: observe removed observer
    func _testObserveObjectRemovedObserver() async throws {
        var numberExecuted = 0
        let removeObserver = FirebaseObserver.shared.observe(String.self, url: URL(string: "otherKey")!, clubId: clubId) { value in
            XCTAssertEqual(value, "value")
            numberExecuted += 1
        }

        // Set value
        let setValueCallItem = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "otherKey")!, property: "value")
        try await FirebaseFunctionCaller.shared.call(setValueCallItem)

        await wait(1)

        // Remove observer
        removeObserver()

        // Update value
        let changeValueCallItem = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "otherKey")!, property: "newValue")
        try await FirebaseFunctionCaller.shared.call(changeValueCallItem)

        // Still wait 10sec for observed value
        await wait(10)

        XCTAssertEqual(numberExecuted, 1)
    }

    /// Test observe object: observe wrong type primitive type
    func _testObserveObjectWrongTypePrimitiveType() async throws {

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
    func _testObserveObjectObject() async throws {
        var removeObserver: (() -> Void)?
        let observedResult: PersonName = try await waitExpectation { handler in
            var numberObserved = 0
            removeObserver =  FirebaseObserver.shared.observe(PersonName.self, url: URL(string: "persons/D1852AC0-A0E2-4091-AC7E-CB2C23F708D9/name")!, clubId: clubId) { value in
                numberObserved += 1
                guard numberObserved != 1 else { return }
                handler(value)
            }
            let callItem = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "persons/D1852AC0-A0E2-4091-AC7E-CB2C23F708D9/name/first")!, property: "new First Name")
            try await FirebaseFunctionCaller.shared.call(callItem)
        }
        removeObserver?()
        XCTAssertEqual(observedResult.firstName, "new First Name")
    }

    /// Test observe object: fetch wrong type object
    func _testObserveObjectWrongTypeObject() async throws {

        // Try fetch string as object
        var removeObserver1: (() -> Void)?
        waitNoData(timeout: 10) { handler in
            removeObserver1 = FirebaseObserver.shared.observe(FirebasePerson.self, url: URL(string: "identifier")!, clubId: clubId, onChange: handler)
        }
        removeObserver1?()

        // Try fetch object as object
        var removeObserver2: (() -> Void)?
        waitNoData(timeout: 10) { handler in
            removeObserver2 = FirebaseObserver.shared.observe(FirebasePerson.self, url: URL(string: "fines/02462A8B-107F-4BAE-A85B-EFF1F727C00F")!, clubId: clubId, onChange: handler)
        }
        removeObserver2?()
    }

    // MARK: observe list

    /// Test observe list
    func testObserveList() async throws {

        // Observe list
        try await _testObserveList()

        // Observe list removed observer
        try await _testObserveListRemovedObserver()

        // Observe list with wrong type
        // try _testObserveListWrongType()
    }

    /// Test observe list
    func _testObserveList() async throws {

        // Observe value added
        try await _testObserveListChildAdded()

        // Observe value changed
        try await _testObserveListChildChanged()

        // Observe value removed
        try await _testObserveListChildRemoved()

    }

    /// Test observe list: child added
    func _testObserveListChildAdded() async throws {
        var removeObserver: (() -> Void)?
        let observedResult: FirebasePerson = try await waitExpectation { handler in
            var numberObserved = 0
            removeObserver = FirebaseObserver.shared.observeList(FirebasePerson.self, event: .childAdded, clubId: clubId) { value in
                numberObserved += 1
                guard numberObserved > 3 else { return }
                handler(value)
            }
            let callItem = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "persons/13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!, property: ["name": ["first": "firstName", "last": "lastName"]])
            try await FirebaseFunctionCaller.shared.call(callItem)
        }
        removeObserver?()
        XCTAssertEqual(observedResult, FirebasePerson(id: FirebasePerson.ID(rawValue: UUID(uuidString: "13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!), name: PersonName(firstName: "firstName", lastName: "lastName"), signInData: nil))
    }

    /// Test observe list: child changed
    func _testObserveListChildChanged() async throws {
        var removeObserver: (() -> Void)?
        let observedResult: FirebasePerson = try await waitExpectation { handler in
            removeObserver = FirebaseObserver.shared.observeList(FirebasePerson.self, event: .childChanged, clubId: clubId, handler: handler)
            let callItem = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "persons/13BC2D6B-13FE-4874-AFD9-8351FB79B5D5/name/first")!, property: "newFirstName")
            try await FirebaseFunctionCaller.shared.call(callItem)
        }
        removeObserver?()
        XCTAssertEqual(observedResult, FirebasePerson(id: FirebasePerson.ID(rawValue: UUID(uuidString: "13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!), name: PersonName(firstName: "newFirstName", lastName: "lastName"), signInData: nil))
    }

    /// Test observe list: child removed
    func _testObserveListChildRemoved() async throws {
        var removeObserver: (() -> Void)?
        let observedResult: FirebasePerson = try await waitExpectation { handler in
            removeObserver = FirebaseObserver.shared.observeList(FirebasePerson.self, event: .childRemoved, clubId: clubId, handler: handler)
            let callItem = FFDeleteTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "persons/13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!)
            try await FirebaseFunctionCaller.shared.call(callItem)
        }
        removeObserver?()
        XCTAssertEqual(observedResult, FirebasePerson(id: FirebasePerson.ID(rawValue: UUID(uuidString: "13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!), name: PersonName(firstName: "newFirstName", lastName: "lastName"), signInData: nil))
    }

    /// Test observe list: removed observer
    func _testObserveListRemovedObserver() async throws {
        var numberExecuted = 0
        let removeObserver = FirebaseObserver.shared.observeList(FirebasePerson.self, event: .childChanged, clubId: clubId) { value in
            XCTAssertEqual(value, FirebasePerson(id: FirebasePerson.ID(rawValue: UUID(uuidString: "D1852AC0-A0E2-4091-AC7E-CB2C23F708D9")!), name: PersonName(firstName: "first", lastName: "Doe"), signInData: nil))
            numberExecuted += 1
        }

        // Update value
        let callItem1 = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "persons/D1852AC0-A0E2-4091-AC7E-CB2C23F708D9/name/first")!, property: "first")
        try await FirebaseFunctionCaller.shared.call(callItem1)

        await wait(1)

        // Remove observer
        removeObserver()

        // Update value
        let callItem2 = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "persons/D1852AC0-A0E2-4091-AC7E-CB2C23F708D9/name/last")!, property: "last")
        try await FirebaseFunctionCaller.shared.call(callItem2)

        // Still wait 10sec for observed value
        await wait(10)

        XCTAssertEqual(numberExecuted, 1)
    }

    /// Test observe list: wrong type
    func _testObserveListWrongType() async throws {

        // Set non person list to person list
        let callItem = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "persons")!, property: ["id": ["test": "value"]])
        try await FirebaseFunctionCaller.shared.call(callItem)

        // Try observe person list
        var removeObserver: (() -> Void)?
        waitNoData(timeout: 10) { handler in
            removeObserver = FirebaseObserver.shared.observeList(FirebasePerson.self, event: .childAdded, clubId: clubId, handler: handler)
        }
        removeObserver?()
    }

    // MARK: observe list all events

    /// Test observe list all events
    func testObserveListAllEvents() async throws {

        // Observe value added
        try await _testObserveListAllEventsChildAdded()

        // Observe value changed
        try await _testObserveListAllEventsChildChanged()

        // Observe value removed
        try await _testObserveListAllEventsChildRemoved()

        // Observe value added same id
        try await _testObserveListAllEventsAlreadySameId()
    }

    /// Test observe list all events: child added
    func _testObserveListAllEventsChildAdded() async throws {
        var removeObserver: (() -> Void)?
        let personList: [FirebasePerson] = try await waitExpectation { handler in
            var personList = [FirebasePerson]()
            var numberObserved = 0
            removeObserver = FirebaseObserver.shared.observeList(FirebasePerson.self, clubId: clubId) { changeList in
                numberObserved += 1
                guard numberObserved > 3 else { return }
                changeList(&personList)
                handler(personList)
            }
            let callItem = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "persons/13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!, property: ["name": ["first": "firstName", "last": "lastName"]])
            try await FirebaseFunctionCaller.shared.call(callItem)
        }
        removeObserver?()
        XCTAssertEqual(personList, [FirebasePerson(id: FirebasePerson.ID(rawValue: UUID(uuidString: "13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!), name: PersonName(firstName: "firstName", lastName: "lastName"), signInData: nil)])
    }

    /// Test observe list all events: child changed
    func _testObserveListAllEventsChildChanged() async throws {
        var removeObserver: (() -> Void)?
        let personList: [FirebasePerson] = try await waitExpectation { handler in
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
            try await FirebaseFunctionCaller.shared.call(callItem)
        }
        removeObserver?()
        XCTAssertEqual(personList, [FirebasePerson(id: FirebasePerson.ID(rawValue: UUID(uuidString: "CEECA214-BA2B-4CEA-914D-6C12F5BD7C1F")!), name: PersonName(firstName: "otherFirstName", lastName: "otherLastName"), signInData: nil),
                                    FirebasePerson(id: FirebasePerson.ID(rawValue: UUID(uuidString: "13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!), name: PersonName(firstName: "newFirstName", lastName: "lastName"), signInData: nil)])
    }

    /// Test observe list all events: child removed
    func _testObserveListAllEventsChildRemoved() async throws {
        var removeObserver: (() -> Void)?
        let personList: [FirebasePerson] = try await waitExpectation { handler in
            var personList = [FirebasePerson(id: FirebasePerson.ID(rawValue: UUID(uuidString: "13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!), name: PersonName(firstName: "firstName", lastName: "lastName"), signInData: nil)]
            var numberObserved = 0
            removeObserver = FirebaseObserver.shared.observeList(FirebasePerson.self, clubId: clubId) { changeList in
                numberObserved += 1
                guard numberObserved > 4 else { return }
                changeList(&personList)
                handler(personList)
            }
            let callItem = FFDeleteTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "persons/13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!)
            try await FirebaseFunctionCaller.shared.call(callItem)
        }
        removeObserver?()
        XCTAssertEqual(personList, [])
    }

    /// Test observe list all events: already same id
    func _testObserveListAllEventsAlreadySameId() async throws {
        var removeObserver: (() -> Void)?
        let personList: [FirebasePerson] = try await waitExpectation { handler in
            var personList = [FirebasePerson(id: FirebasePerson.ID(rawValue: UUID(uuidString: "13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!), name: PersonName(firstName: "firstName", lastName: "lastName"), signInData: nil)]
            var numberObserved = 0
            removeObserver = FirebaseObserver.shared.observeList(FirebasePerson.self, clubId: clubId) { changeList in
                numberObserved += 1
                guard numberObserved > 3 else { return }
                changeList(&personList)
                handler(personList)
            }
            let callItem = FFNewTestClubPropertyCall(clubId: clubId, urlFromClub: URL(string: "persons/13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!, property: ["name": ["first": "newFirstName", "last": "lastName"]])
            try await FirebaseFunctionCaller.shared.call(callItem)
        }
        removeObserver?()
        XCTAssertEqual(personList, [FirebasePerson(id: FirebasePerson.ID(rawValue: UUID(uuidString: "13BC2D6B-13FE-4874-AFD9-8351FB79B5D5")!), name: PersonName(firstName: "firstName", lastName: "lastName"), signInData: nil)])
    }
}
