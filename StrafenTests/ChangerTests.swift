//
//  ChangerTests.swift
//  StrafenTests
//
//  Created by Steven on 9/19/20.
//

import XCTest
@testable import Strafen

/// Test for all changers
///
/// ✅ 1) Check if test club folder is deleted
///
/// ✅ 2) Check if test club image is deleted
///
/// ✅ 3) Check if test club is deleted from allClubs.json
///
/// ✅ 4) Delete none existing club
///
/// ✅ 5) Create new club with email login and check if club and person with email login are in allClubs.json with all properties and if all lists are created
///
/// ✅ 6) Create same club again
///
/// ✅ 7) Update none existing club image
///
/// ✅ 8) Delete none existing club image
///
/// ✅ 9) Add club image and check if image is created
///
/// ✅ 10) Add same club image
///
/// ✅ 11) Update club image and check if image is updated
///
/// ✅ 12) Delete club image and check if image is deleted
///
/// ✅ 13) Add club image and check if image is created
///
/// ✅ 14) Delete club and check if club lists and image are deleted and if club is deleted from allClubs.json
///
/// ✅ 15) Create new club with apple login and check if club and person with apple login are in allClubs.json with all properties and if all lists are created
///
/// ✅ 16) Update none existing person image
///
/// ✅ 17) Delete none existing person image
///
/// ✅ 18) Add person image and check if image is created
///
/// ✅ 19) Add same person image
///
/// ✅ 20) Update person image and check if image is updated
///
/// ✅ 21) Delete person image and check if image is deleted
///
/// ✅ 22) Register new person with email login and check if person is added to allClubs.json and to person list with all properties
///
/// ✅ 23) Force sign out a registered person and check if person is deleted in allClubs.json
///
/// ✅ 24) Register new person with apple login and check if person is added to allClubs.json and to person list with all properties
///
/// ✅ 25) Set late payment interest and check in allClubs.json with all properties
///
/// ✅ 26) Set late payment interest to nil and check in allClubs.json
///
/// ✅ 27) Add person image without person and check if is created
///
/// ✅ 28) Update none existing person / fine (custom and template) / reason
///
/// ✅ 29) Delete none existing person / fine (custom and template) / reason
///
/// ✅ 30) Add person / fine (custom and template) / reason and check if all properties are set
///
/// ✅ 31) Add same person / fine (custom and template) / reason
///
/// ✅ 32) Update person / fine (custom and template) / reason and check if all properties are set
///
/// ✅ 33) Delete person / fine (custom and template) / reason and check if is deleted and person image for person
///
/// ✅ 34) Delete club and check if club lists, person images and club image are deleted and if club is deleted from allClubs.json
///
/// ☑️ 35) Check send code mail
class ChangerTests: XCTestCase {
    
    override class func tearDown() {
        print("\n")
    }
    
    func testChangers() throws {
        continueAfterFailure = false
        print("\n")
        try deleteClub(forReset: true)
        
        try clubFolderDeleted()
        try clubImageDeleted()
        try clubAllClubsDeleted()
        try deleteNoneExistingClub()
        try createNewClubEmailLogin()
        try createSameClubAgain()
        try updateNoneExistingClubImage()
        try deleteNoneExistingClubImage()
        try addClubImage()
        try addSameClubImage()
        try updateClubImage()
        try deleteClubImage()
        try addClubImageAgain()
        try deleteFirstClub()
        try createNewClubAppleLogin()
        try updateNoneExistingPersonImage()
        try deleteNoneExistingPersonImage()
        try addPersonImage()
        try addSamePersonImage()
        try updatePersonImage()
        try deletePersonImage()
        try registerPersonEmailLogin()
        try forceSignOut()
        try registerPersonAppleLogin()
        try setLatePaymentInterest()
        try unsetLatePaymentInterest()
        try addPersonImageAgain()
        try updateNoneExistingListTypes()
        try deleteNoneExistingListTypes()
        try addListTypes()
        try addSameListTypes()
        try updateListTypes()
        try deleteListTypes()
        try deleteClub()
        
        print("\n")
    }
    
    /// Test 01 | Setup Test 1 of 3
    ///
    /// Checks if test club folder is deleted.
    private func clubFolderDeleted() throws {
        TestInfos.shared.start(number: 1, messages: "Setup Test 1 of 3", "Checks if test club folder is deleted.")
        let statusCode: Int? = try await { handler in
            let url = TestContent.shared.club.folderUrl
            FileManager.default.serverFileStatusCode(of: url, handler)
        }
        XCTAssertNotNil(statusCode, "There was an error in test 1.")
        XCTAssertEqual(statusCode!, 404, "Test 01 | The test club folder already exists on the server. Please delete this folder first to start the tests.")
        TestInfos.shared.end()
    }
    
    /// Test 02 | Setup Test 2 of 3
    ///
    /// Checks if test club image is deleted.
    private func clubImageDeleted() throws {
        TestInfos.shared.start(number: 2, messages: "Setup Test 2 of 3", "Checks if test club image is deleted.")
        let fileExists: Bool? = try await { handler in
            let url = TestContent.shared.club.imageUrl
            FileManager.default.serverFileExists(of: url, handler)
        }
        XCTAssertNotNil(fileExists, "There was an error in test 2.")
        XCTAssertFalse(fileExists!, "Test 02 | The test club image already exists on the server. Please delete the image first to start the tests.")
        TestInfos.shared.end()
    }
    
    /// Test 03 | Setup Test 3 of 3
    ///
    /// Checks if test club is deleted from allClubs.json
    private func clubAllClubsDeleted() throws {
        TestInfos.shared.start(number: 3, messages: "Setup Test 3 of 3", "Checks if test club is deleted in allClubs.json.")
        let allClubs: [Club]? = try await { handler in
            ListFetcher.shared.fetch(handler)
        }
        let containsClub = allClubs?.contains(where: { $0.id == TestContent.shared.club.id })
        XCTAssertNotNil(containsClub, "There was an error in test 3.")
        XCTAssertFalse(containsClub!, "Test 03 | The test club already exists in allClubs.json on the server. Please delete the club in allClubs.json first to start the tests.")
        TestInfos.shared.end()
    }
    
    /// Test 04 | Club Test 01 of 12
    ///
    /// Deletes none existing club
    private func deleteNoneExistingClub() throws {
        TestInfos.shared.start(number: 4, messages: "Club Test 01 of 12", "Deletes none existing club.")
        let taskState: TaskState = try await { handler in
            let changeItem = DeleteClubChange(clubId: TestContent.shared.club.id)
            Changer.shared.change(changeItem, taskStateHandler: handler)
        }
        XCTAssertEqual(taskState, .passed, "Test 04 | Couldn't delete none existing club.")
        TestInfos.shared.end()
    }
    
    /// Test 05 | Club Test 02 of 12
    ///
    /// Creates a new club with email login and checks if club and person with email login are in allClubs.json with all properties and if all lists are created
    private func createNewClubEmailLogin() throws {
        TestInfos.shared.start(number: 5, messages: "Club Test 02 of 12", "Create new club with email login and check if club and person with email login are in allClubs.json with all properties and if all lists are created.")
        
        // Create new club
        let taskState: TaskState = try await { handler in
            let newClub = ChangerClub(clubId: TestContent.shared.club.id, clubName: TestContent.shared.club.name, personId: TestContent.shared.emailLoginPerson.id, personName: TestContent.shared.emailLoginPerson.personName, login: TestContent.shared.emailLoginPerson.login)
            let changeItem = NewClubChange(club: newClub)
            Changer.shared.change(changeItem, taskStateHandler: handler)
        }
        XCTAssertEqual(taskState, .passed, "Test 05 | Couldn't add new club.")
        
        // Check allClubs.json
        let allClubs: [Club]? = try await { handler in
            ListFetcher.shared.fetch(handler)
        }
        XCTAssertNotNil(allClubs, "There was an error in test 5.")
        let person = Club.ClubPerson(id: TestContent.shared.emailLoginPerson.id, firstName: TestContent.shared.emailLoginPerson.personName.firstName, lastName: TestContent.shared.emailLoginPerson.personName.lastName, login: TestContent.shared.emailLoginPerson.login.encryptedCodable, isCashier: true)
        let club = Club(id: TestContent.shared.club.id, name: TestContent.shared.club.name, allPersons: [person], latePaymentInterest: nil)
        let serverClub = allClubs!.first(where: { $0.id == club.id })
        XCTAssertNotNil(serverClub, "Test 05 | allClubs.json didn't contain new club.")
        XCTAssertEqual(serverClub!, club, "Test 05 | allClubs.json didn't contain all properties.")
        
        // Check if list were created
        let keyPaths: [(KeyPath<AppUrls.ListTypesUrls, URL>, String)] = [(\.person, "Person"), (\.reason, "Reason"), (\.fine, "Fine")]
        for keyPath in keyPaths {
            let fileExists: Bool? = try await { handler in
                let url = AppUrls.shared.listTypesUrls(of: TestContent.shared.club.id)[keyPath: keyPath.0]
                FileManager.default.serverFileExists(of: url, handler)
            }
            XCTAssertNotNil(fileExists, "There was an error in test 5.")
            XCTAssertTrue(fileExists!, "Test 05 | \(keyPath.1) list didn't exist for new club.")
        }
        
        // Check person list
        let personList: [Person]? = try await { handler in
            let url = AppUrls.shared.listTypesUrls(of: TestContent.shared.club.id).person
            ListFetcher.shared.fetch(from: url, handler)
        }
        XCTAssertNotNil(personList, "There was an error in test 5.")
        XCTAssertEqual(personList!, [Person(firstName: TestContent.shared.emailLoginPerson.personName.firstName, lastName: TestContent.shared.emailLoginPerson.personName.lastName, id: TestContent.shared.emailLoginPerson.id)], "Couldn't add person to person list.")
        
        TestInfos.shared.end()
    }
    
    /// Test 06 | Club Test 03 of 12
    ///
    /// Creates same club again
    private func createSameClubAgain() throws {
        TestInfos.shared.start(number: 6, messages: "Club Test 03 of 12", "Create same club again.")
        let taskState: TaskState = try await { handler in
            let changeItem = DeleteClubChange(clubId: TestContent.shared.club.id)
            Changer.shared.change(changeItem, taskStateHandler: handler)
        }
        XCTAssertEqual(taskState, .passed, "Couldn't create same club again.")
        TestInfos.shared.end()
    }
    
    /// Test 07 | Club Test 04 of 12
    ///
    /// Updates none existing club image
    private func updateNoneExistingClubImage() throws {
        TestInfos.shared.start(number: 7, messages: "Club Test 04 of 12", "Update none existing club image.")
        let taskState: TaskState = try await { handler in
            let changeItem = ClubImageChange(changeType: .update, image: TestContent.shared.club.image, clubId: TestContent.shared.club.id)
            Changer.shared.change(changeItem, taskStateHandler: handler)
        }
        XCTAssertEqual(taskState, .passed, "Couldn't update none existing image.")
        TestInfos.shared.end()
    }
    
    /// Test 08 | Club Test 05 of 12
    ///
    /// Deletes none existing club image
    private func deleteNoneExistingClubImage() throws {
        TestInfos.shared.start(number: 8, messages: "Club Test 05 of 12", "Delete none existing club image.")
        let taskState: TaskState = try await { handler in
            let changeItem = ClubImageChange(changeType: .delete, image: nil, clubId: TestContent.shared.club.id)
            Changer.shared.change(changeItem, taskStateHandler: handler)
        }
        XCTAssertEqual(taskState, .passed, "Couldn't delete none existing image.")
        TestInfos.shared.end()
    }
    
    /// Test 09 | Club Test 06 of 12
    ///
    /// Adds club image and checks if image is created
    private func addClubImage() throws {
        TestInfos.shared.start(number: 9, messages: "Club Test 06 of 12", "Add club image and check if image is created.")
        
        // Add image
        let taskState: TaskState = try await { handler in
            let changeItem = ClubImageChange(changeType: .add, image: TestContent.shared.club.image, clubId: TestContent.shared.club.id)
            Changer.shared.change(changeItem, taskStateHandler: handler)
        }
        XCTAssertEqual(taskState, .passed, "Couldn't add club image.")
        
        // Check image
        let imageData: Data? = try await { handler in
            let url = AppUrls.shared.clubImageUrl(of: TestContent.shared.club.id)
            var request = URLRequest(url: url)
            request.setValue("Basic \(AppUrls.shared.loginString)", forHTTPHeaderField: "Authorization")
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            URLSession.shared.dataTask(with: request) { data, _, _ in
                handler(data)
            }.resume()
        }
        XCTAssertNotNil(imageData, "There was an error in test 9.")
        XCTAssertEqual(imageData!, TestContent.shared.club.image.pngData()!, "Couldn't add club image.")
        
        TestInfos.shared.end()
    }
    
    /// Test 10 | Club Test 07 of 12
    ///
    /// Add same club image
    private func addSameClubImage() throws {
        TestInfos.shared.start(number: 10, messages: "Club Test 07 of 12", "Add same club image.")
        
        // Add image
        let taskState: TaskState = try await { handler in
            let changeItem = ClubImageChange(changeType: .add, image: TestContent.shared.club.secondImage, clubId: TestContent.shared.club.id)
            Changer.shared.change(changeItem, taskStateHandler: handler)
        }
        XCTAssertEqual(taskState, .passed, "Couldn't add same club image.")
        
        // Check image
        let imageData: Data? = try await { handler in
            let url = AppUrls.shared.clubImageUrl(of: TestContent.shared.club.id)
            var request = URLRequest(url: url)
            request.setValue("Basic \(AppUrls.shared.loginString)", forHTTPHeaderField: "Authorization")
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            URLSession.shared.dataTask(with: request) { data, _, _ in
                handler(data)
            }.resume()
        }
        XCTAssertNotNil(imageData, "There was an error in test 10.")
        XCTAssertEqual(imageData!, TestContent.shared.club.image.pngData()!, "Add a image.")
        
        TestInfos.shared.end()
    }
    
    /// Test 11 | Club Test 08 of 12
    ///
    /// Updates club image and checks if image is updated
    private func updateClubImage() throws {
        TestInfos.shared.start(number: 11, messages: "Club Test 08 of 12", "Update club image and check if image is updated.")
        
        // Update image
        let taskState: TaskState = try await { handler in
            let changeItem = ClubImageChange(changeType: .update, image: TestContent.shared.club.secondImage, clubId: TestContent.shared.club.id)
            Changer.shared.change(changeItem, taskStateHandler: handler)
        }
        XCTAssertEqual(taskState, .passed, "Couldn't update club image.")
        
        // Check image
        let imageData: Data? = try await { handler in
            let url = AppUrls.shared.clubImageUrl(of: TestContent.shared.club.id)
            var request = URLRequest(url: url)
            request.setValue("Basic \(AppUrls.shared.loginString)", forHTTPHeaderField: "Authorization")
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            URLSession.shared.dataTask(with: request) { data, _, _ in
                handler(data)
            }.resume()
        }
        XCTAssertNotNil(imageData, "There was an error in test 11.")
        XCTAssertEqual(imageData!, TestContent.shared.club.secondImage.pngData()!, "Couldn't update club image.")
        
        TestInfos.shared.end()
    }
    
    /// Test 12 | Club Test 09 of 12
    ///
    /// Deletes club image and checks if image is deleted
    private func deleteClubImage()  throws {
        TestInfos.shared.start(number: 12, messages: "Club Test 09 of 12", "Delete club image and check if image is deleted")
        
        // Delete image
        let taskState: TaskState = try await { handler in
            let changeItem = ClubImageChange(changeType: .delete, image: nil, clubId: TestContent.shared.club.id)
            Changer.shared.change(changeItem, taskStateHandler: handler)
        }
        XCTAssertEqual(taskState, .passed, "Couldn't delete club image.")
        
        // Check image
        let fileExists: Bool? = try await { handler in
            let url = AppUrls.shared.clubImageUrl(of: TestContent.shared.club.id)
            FileManager.default.serverFileExists(of: url, handler)
        }
        XCTAssertNotNil(fileExists, "There was an error in test 12.")
        XCTAssertFalse(fileExists!, "Couldn't delete club image.")
        
        TestInfos.shared.end()
    }
    
    /// Test 13 | Club Test 10 of 12
    ///
    /// Adds club image and checks if image is created
    private func addClubImageAgain() throws {
        TestInfos.shared.start(number: 13, messages: "Club Test 10 of 12", "Add club image and check if image is created.")
        
        // Add image
        let taskState: TaskState = try await { handler in
            let changeItem = ClubImageChange(changeType: .add, image: TestContent.shared.club.image, clubId: TestContent.shared.club.id)
            Changer.shared.change(changeItem, taskStateHandler: handler)
        }
        XCTAssertEqual(taskState, .passed, "Couldn't add club image.")
        
        // Check image
        let imageData: Data? = try await { handler in
            let url = AppUrls.shared.clubImageUrl(of: TestContent.shared.club.id)
            var request = URLRequest(url: url)
            request.setValue("Basic \(AppUrls.shared.loginString)", forHTTPHeaderField: "Authorization")
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            URLSession.shared.dataTask(with: request) { data, _, _ in
                handler(data)
            }.resume()
        }
        XCTAssertNotNil(imageData, "There was an error in test 13.")
        XCTAssertEqual(imageData!, TestContent.shared.club.image.pngData()!, "Couldn't add club image.")
        
        TestInfos.shared.end()
    }
    
    /// Test 14 | Club Test 11 of  12
    ///
    /// Deletes club and checks if club lists and image are deleted and if club is deleted from allClubs.json
    private func deleteFirstClub() throws {
        TestInfos.shared.start(number: 14, messages: "Club Test 11 of 12", "Deletes club and checks if club lists, person images and club image are deleted and if club is deleted from allClubs.json.")
        
        // Delete club
        let taskState: TaskState = try await { handler in
            let changeItem = DeleteClubChange(clubId: TestContent.shared.club.id)
            Changer.shared.change(changeItem, taskStateHandler: handler)
        }
        XCTAssertEqual(taskState, .passed, "Test 14 | Couldn't delete club.")
        
        // Check club folder
        let statusCode: Int? = try await { handler in
            let url = TestContent.shared.club.folderUrl
            FileManager.default.serverFileStatusCode(of: url, handler)
        }
        XCTAssertNotNil(statusCode, "There was an error in test 14.")
        XCTAssertEqual(statusCode!, 404, "Test 14 | The club folder isn't deleted.")
        
        // Check club image
        let fileExists: Bool? = try await { handler in
            let url = TestContent.shared.club.imageUrl
            FileManager.default.serverFileExists(of: url, handler)
        }
        XCTAssertNotNil(fileExists, "There was an error in test 14.")
        XCTAssertFalse(fileExists!, "Test 14 | The club image isn't deleted.")
        
        // Check allClubs.json
        let allClubs: [Club]? = try await { handler in
            ListFetcher.shared.fetch(handler)
        }
        let containsClub = allClubs?.contains(where: { $0.id == TestContent.shared.club.id })
        XCTAssertNotNil(containsClub, "There was an error in test 14.")
        XCTAssertFalse(containsClub!, "Test 14 | The club isn't deleted in allClubs.json.")
        
        TestInfos.shared.end()
    }
    
    /// Test 15 | Club Test 12 of 12
    ///
    /// Creates new club with apple login and checks if club and person with apple login are in allClubs.json with all properties and if all lists are created
    private func createNewClubAppleLogin() throws {
        TestInfos.shared.start(number: 15, messages: "Club Test 12 of 12", "Create new club with apple login and check if club and person with apple login are in allClubs.json with all properties and if all lists are created.")
        
        // Create new club
        let taskState: TaskState = try await { handler in
            let newClub = ChangerClub(clubId: TestContent.shared.club.id, clubName: TestContent.shared.club.name, personId: TestContent.shared.appleLoginPerson.id, personName: TestContent.shared.appleLoginPerson.personName, login: TestContent.shared.appleLoginPerson.login)
            let changeItem = NewClubChange(club: newClub)
            Changer.shared.change(changeItem, taskStateHandler: handler)
        }
        XCTAssertEqual(taskState, .passed, "Test 15 | Couldn't add new club.")
        
        // Check allClubs.json
        let allClubs: [Club]? = try await { handler in
            ListFetcher.shared.fetch(handler)
        }
        XCTAssertNotNil(allClubs, "There was an error in test 15.")
        let person = Club.ClubPerson(id: TestContent.shared.appleLoginPerson.id, firstName: TestContent.shared.appleLoginPerson.personName.firstName, lastName: TestContent.shared.appleLoginPerson.personName.lastName, login: TestContent.shared.appleLoginPerson.login.encryptedCodable, isCashier: true)
        let club = Club(id: TestContent.shared.club.id, name: TestContent.shared.club.name, allPersons: [person], latePaymentInterest: nil)
        let serverClub = allClubs!.first(where: { $0.id == club.id })
        XCTAssertNotNil(serverClub, "Test 15 | allClubs.json didn't contain new club.")
        XCTAssertEqual(serverClub!, club, "Test 15 | allClubs.json didn't contain all properties.")
        
        // Check if list were created
        let keyPaths: [(KeyPath<AppUrls.ListTypesUrls, URL>, String)] = [(\.person, "Person"), (\.reason, "Reason"), (\.fine, "Fine")]
        for keyPath in keyPaths {
            let fileExists: Bool? = try await { handler in
                let url = AppUrls.shared.listTypesUrls(of: TestContent.shared.club.id)[keyPath: keyPath.0]
                FileManager.default.serverFileExists(of: url, handler)
            }
            XCTAssertNotNil(fileExists, "There was an error in test 15.")
            XCTAssertTrue(fileExists!, "Test 15 | \(keyPath.1) list didn't exist for new club.")
        }
        
        // Check person list
        let personList: [Person]? = try await { handler in
            let url = AppUrls.shared.listTypesUrls(of: TestContent.shared.club.id).person
            ListFetcher.shared.fetch(from: url, handler)
        }
        XCTAssertNotNil(personList, "There was an error in test 15.")
        XCTAssertEqual(personList!, [Person(firstName: TestContent.shared.appleLoginPerson.personName.firstName, lastName: TestContent.shared.appleLoginPerson.personName.lastName, id: TestContent.shared.appleLoginPerson.id)], "Couldn't add person to person list.")
        
        TestInfos.shared.end()
    }
    
    /// Test 16 | Person Test 01 of 10
    ///
    /// Updates none existing person image
    private func updateNoneExistingPersonImage() throws {
        TestInfos.shared.start(number: 16, messages: "Person Test 01 of 10", "Update none existing person image.")
        let taskState: TaskState = try await { handler in
            let changeItem = PersonImageChange(changeType: .update, image: TestContent.shared.appleLoginPerson.image, personId: TestContent.shared.appleLoginPerson.id, clubId: TestContent.shared.club.id)
            Changer.shared.change(changeItem, taskStateHandler: handler)
        }
        XCTAssertEqual(taskState, .passed, "Couldn't update none existing image.")
        TestInfos.shared.end()
    }
    
    /// Test 17 | Person Test 02 of 10
    ///
    /// Deletes none existing person image
    private func deleteNoneExistingPersonImage() throws {
        TestInfos.shared.start(number: 17, messages: "Person Test 02 of 10", "Delete none existing person image.")
        let taskState: TaskState = try await { handler in
            let changeItem = PersonImageChange(changeType: .delete, image: nil, personId: TestContent.shared.appleLoginPerson.id, clubId: TestContent.shared.club.id)
            Changer.shared.change(changeItem, taskStateHandler: handler)
        }
        XCTAssertEqual(taskState, .passed, "Couldn't delete none existing image.")
        TestInfos.shared.end()
    }
    
    /// Test 18 | Person Test 03 of 10
    ///
    /// Adds person image and checks if image is created
    private func addPersonImage() throws {
        TestInfos.shared.start(number: 18, messages: "Person Test 03 of 10", "Add person image and check if image is created.")
        
        // Add image
        let taskState: TaskState = try await { handler in
            let changeItem = PersonImageChange(changeType: .add, image: TestContent.shared.appleLoginPerson.image, personId: TestContent.shared.appleLoginPerson.id, clubId: TestContent.shared.club.id)
            Changer.shared.change(changeItem, taskStateHandler: handler)
        }
        XCTAssertEqual(taskState, .passed, "Couldn't add person image.")
        
        // Check image
        let imageData: Data? = try await { handler in
            let url = AppUrls.shared.personImageUrl(of: TestContent.shared.appleLoginPerson.id, club: TestContent.shared.club.id)
            var request = URLRequest(url: url)
            request.setValue("Basic \(AppUrls.shared.loginString)", forHTTPHeaderField: "Authorization")
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            URLSession.shared.dataTask(with: request) { data, _, _ in
                handler(data)
            }.resume()
        }
        XCTAssertNotNil(imageData, "There was an error in test 18.")
        XCTAssertEqual(imageData!, TestContent.shared.appleLoginPerson.image.pngData()!, "Couldn't add person image.")
        
        TestInfos.shared.end()
    }
    
    /// Test 19 | Person Test 04 of 10
    ///
    /// Add same person image
    private func addSamePersonImage() throws {
        TestInfos.shared.start(number: 19, messages: "Person Test 04 of 10", "Add same person image.")
        
        // Add image
        let taskState: TaskState = try await { handler in
            let changeItem = PersonImageChange(changeType: .add, image: TestContent.shared.appleLoginPerson.secondImage, personId: TestContent.shared.appleLoginPerson.id, clubId: TestContent.shared.club.id)
            Changer.shared.change(changeItem, taskStateHandler: handler)
        }
        XCTAssertEqual(taskState, .passed, "Couldn't add same person image.")
        
        // Check image
        let imageData: Data? = try await { handler in
            let url = AppUrls.shared.personImageUrl(of: TestContent.shared.appleLoginPerson.id, club: TestContent.shared.club.id)
            var request = URLRequest(url: url)
            request.setValue("Basic \(AppUrls.shared.loginString)", forHTTPHeaderField: "Authorization")
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            URLSession.shared.dataTask(with: request) { data, _, _ in
                handler(data)
            }.resume()
        }
        XCTAssertNotNil(imageData, "There was an error in test 19.")
        XCTAssertEqual(imageData!, TestContent.shared.club.image.pngData()!, "Add a image.")
        
        TestInfos.shared.end()
    }
    
    /// Test 20 | Person Test 05 of 10
    ///
    /// Updates person image and checks if image is updated
    private func updatePersonImage() throws {
        TestInfos.shared.start(number: 20, messages: "Person Test 05 of 10", "Update person image and check if image is updated.")
        
        // Update image
        let taskState: TaskState = try await { handler in
            let changeItem = PersonImageChange(changeType: .update, image: TestContent.shared.appleLoginPerson.secondImage, personId: TestContent.shared.appleLoginPerson.id, clubId: TestContent.shared.club.id)
            Changer.shared.change(changeItem, taskStateHandler: handler)
        }
        XCTAssertEqual(taskState, .passed, "Couldn't update person image.")
        
        // Check image
        let imageData: Data? = try await { handler in
            let url = AppUrls.shared.personImageUrl(of: TestContent.shared.appleLoginPerson.id, club: TestContent.shared.club.id)
            var request = URLRequest(url: url)
            request.setValue("Basic \(AppUrls.shared.loginString)", forHTTPHeaderField: "Authorization")
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            URLSession.shared.dataTask(with: request) { data, _, _ in
                handler(data)
            }.resume()
        }
        XCTAssertNotNil(imageData, "There was an error in test 20.")
        XCTAssertEqual(imageData!, TestContent.shared.club.secondImage.pngData()!, "Couldn't update person image.")
        
        TestInfos.shared.end()
    }
    
    /// Test 21 | Person Test 06 of 10
    ///
    /// Deletes person image and checks if image is deleted
    private func deletePersonImage()  throws {
        TestInfos.shared.start(number: 21, messages: "Person Test 06 of 10", "Delete person image and check if image is deleted")
        
        // Delete image
        let taskState: TaskState = try await { handler in
            let changeItem = PersonImageChange(changeType: .delete, image: nil, personId: TestContent.shared.appleLoginPerson.id, clubId: TestContent.shared.club.id)
            Changer.shared.change(changeItem, taskStateHandler: handler)
        }
        XCTAssertEqual(taskState, .passed, "Couldn't delete person image.")
        
        // Check image
        let fileExists: Bool? = try await { handler in
            let url = AppUrls.shared.personImageUrl(of: TestContent.shared.appleLoginPerson.id, club: TestContent.shared.club.id)
            FileManager.default.serverFileExists(of: url, handler)
        }
        XCTAssertNotNil(fileExists, "There was an error in test 21.")
        XCTAssertFalse(fileExists!, "Couldn't delete person image.")
        
        TestInfos.shared.end()
    }
    
    /// Test 22 | Person Test 07 of 10
    ///
    /// Registers new person with email login and checks if person is added to allClubs.json and to person list with all properties
    private func registerPersonEmailLogin() throws {
        TestInfos.shared.start(number: 22, messages: "Person Test 07 of 10", "Register new person with email login and check if person is added to allClubs.json and to person list with all properties")
        
        // Register person
        let taskState: TaskState = try await { handler in
            let changeItem = RegisterPersonChange(person: RegisterPerson(clubId: TestContent.shared.club.id, personId: TestContent.shared.emailLoginPerson.id, personName: TestContent.shared.emailLoginPerson.personName, login: TestContent.shared.emailLoginPerson.login))
            Changer.shared.change(changeItem, taskStateHandler: handler)
        }
        XCTAssertEqual(taskState, .passed, "Couldn't register new person.")
        
        // Check allClubs.json
        let allClubs: [Club]? = try await { handler in
            ListFetcher.shared.fetch(handler)
        }
        XCTAssertNotNil(allClubs, "There was an error in test 22.")
        let person = Club.ClubPerson(id: TestContent.shared.emailLoginPerson.id, firstName: TestContent.shared.emailLoginPerson.personName.firstName, lastName: TestContent.shared.emailLoginPerson.personName.lastName, login: TestContent.shared.emailLoginPerson.login.encryptedCodable, isCashier: false)
        let serverPerson = allClubs!.first(where: { $0.id == TestContent.shared.club.id })?.allPersons.first(where: { $0.id == TestContent.shared.emailLoginPerson.id })
        XCTAssertNotNil(serverPerson, "Test 22 | allClubs.json didn't contain new person.")
        XCTAssertEqual(serverPerson!, person, "Test 22 | allClubs.json didn't contain all properties.")
        
        // Check person list
        let personList: [Person]? = try await { handler in
            let url = AppUrls.shared.listTypesUrls(of: TestContent.shared.club.id).person
            ListFetcher.shared.fetch(from: url, handler)
        }
        let serverPerson2 = personList?.first(where: { $0.id == TestContent.shared.emailLoginPerson.id })
        XCTAssertNotNil(serverPerson2, "There was an error in test 22.")
        XCTAssertEqual(serverPerson2!, Person(firstName: TestContent.shared.emailLoginPerson.personName.firstName, lastName: TestContent.shared.emailLoginPerson.personName.lastName, id: TestContent.shared.emailLoginPerson.id), "Couldn't add person to person list.")
        
        TestInfos.shared.end()
    }
    
    /// Test 23 | Person Test 08 of 10
    ///
    /// Force sign out a registered person and checks if person is deleted in allClubs.json
    private func forceSignOut() throws {
        TestInfos.shared.start(number: 23, messages: "Person Test 08 of 10", "Force sign out a registered person and check if person is deleted in allClubs.json")
        
        // Force sign out
        let taskState: TaskState = try await { handler in
            let changeItem = ForceSignOutChange(personId: TestContent.shared.appleLoginPerson.id, clubId: TestContent.shared.club.id)
            Changer.shared.change(changeItem, taskStateHandler: handler)
        }
        XCTAssertEqual(taskState, .passed, "Couldn't force sign out person.")
        
        // Check allClubs.json
        let allClubs: [Club]? = try await { handler in
            ListFetcher.shared.fetch(handler)
        }
        XCTAssertNotNil(allClubs, "There was an error in test 23.")
        let serverClub = allClubs!.first(where: { $0.id == TestContent.shared.club.id })
        XCTAssertNotNil(serverClub, "There was an error in test 23.")
        let person = Club.ClubPerson(id: TestContent.shared.emailLoginPerson.id, firstName: TestContent.shared.emailLoginPerson.personName.firstName, lastName: TestContent.shared.emailLoginPerson.personName.lastName, login: TestContent.shared.emailLoginPerson.login.encryptedCodable, isCashier: false)
        XCTAssertEqual(serverClub!.allPersons, [person], "Didn't force sign out person")
        
        TestInfos.shared.end()
    }
    
    /// Test 24 | Person Test 09 of 10
    ///
    /// Registers new person with apple login and checks if person is added to allClubs.json and to person list with all properties
    private func registerPersonAppleLogin() throws {
        TestInfos.shared.start(number: 24, messages: "Person Test 08 of 10", "Register new person with apple login and check if person is added to allClubs.json and to person list with all properties")
        
        // Register person
        let taskState: TaskState = try await { handler in
            let changeItem = RegisterPersonChange(person: RegisterPerson(clubId: TestContent.shared.club.id, personId: TestContent.shared.appleLoginPerson.id, personName: TestContent.shared.appleLoginPerson.personName, login: TestContent.shared.appleLoginPerson.login))
            Changer.shared.change(changeItem, taskStateHandler: handler)
        }
        XCTAssertEqual(taskState, .passed, "Couldn't register new person.")
        
        // Check allClubs.json
        let allClubs: [Club]? = try await { handler in
            ListFetcher.shared.fetch(handler)
        }
        XCTAssertNotNil(allClubs, "There was an error in test 24.")
        let person = Club.ClubPerson(id: TestContent.shared.appleLoginPerson.id, firstName: TestContent.shared.appleLoginPerson.personName.firstName, lastName: TestContent.shared.appleLoginPerson.personName.lastName, login: TestContent.shared.appleLoginPerson.login.encryptedCodable, isCashier: false)
        let serverPerson = allClubs!.first(where: { $0.id == TestContent.shared.club.id })?.allPersons.first(where: { $0.id == TestContent.shared.appleLoginPerson.id })
        XCTAssertNotNil(serverPerson, "Test 24 | allClubs.json didn't contain new person.")
        XCTAssertEqual(serverPerson!, person, "Test 24 | allClubs.json didn't contain all properties.")
        
        // Check person list
        let personList: [Person]? = try await { handler in
            let url = AppUrls.shared.listTypesUrls(of: TestContent.shared.club.id).person
            ListFetcher.shared.fetch(from: url, handler)
        }
        let serverPerson2 = personList?.first(where: { $0.id == TestContent.shared.appleLoginPerson.id })
        XCTAssertNotNil(serverPerson2, "There was an error in test 22.")
        XCTAssertEqual(serverPerson2!, Person(firstName: TestContent.shared.appleLoginPerson.personName.firstName, lastName: TestContent.shared.appleLoginPerson.personName.lastName, id: TestContent.shared.appleLoginPerson.id), "Couldn't add person to person list.")
        
        TestInfos.shared.end()
    }
    
    /// Test 25 | Late Payment Interest Test 1 of 2
    ///
    /// Sets late payment interest and checks in allClubs.json with all properties
    private func setLatePaymentInterest() throws {
        TestInfos.shared.start(number: 25, messages: "Late Payment Interest Test 1 of 2", "Set late payment interest and check in allClubs.json with all properties.")
        
        // Set late payment interest
        let latePaymentInterest = Settings.LatePaymentInterest(interestFreePeriod: .init(value: 10, unit: .month), interestRate: 2.5, interestPeriod: .init(value: 1, unit: .day), compoundInterest: true)
        let taskState: TaskState = try await { handler in
            let changeItem = LatePaymentInterestChange(latePaymentInterest: latePaymentInterest, clubId: TestContent.shared.club.id)
            Changer.shared.change(changeItem, taskStateHandler: handler)
        }
        XCTAssertEqual(taskState, .passed, "Test 25 | Couldn't set late payment interest.")
        
        // Check late payment interest
        let allClubs: [Club]? = try await { handler in
            ListFetcher.shared.fetch(handler)
        }
        let club = allClubs?.first(where: { $0.id == TestContent.shared.club.id })
        XCTAssertNotNil(club, "There was an error in test 25.")
        XCTAssertEqual(club!.latePaymentInterest, latePaymentInterest, "Test 25 | Couldn't set late payment interest.")
        
        TestInfos.shared.end()
    }
    
    /// Test 26 | Late Payment Interest Test 2 of 2
    ///
    /// Sets late payment interest to nil and checks in allClubs.json
    private func unsetLatePaymentInterest() throws {
        TestInfos.shared.start(number: 26, messages: "Late Payment Interest Test 2 of 2", "Set late payment interest to nil and check in allClubs.json.")
        
        // Set late payment interest
        let taskState: TaskState = try await { handler in
            let changeItem = LatePaymentInterestChange(latePaymentInterest: nil, clubId: TestContent.shared.club.id)
            Changer.shared.change(changeItem, taskStateHandler: handler)
        }
        XCTAssertEqual(taskState, .passed, "Test 26 | Couldn't unset late payment interest.")
        
        // Check late payment interest
        let allClubs: [Club]? = try await { handler in
            ListFetcher.shared.fetch(handler)
        }
        let club = allClubs?.first(where: { $0.id == TestContent.shared.club.id })
        XCTAssertNotNil(club, "There was an error in test 26.")
        XCTAssertNil(club!.latePaymentInterest, "Test 26 | Couldn't unset late payment interest.")
        
        TestInfos.shared.end()
    }
    
    /// Test 27 | Person Test 10 of 10
    ///
    /// Adds person image without person and checks if image is created
    private func addPersonImageAgain() throws {
        TestInfos.shared.start(number: 27, messages: "Person Test 10 of 10", "Add person image without person and check if image is created.")
        
        // Add image
        let taskState: TaskState = try await { handler in
            let changeItem = PersonImageChange(changeType: .add, image: TestContent.shared.appleLoginPerson.image, personId: TestContent.shared.personSecond.id, clubId: TestContent.shared.club.id)
            Changer.shared.change(changeItem, taskStateHandler: handler)
        }
        XCTAssertEqual(taskState, .passed, "Couldn't add person image.")
        
        // Check image
        let imageData: Data? = try await { handler in
            let url = AppUrls.shared.personImageUrl(of: TestContent.shared.personSecond.id, club: TestContent.shared.club.id)
            var request = URLRequest(url: url)
            request.setValue("Basic \(AppUrls.shared.loginString)", forHTTPHeaderField: "Authorization")
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            URLSession.shared.dataTask(with: request) { data, _, _ in
                handler(data)
            }.resume()
        }
        XCTAssertNotNil(imageData, "There was an error in test 27.")
        XCTAssertEqual(imageData!, TestContent.shared.appleLoginPerson.image.pngData()!, "Couldn't add person image.")
        
        TestInfos.shared.end()
    }
    
    /// Test 28 | List Type Test 1 of 6
    ///
    /// Updates none existing person / fine (custom and template) / reason
    private func updateNoneExistingListTypes() throws {
        TestInfos.shared.start(number: 28, messages: "List Type Test 1 of 6", "Update none existing person / fine (custom and template) / reason.")
        
        func executeTest<ListType>(with listType: ListType, type description: String) throws where ListType: ListTypes {
            let taskState: TaskState = try await { handler in
                let changeItem = ServerListChange(changeType: .update, item: listType, clubId: TestContent.shared.club.id)
                Changer.shared.change(changeItem, taskStateHandler: handler)
            }
            XCTAssertEqual(taskState, .passed, "Test 28 | Couldn't update none existing List Type of type \(description).")
        }
        
        try executeTest(with: TestContent.shared.person, type: "Person")
        try executeTest(with: TestContent.shared.reason, type: "Reason")
        try executeTest(with: TestContent.shared.fineCustom, type: "Fine Custom")
        try executeTest(with: TestContent.shared.fineTemplate, type: "Fine Template")
        
        TestInfos.shared.end()
    }
    
    /// Test 29 | List Type Test 2 of 6
    ///
    /// Deletes none existing person / fine (custom and template) / reason
    private func deleteNoneExistingListTypes() throws {
        TestInfos.shared.start(number: 29, messages: "List Type Test 2 of 6", "Delete none existing person / fine (custom and template) / reason.")
        
        func executeTest<ListType>(with listType: ListType, type description: String) throws where ListType: ListTypes {
            let taskState: TaskState = try await { handler in
                let changeItem = ServerListChange(changeType: .delete, item: listType, clubId: TestContent.shared.club.id)
                Changer.shared.change(changeItem, taskStateHandler: handler)
            }
            XCTAssertEqual(taskState, .passed, "Test 29 | Couldn't delete none existing List Type of type \(description).")
        }
        
        try executeTest(with: TestContent.shared.person, type: "Person")
        try executeTest(with: TestContent.shared.reason, type: "Reason")
        try executeTest(with: TestContent.shared.fineCustom, type: "Fine Custom")
        try executeTest(with: TestContent.shared.fineTemplate, type: "Fine Template")
        
        TestInfos.shared.end()
    }
    
    /// Test 30 | List Type Test 3 of 6
    ///
    /// Adds person / fine (custom and template) / reason and checks if all properties are set
    private func addListTypes() throws {
        TestInfos.shared.start(number: 30, messages: "List Type Test 3 of 6", "Add person / fine (custom and template) / reason and check if all properties are set.")
        
        func executeTest<ListType>(with listType: ListType, keyPath: KeyPath<AppUrls.ListTypesUrls, URL>, type description: String) throws where ListType: ListTypes & Equatable {
            
            // Add list type
            let taskState: TaskState = try await { handler in
                let changeItem = ServerListChange(changeType: .add, item: listType, clubId: TestContent.shared.club.id)
                Changer.shared.change(changeItem, taskStateHandler: handler)
            }
            XCTAssertEqual(taskState, .passed, "Test 30 | Couldn't add List Type of type \(description).")
            
            // Check list type
            let serverListTypeList: [ListType]? = try await { handler in
                let url = AppUrls.shared.listTypesUrls(of: TestContent.shared.club.id)[keyPath: keyPath]
                ListFetcher.shared.fetch(from: url, handler)
            }
            XCTAssertNotNil(serverListTypeList, "There was an error in test 30 of type \(description).")
            let serverListType = serverListTypeList!.first(where: { $0.id == listType.id })
            XCTAssertNotNil(serverListType, "Test 30 | Couldn't add List Type of type \(description).")
            XCTAssertEqual(listType, serverListType, "Test 30 | Couldn't add List Type of type \(description).")
            
        }
        
        try executeTest(with: TestContent.shared.person, keyPath: \.person, type: "Person")
        try executeTest(with: TestContent.shared.reason, keyPath: \.reason, type: "Reason")
        try executeTest(with: TestContent.shared.fineCustom, keyPath: \.fine, type: "Fine Custom")
        try executeTest(with: TestContent.shared.fineTemplate, keyPath: \.fine, type: "Fine Template")
        
        TestInfos.shared.end()
    }
    
    /// Test 31 | List Type Test 4 of 6
    ///
    /// Adds same person / fine (custom and template) / reason and checks if all properties are set
    private func addSameListTypes() throws {
        TestInfos.shared.start(number: 31, messages: "List Type Test 4 of 6", "Add same person / fine (custom and template) / reason and check if all properties are set.")
        
        func executeTest<ListType>(with listType: ListType, oldListType: ListType, keyPath: KeyPath<AppUrls.ListTypesUrls, URL>, type description: String) throws where ListType: ListTypes & Equatable {
            
            // Add list type
            let taskState: TaskState = try await { handler in
                let changeItem = ServerListChange(changeType: .add, item: listType, clubId: TestContent.shared.club.id)
                Changer.shared.change(changeItem, taskStateHandler: handler)
            }
            XCTAssertEqual(taskState, .passed, "Test 31 | Couldn't add same List Type of type \(description).")
            
            // Check list type
            let serverListTypeList: [ListType]? = try await { handler in
                let url = AppUrls.shared.listTypesUrls(of: TestContent.shared.club.id)[keyPath: keyPath]
                ListFetcher.shared.fetch(from: url, handler)
            }
            XCTAssertNotNil(serverListTypeList, "There was an error in test 31 of type \(description).")
            let serverListType = serverListTypeList!.first(where: { $0.id == listType.id })
            XCTAssertNotNil(serverListType, "Test 31 | Couldn't add same List Type of type \(description).")
            XCTAssertEqual(oldListType, serverListType, "Test 31 | Couldn't add same List Type of type \(description).")
            
        }
        
        try executeTest(with: TestContent.shared.personSecond, oldListType: TestContent.shared.person, keyPath: \.person, type: "Person")
        try executeTest(with: TestContent.shared.reasonSecond, oldListType: TestContent.shared.reason, keyPath: \.reason, type: "Reason")
        try executeTest(with: TestContent.shared.fineCustomSecond, oldListType: TestContent.shared.fineCustom, keyPath: \.fine, type: "Fine Custom")
        try executeTest(with: TestContent.shared.fineTemplateSecond, oldListType: TestContent.shared.fineTemplate, keyPath: \.fine, type: "Fine Template")
        
        TestInfos.shared.end()
    }
    
    /// Test 32 | List Type Test 5 of 6
    ///
    /// Updates person / fine (custom and template) / reason and checks if all properties are set
    private func updateListTypes() throws {
        TestInfos.shared.start(number: 32, messages: "List Type Test 5 of 6", "Updates person / fine (custom and template) / reason and check if all properties are set.")
        
        func executeTest<ListType>(with listType: ListType, keyPath: KeyPath<AppUrls.ListTypesUrls, URL>, type description: String) throws where ListType: ListTypes & Equatable {
            
            // Add list type
            let taskState: TaskState = try await { handler in
                let changeItem = ServerListChange(changeType: .update, item: listType, clubId: TestContent.shared.club.id)
                Changer.shared.change(changeItem, taskStateHandler: handler)
            }
            XCTAssertEqual(taskState, .passed, "Test 32 | Couldn't update List Type of type \(description).")
            
            // Check list type
            let serverListTypeList: [ListType]? = try await { handler in
                let url = AppUrls.shared.listTypesUrls(of: TestContent.shared.club.id)[keyPath: keyPath]
                ListFetcher.shared.fetch(from: url, handler)
            }
            XCTAssertNotNil(serverListTypeList, "There was an error in test 32 of type \(description).")
            let serverListType = serverListTypeList!.first(where: { $0.id == listType.id })
            XCTAssertNotNil(serverListType, "Test 32 | Couldn't update List Type of type \(description).")
            XCTAssertEqual(listType, serverListType, "Test 32 | Couldn't update List Type of type \(description).")
            
        }
        
        try executeTest(with: TestContent.shared.personSecond, keyPath: \.person, type: "Person")
        try executeTest(with: TestContent.shared.reasonSecond, keyPath: \.reason, type: "Reason")
        try executeTest(with: TestContent.shared.fineCustomSecond, keyPath: \.fine, type: "Fine Custom")
        try executeTest(with: TestContent.shared.fineTemplateSecond, keyPath: \.fine, type: "Fine Template")
        
        TestInfos.shared.end()
    }
    
    /// Test 33 | List Type Test 6 of 6
    ///
    /// Deletes person / fine (custom and template) / reason and checks if all properties  and person image are deleted
    private func deleteListTypes() throws {
        TestInfos.shared.start(number: 33, messages: "List Type Test 6 of 6", "Updates person / fine (custom and template) / reason and check if all properties and person image are deleted.")
        
        func executeTest<ListType>(with listType: ListType, keyPath: KeyPath<AppUrls.ListTypesUrls, URL>, type description: String) throws where ListType: ListTypes {
            
            // Add list type
            let taskState: TaskState = try await { handler in
                let changeItem = ServerListChange(changeType: .delete, item: listType, clubId: TestContent.shared.club.id)
                Changer.shared.change(changeItem, taskStateHandler: handler)
            }
            XCTAssertEqual(taskState, .passed, "Test 33 | Couldn't delete List Type of type \(description).")
            
            // Check list type
            let serverListTypeList: [ListType]? = try await { handler in
                let url = AppUrls.shared.listTypesUrls(of: TestContent.shared.club.id)[keyPath: keyPath]
                ListFetcher.shared.fetch(from: url, handler)
            }
            XCTAssertNotNil(serverListTypeList, "There was an error in test 33 of type \(description).")
            let serverListType = serverListTypeList!.first(where: { $0.id == listType.id })
            XCTAssertNil(serverListType, "Test 33 | Couldn't delete List Type of type \(description).")
            
        }
        
        try executeTest(with: TestContent.shared.personSecond, keyPath: \.person, type: "Person")
        try executeTest(with: TestContent.shared.reasonSecond, keyPath: \.reason, type: "Reason")
        try executeTest(with: TestContent.shared.fineCustomSecond, keyPath: \.fine, type: "Fine Custom")
        try executeTest(with: TestContent.shared.fineTemplateSecond, keyPath: \.fine, type: "Fine Template")
        
        // Check person image
        let fileExists: Bool? = try await { handler in
            let url = AppUrls.shared.personImageUrl(of: TestContent.shared.personSecond.id, club: TestContent.shared.club.id)
            FileManager.default.serverFileExists(of: url, handler)
        }
        XCTAssertNotNil(fileExists, "There was an error in test 33.")
        XCTAssertFalse(fileExists!, "Couldn't delete person image.")
        
        TestInfos.shared.end()
    }
    
    /// Test 34 | Finishing Test 1 of 1
    ///
    /// Deletes club and checks if club lists, person images and club image are deleted and if club is deleted from allClubs.json
    private func deleteClub(forReset: Bool = false) throws {
        if !forReset {
            TestInfos.shared.start(number: 34, messages: "Finishing Test 1 of 1", "Deletes club and checks if club lists, person images and club image are deleted and if club is deleted from allClubs.json.")
        }
        
        // Delete club
        let taskState: TaskState = try await { handler in
            let changeItem = DeleteClubChange(clubId: TestContent.shared.club.id)
            Changer.shared.change(changeItem, taskStateHandler: handler)
        }
        XCTAssertEqual(taskState, .passed, "Test 34 | Couldn't delete club.")
        
        // Check club folder
        let statusCode: Int? = try await { handler in
            let url = TestContent.shared.club.folderUrl
            FileManager.default.serverFileStatusCode(of: url, handler)
        }
        XCTAssertNotNil(statusCode, "There was an error in test 34.")
        XCTAssertEqual(statusCode!, 404, "Test 34 | The club folder isn't deleted.")
        
        // Check club image
        let fileExists: Bool? = try await { handler in
            let url = TestContent.shared.club.imageUrl
            FileManager.default.serverFileExists(of: url, handler)
        }
        XCTAssertNotNil(fileExists, "There was an error in test 34.")
        XCTAssertFalse(fileExists!, "Test 34 | The club image isn't deleted.")
        
        // Check allClubs.json
        let allClubs: [Club]? = try await { handler in
            ListFetcher.shared.fetch(handler)
        }
        let containsClub = allClubs?.contains(where: { $0.id == TestContent.shared.club.id })
        XCTAssertNotNil(containsClub, "There was an error in test 34.")
        XCTAssertFalse(containsClub!, "Test 34 | The club isn't deleted in allClubs.json.")
        
        if !forReset {
            TestInfos.shared.end()
        }
    }
}

fileprivate struct TestInfos {
    
    static var shared = Self()
    
    private init() {}
    
    private let numberTests = 35
    
    private var lastTestStartTime: TimeInterval?
    
    private var lastTestNumber: Int?
    
    /// Prints an info message that a test has started
    mutating func start(number testNumber: Int, messages: String...) {
        guard lastTestStartTime == nil else {
            fatalError("End isn't called")
        }
        guard testNumber == (lastTestNumber ?? (testNumber - 1)) + 1 else {
            fatalError("Tests aren't in correct sequence")
        }
        lastTestStartTime = Date().timeIntervalSince1970
        lastTestNumber = testNumber
        let numberTestDigitCount = String(numberTests).count
        let testNumberDigitCount = String(testNumber).count
        let digitDifference = numberTestDigitCount - testNumberDigitCount
        let testNumberString = Array(repeating: "0", count: digitDifference).joined() + String(testNumber)
        var stringToPrint = "INFO: Test \(testNumberString) of \(numberTests) Started"
        for message in messages {
            stringToPrint += " | \(message)"
        }
        print(stringToPrint)
    }
    
    /// Prints an info message that a test has ended
    mutating func end() {
        guard let startTime = lastTestStartTime, let testNumber = lastTestNumber else {
            fatalError("End test called before test started")
        }
        lastTestStartTime = nil
        let endTime = Date().timeIntervalSince1970
        let difference = endTime - startTime
        let numberTestDigitCount = String(numberTests).count
        let testNumberDigitCount = String(testNumber).count
        let digitDifference = numberTestDigitCount - testNumberDigitCount
        let testNumberString = Array(repeating: "0", count: digitDifference).joined() + String(testNumber)
        print("   -> Test \(testNumberString) of \(numberTests) Ended in \(difference) seconds\n")
    }
}

extension XCTestCase {
    
    fileprivate enum TimeoutError: Error {
        case dataTaskExpired
    }
    
    fileprivate func await<Value>(timeout: TimeInterval = 60, _ handler: (@escaping (Value) -> Void) -> Void) throws -> Value {
        let expectation = self.expectation(description: "Expactation")
        var result: Value?
        handler { value in
            if result == nil {
                result = value
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: timeout)
        guard let unwrappedResult = result else {
            throw TimeoutError.dataTaskExpired
        }
        return unwrappedResult
    }
}

extension FileManager {
    fileprivate func serverFileExists(of url: URL, _ completion: @escaping (Bool?) -> Void) {
        var request = URLRequest(url: url)
        request.setValue("Basic \(AppUrls.shared.loginString)", forHTTPHeaderField: "Authorization")
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        URLSession.shared.dataTask(with: request) { _, response, _ in
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                return completion(nil)
            }
            completion((200..<300).contains(statusCode))
        }.resume()
    }
    
    fileprivate func serverFileStatusCode(of url: URL, _ completion: @escaping (Int?) -> Void) {
        var request = URLRequest(url: url)
        request.setValue("Basic \(AppUrls.shared.loginString)", forHTTPHeaderField: "Authorization")
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        URLSession.shared.dataTask(with: request) { _, response, _ in
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            completion(statusCode)
        }.resume()
    }
}

fileprivate struct TestContent {
    struct Club {
        let id = UUID(uuidString: "9991acfa-5b09-4a21-9a8e-b273ff56bef6")!
        let name = "Test Club Name"
        let image = UIImage(systemName: "circle")!
        let secondImage = UIImage(systemName: "circle.fill")!
        var folderUrl: URL {
            AppUrls.shared.clubFolderUrl(of: id)
        }
        var listTypeUrls: AppUrls.ListTypesUrls {
            AppUrls.shared.listTypesUrls(of: id)
        }
        var imageUrl: URL {
            AppUrls.shared.baseUrl.appendingPathComponent(AppUrls.shared.codableAppUrls.imagesDirectory).appendingPathComponent(id.uuidString).appendingPathExtension("png")
        }
    }
    struct EmailLoginPerson {
        let id = UUID(uuidString: "22e67e89-4b18-4d42-87a1-e73db7416687")!
        let login = PersonLoginEmail(email: "Person Email", password: "Person Password")
        let personName = PersonName(firstName: "Person Email Login First Name", lastName: "Person Email Login Last Name")
    }
    struct AppleLoginPerson {
        let id = UUID(uuidString: "d21e80bf-9a0d-474a-a5e1-5fc3d4f8b867")!
        let login = PersonLoginApple(appleIdentifier: "Person AppleIdentifier")
        let personName = PersonName(firstName: "Person Apple Login First Name", lastName: "Person Apple Login Last Name")
        let image = UIImage(systemName: "circle")!
        let secondImage = UIImage(systemName: "circle.fill")!
    }
    
    static let shared = TestContent()
    private init() {}
    
    let club = Club()
    let emailLoginPerson = EmailLoginPerson()
    let appleLoginPerson = AppleLoginPerson()
    let person = Person(firstName: "Test Person First Name", lastName: "Test Person Last Name", id: UUID(uuidString: "5ea73630-d01e-4bc3-b725-21ba3edd5943")!)
    let reason = Reason(reason: "Test Reason Reason", id: UUID(uuidString: "64011f1c-b8ed-4047-b07a-a448551b91a6")!, amount: Euro(euro: 10, cent: 50), importance: .medium)
    let fineCustom = Fine(personId: UUID(uuidString: "5ea73630-d01e-4bc3-b725-21ba3edd5943")!, date: FormattedDate(date: Date(timeIntervalSince1970: 123456)), payed: .payed(date: Date(timeIntervalSince1970: 65431)), number: 2, id: UUID(uuidString: "9a4e5a2e-fca3-4b00-b04c-ba896b924a77")!, fineReason: FineReasonCustom(reason: "Test Fine Custom Reason", amount: Euro(euro: 4, cent: 23), importance: .high))
    let fineTemplate = Fine(personId: UUID(uuidString: "5ea73630-d01e-4bc3-b725-21ba3edd5943")!, date: FormattedDate(date: Date(timeIntervalSince1970: 444444)), payed: .unpayed, number: 1, id: UUID(uuidString: "ee06f12c-d8ba-4838-b80c-9aacbe9325f1")!, fineReason: FineReasonTemplate(templateId: UUID(uuidString: "64011f1c-b8ed-4047-b07a-a448551b91a6")!))
    let personSecond = Person(firstName: "Test Person First Name Second", lastName: "Test Person Last Name Second", id: UUID(uuidString: "5ea73630-d01e-4bc3-b725-21ba3edd5943")!)
    let reasonSecond = Reason(reason: "Test Reason Reason Second", id: UUID(uuidString: "64011f1c-b8ed-4047-b07a-a448551b91a6")!, amount: Euro(euro: 11, cent: 51), importance: .low)
    let fineCustomSecond = Fine(personId: UUID(uuidString: "5ea73630-d01e-4bc3-b725-21ba3edd5943")!, date: FormattedDate(date: Date(timeIntervalSince1970: 765765)), payed: .unpayed, number: 8, id: UUID(uuidString: "9a4e5a2e-fca3-4b00-b04c-ba896b924a77")!, fineReason: FineReasonTemplate(templateId: UUID(uuidString: "64011f1c-b8ed-4047-b07a-a448551b91a6")!))
    let fineTemplateSecond = Fine(personId: UUID(uuidString: "5ea73630-d01e-4bc3-b725-21ba3edd5943")!, date: FormattedDate(date: Date(timeIntervalSince1970: 876273)), payed: .payed(date: Date(timeIntervalSince1970: 287849)), number: 6, id: UUID(uuidString: "ee06f12c-d8ba-4838-b80c-9aacbe9325f1")!, fineReason: FineReasonCustom(reason: "Test Fine Second Custom Reason", amount: Euro(euro: 7, cent: 90), importance: .medium))
}

extension AppUrls {
    fileprivate func clubFolderUrl(of clubId: UUID) -> URL {
        baseUrl.appendingPathComponent("clubs").appendingPathComponent(clubId.uuidString)
    }
    
    fileprivate func listTypesUrls(of clubId: UUID) -> ListTypesUrls {
        let baseUrl = clubFolderUrl(of: clubId)
        let personUrl = baseUrl.appendingPathComponent(codableAppUrls.lists.person)
        let fineUrl = baseUrl.appendingPathComponent(codableAppUrls.lists.fine)
        let reasonUrl = baseUrl.appendingPathComponent(codableAppUrls.lists.reason)
        return ListTypesUrls(person: personUrl, fine: fineUrl, reason: reasonUrl)
    }
    
    fileprivate func clubImageUrl(of clubId: UUID) -> URL {
        baseUrl.appendingPathComponent(codableAppUrls.imagesDirectory).appendingPathComponent(clubId.uuidString).appendingPathExtension("png")
    }
    
    fileprivate func personImageUrl(of personId: UUID, club clubId: UUID) -> URL {
        baseUrl.appendingPathComponent("clubs").appendingPathComponent(clubId.uuidString).appendingPathComponent(codableAppUrls.imagesDirectory).appendingPathComponent(personId.uuidString).appendingPathExtension("png")
    }
}

extension PersonLoginEmail {
    fileprivate var encryptedCodable: PersonLoginCodable {
        PersonLoginCodable(email: email, password: password.encrypted, appleIdentifier: nil)
    }
}

extension PersonLoginApple {
    fileprivate var encryptedCodable: PersonLoginCodable {
        PersonLoginCodable(email: nil, password: nil, appleIdentifier: appleIdentifier)
    }
}
