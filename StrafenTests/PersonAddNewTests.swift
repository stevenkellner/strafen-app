//
//  PersonAddNewTests.swift
//  StrafenTests
//
//  Created by Steven on 15.06.21.
//

import XCTest
import SwiftUI
import FirebaseFunctions
import FirebaseAuth
@testable import Strafen

class PersonAddNewTests: XCTestCase {
    let clubId = Club.ID(rawValue: UUID(uuidString: "65d63ed5-f1bc-4a7b-898c-850c88f54765")!)

    @MainActor override func setUpWithError() throws {
        continueAfterFailure = false
        FirebaseFetcher.shared.level = .testing
        FirebaseFunctionCaller.shared.level = .testing
        FirebaseImageStorage.shared.level = .testing

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

    /// Test add new person with empty fist name
    func testEmptyFirstName() async {
        let personId = TestClub.fetcherTestClub.persons.first { $0.signInData != nil }!.id
        let settingsClub = Club(id: clubId, name: "ClubName", identifier: "ClubIdentifier", regionCode: "DE", inAppPaymentActive: true)
        let settingsPerson = Settings.Person(club: settingsClub, id: personId, name: PersonName(firstName: "FirstName"), signInDate: Date(), isCashier: true)
        var inputProperties = PersonAddNew.InputProperties()
        let inputBinding = Binding<PersonAddNew.InputProperties> { inputProperties} set: { inputProperties = $0 }
        await PersonAddNew.handlePersonSave(person: settingsPerson, inputProperties: inputBinding)
        XCTAssertEqual(inputProperties.connectionState, .failed)
        XCTAssertEqual(inputProperties.errorMessages, [.firstName: .emptyField])
    }

    /// Test add new person with no image
    func testSaveOfPersonNoImage() async throws {
        let settingsPersonId = TestClub.fetcherTestClub.persons.first { $0.signInData != nil }!.id
        let settingsClub = Club(id: clubId, name: "ClubName", identifier: "ClubIdentifier", regionCode: "DE", inAppPaymentActive: true)
        let settingsPerson = Settings.Person(club: settingsClub, id: settingsPersonId, name: PersonName(firstName: "FirstName"), signInDate: Date(), isCashier: true)
        var inputProperties = PersonAddNew.InputProperties()
        inputProperties.inputProperties = [.firstName: "First-Name", .lastName: "Last-Name"]
        let inputBinding = Binding<PersonAddNew.InputProperties> { inputProperties} set: { inputProperties = $0 }
        let personId = await PersonAddNew.handlePersonSave(person: settingsPerson, inputProperties: inputBinding)
        XCTAssertNotNil(personId)
        XCTAssertEqual(inputProperties.connectionState, .passed)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertNil(inputProperties.imageUploadProgess)
        XCTAssertNil(inputProperties.functionCallErrorMessage)

        // Check person
        let personList: [FirebasePerson] = try await FirebaseFetcher.shared.fetchList(clubId: clubId)
        let fetchedPerson = personList.first { $0.id == personId }
        XCTAssertNotNil(fetchedPerson)
        XCTAssertEqual(fetchedPerson?.name.firstName, "First-Name")
        XCTAssertEqual(fetchedPerson?.name.lastName, "Last-Name")
    }

    /// Test add new person with image
    func testSaveOfPersonWithImage() async throws {
        let settingsPersonId = TestClub.fetcherTestClub.persons.first { $0.signInData != nil }!.id
        let settingsClub = Club(id: clubId, name: "ClubName", identifier: "ClubIdentifier", regionCode: "DE", inAppPaymentActive: true)
        let settingsPerson = Settings.Person(club: settingsClub, id: settingsPersonId, name: PersonName(firstName: "FirstName"), signInDate: Date(), isCashier: true)
        var inputProperties = PersonAddNew.InputProperties()
        inputProperties.inputProperties = [.firstName: "First-Name-2", .lastName: "Last-Name-2"]
        inputProperties.image = UIImage(named: "image-icon-small", in: Bundle(for: PersonAddNewTests.self), with: nil)
        let inputBinding = Binding<PersonAddNew.InputProperties> { inputProperties} set: { inputProperties = $0 }
        let personId = await PersonAddNew.handlePersonSave(person: settingsPerson, inputProperties: inputBinding)
        XCTAssertNotNil(personId)
        XCTAssertEqual(inputProperties.connectionState, .passed)
        XCTAssertEqual(inputProperties.errorMessages, [:])
        XCTAssertNil(inputProperties.imageUploadProgess)
        XCTAssertNil(inputProperties.functionCallErrorMessage)

        // Check person
        let personList: [FirebasePerson] = try await FirebaseFetcher.shared.fetchList(clubId: clubId)
        let fetchedPerson = personList.first { $0.id == personId }
        XCTAssertNotNil(fetchedPerson)
        XCTAssertEqual(fetchedPerson?.name.firstName, "First-Name-2")
        XCTAssertEqual(fetchedPerson?.name.lastName, "Last-Name-2")

        // Check image
        let imageType = FirebaseImageStorage.ImageType(id: personId!, clubId: clubId)
        let image = try await FirebaseImageStorage.shared.fetch(imageType, size: .original)
        let otherImage = UIImage(data: inputProperties.image?.jpegData(compressionQuality: FirebaseImageStorage.compressionQuality))
        XCTAssertEqual(image.jpegData(compressionQuality: 1), otherImage?.jpegData(compressionQuality: 1))

        // Delete images
        await wait(10)
        try await FirebaseImageStorage.shared.delete(imageType)
    }
}
