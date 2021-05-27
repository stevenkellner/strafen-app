//
//  Settings.swift
//  Strafen
//
//  Created by Steven on 25.05.21.
//

import SwiftUI

/// Contains all properies of the settings of the app of this device
class Settings: ObservableObject {

    /// Shared instance for singelton
    static let shared = Settings()

    /// Private init for singleton
    private init() {
        guard let jsonData = FileManager.default.contents(atPath: Settings.settingsUrl.path) else { return }
        let decoder = JSONDecoder()
        guard let settings = try? decoder.decode(Settings.self, from: jsonData) else { return }
        self.person = settings.person
        self.latePaymentInterest = latePaymentInterest
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        person = try container.decodeIfPresent(Person.self, forKey: .person)
        latePaymentInterest = try container.decodeIfPresent(LatePaymentInterest.self, forKey: .latePaymentInterest)
    }

    /// Properties of logged in person
    @Published var person: Person? {
        didSet { saveSettings() }
    }

    /// Properties for late payment interest
    @Published var latePaymentInterest: LatePaymentInterest? {
        didSet { saveSettings() }
    }

    /// Saves settings
    private func saveSettings() {
        let encoder = JSONEncoder()
        guard let jsonData = try? encoder.encode(self) else { return }
        if FileManager.default.fileExists(atPath: Settings.settingsUrl.path) {
            try? jsonData.write(to: Settings.settingsUrl, options: .atomic)
        } else {
            FileManager.default.createFile(atPath: Settings.settingsUrl.path, contents: jsonData)
        }
    }

    /// Url to saved settings
    static private var settingsUrl: URL {
        FileManager.default.sharedContainerUrl
            .appendingPathComponent("settings_v3")
            .appendingPathExtension("json")
    }
}

extension Settings: Decodable {

    /// Coding keys for Codable
    enum CodingKeys: CodingKey {
        case person, latePaymentInterest
    }
}

extension Settings: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(person, forKey: .person)
        try container.encode(latePaymentInterest, forKey: .latePaymentInterest)
    }
}

extension Settings {

    /// Properties of logged in person
    class Person: ObservableObject, Codable {

        /// Properties of the club
        let club: Club

        /// Id of logged in person
        let id: FirebasePerson.ID // swiftlint:disable:this identifier_name

        /// Name of logged in person
        let name: PersonName

        /// Date of sign in of logged in person
        let signInDate: Date

        /// Indicates whether logged in person is cashier of the club
        let isCashier: Bool

        init(club: Club, id: FirebasePerson.ID, name: PersonName, signInDate: Date, isCashier: Bool) { // swiftlint:disable:this identifier_name
            self.club = club
            self.id = id
            self.name = name
            self.signInDate = signInDate
            self.isCashier = isCashier
        }
    }
}
