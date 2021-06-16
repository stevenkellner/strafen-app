//
//  PersonEditorTests.swift
//  StrafenTests
//
//  Created by Steven on 16.06.21.
//

import XCTest
import SwiftUI
import FirebaseFunctions
import FirebaseAuth
@testable import Strafen

class PersonEditorTests: XCTestCase {
    let clubId = Club.ID(rawValue: UUID(uuidString: "12d63ed5-f1bc-4a7b-898c-850c88f54765")!)

    @MainActor override func setUpWithError() throws {
        continueAfterFailure = false
        FirebaseFetcher.shared.level = .testing
        FirebaseFunctionCaller.shared.level = .testing

        waitExpectation { handler in
            async {

                // Sign test user in
                try await Auth.auth().signIn(withEmail: "app.demo@web.de", password: "Demopw12")

                let callItem = FFNewTestClubCall(clubId: clubId, testClubType: .fetcherTestClub)
                try await FirebaseFunctionCaller.shared.call(callItem)

                handler()
            }
        }
        try Task.checkCancellation()
    }

    override func tearDownWithError() throws {
        waitExpectation { handler in
            async {
                let callItem = FFDeleteTestClubCall(clubId: clubId)
                try await FirebaseFunctionCaller.shared.call(callItem)
                handler()
            }
        }
        try Task.checkCancellation()
    }

    /// Tests delete already registered
    func testDeleteAlreadyRegitered() async throws {
        let personId = TestClub.fetcherTestClub.persons.first { $0.signInData != nil }!.id
        let settingsClub = Club(id: clubId, name: "ClubName", identifier: "ClubIdentifier", regionCode: "DE", inAppPaymentActive: true)
        let settingsPerson = Settings.Person(club: settingsClub, id: personId, name: PersonName(firstName: "FirstName"), signInDate: Date(), isCashier: true)
        var inputProperties = PersonEditor.InputProperties()
        let inputBinding = Binding<PersonEditor.InputProperties> { inputProperties} set: { inputProperties = $0 }
        await PersonEditor.handlePersonDelete(id: personId, loggedInPerson: settingsPerson, fineList: TestClub.fetcherTestClub.fines, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionStateDelete, .failed)
        XCTAssertEqual(inputProperties.connectionStateUpdate, .notStarted)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertEqual(inputProperties.functionCallErrorMessage, .personUndeletable)
    }

    /// Tests delete
    func testDelete() async throws {

        // Create image
        let personId = TestClub.fetcherTestClub.persons.first { $0.signInData == nil }!.id
        let imageType = FirebaseImageStorage.ImageType(id: personId, clubId: clubId)
        try await FirebaseImageStorage.shared.store(UIImage(named: "image-icon-small", in: Bundle(for: PersonAddNewTests.self), with: nil)!, of: imageType)
        await wait(10)

        // Test delete
        let settingsPersonId = TestClub.fetcherTestClub.persons.first { $0.signInData != nil }!.id
        let settingsClub = Club(id: clubId, name: "ClubName", identifier: "ClubIdentifier", regionCode: "DE", inAppPaymentActive: true)
        let settingsPerson = Settings.Person(club: settingsClub, id: settingsPersonId, name: PersonName(firstName: "FirstName"), signInDate: Date(), isCashier: true)
        var inputProperties = PersonEditor.InputProperties()
        let inputBinding = Binding<PersonEditor.InputProperties> { inputProperties} set: { inputProperties = $0 }
        await PersonEditor.handlePersonDelete(id: personId, loggedInPerson: settingsPerson, fineList: TestClub.fetcherTestClub.fines, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionStateDelete, .passed)
        XCTAssertEqual(inputProperties.connectionStateUpdate, .notStarted)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertNil(inputProperties.functionCallErrorMessage)

        // Check lists and image
        let personList: [FirebasePerson] = try await FirebaseFetcher.shared.fetchList(clubId: clubId)
        XCTAssertNil(personList.first { $0.id == personId })
        let fineList: [FirebaseFine] = try await FirebaseFetcher.shared.fetchList(clubId: clubId)
        XCTAssertNil(fineList.first { $0.assoiatedPersonId == personId })
        do {
            _ = try await FirebaseImageStorage.shared.fetch(imageType, size: .original)
            XCTFail() // swiftlint:disable:this xctfail_message
        } catch {
            XCTAssertEqual(error as? FirebaseImageStorage.StoreError, .onFetch)
        }
    }

    /// Test update with empty first name
    func testUpdateEmptyFirstName() async {
        let personId = TestClub.fetcherTestClub.persons.first { $0.signInData != nil }!.id
        let settingsClub = Club(id: clubId, name: "ClubName", identifier: "ClubIdentifier", regionCode: "DE", inAppPaymentActive: true)
        let settingsPerson = Settings.Person(club: settingsClub, id: personId, name: PersonName(firstName: "FirstName"), signInDate: Date(), isCashier: true)
        var inputProperties = PersonEditor.InputProperties()
        let inputBinding = Binding<PersonEditor.InputProperties> { inputProperties} set: { inputProperties = $0 }
        await PersonEditor.handlePersonUpdate(id: personId, loggedInPerson: settingsPerson, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionStateDelete, .notStarted)
        XCTAssertEqual(inputProperties.connectionStateUpdate, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.firstName: .emptyField])
        XCTAssertNil(inputProperties.functionCallErrorMessage)
    }

    /// Test update
    func testUpdate() async throws {

        // Create image
        let personId = TestClub.fetcherTestClub.persons.first { $0.signInData != nil }!.id
        let imageType = FirebaseImageStorage.ImageType(id: personId, clubId: clubId)
        try await FirebaseImageStorage.shared.store(UIImage(named: "image-icon-small", in: Bundle(for: PersonAddNewTests.self), with: nil)!, of: imageType)
        await wait(10)

        // Update person
        let settingsClub = Club(id: clubId, name: "ClubName", identifier: "ClubIdentifier", regionCode: "DE", inAppPaymentActive: true)
        let settingsPerson = Settings.Person(club: settingsClub, id: personId, name: PersonName(firstName: "FirstName"), signInDate: Date(), isCashier: true)
        var inputProperties = PersonEditor.InputProperties()
        inputProperties.inputProperties = [.firstName: "asdf-name"]
        inputProperties.image = UIImage(named: "image-icon-small-2", in: Bundle(for: PersonAddNewTests.self), with: nil)!
        inputProperties.isNewImage = true
        let inputBinding = Binding<PersonEditor.InputProperties> { inputProperties} set: { inputProperties = $0 }
        await PersonEditor.handlePersonUpdate(id: personId, loggedInPerson: settingsPerson, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionStateDelete, .notStarted)
        XCTAssertEqual(inputProperties.connectionStateUpdate, .passed)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertNil(inputProperties.functionCallErrorMessage)

        // Check person
        let personList: [FirebasePerson] = try await FirebaseFetcher.shared.fetchList(clubId: clubId)
        let person = personList.first { $0.id == personId }
        XCTAssertEqual(person?.name.firstName, "asdf-name")
        XCTAssertNil(person?.name.lastName)
        XCTAssertNotNil(person?.signInData)

        // Check image
        let image = try await FirebaseImageStorage.shared.fetch(imageType, size: .original)
        let otherImage = UIImage(data: inputProperties.image?.jpegData(compressionQuality: FirebaseImageStorage.compressionQuality))
        XCTAssertEqual(image.jpegData(compressionQuality: 1), otherImage?.jpegData(compressionQuality: 1))

        // Delete images
        await wait(10)
        try await FirebaseImageStorage.shared.delete(imageType)
    }
}
