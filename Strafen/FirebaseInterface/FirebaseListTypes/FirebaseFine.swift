//
//  FirebaseFine.swift
//  Strafen
//
//  Created by Steven on 05.05.21.
//

import SwiftUI

// swiftlint:disable identifier_name
// swiftlint:disable type_name

/// Contains all properties of a fine in firebase database
struct FirebaseFine {

    /// Tagged UUID type of the id
    typealias ID = Tagged<FirebaseFine, UUID>

    /// Id
    let id: ID

    /// Id of the associated person
    let assoiatedPersonId: FirebasePerson.ID

    /// Date this fine was issued
    let date: Date

    /// Is fine payed
    var payed: Payed

    /// Number of fines
    let number: Int

    /// Codable fine reason for reason / amount / importance or templateId
    private var codableFineReason: CodableFineReason

    /// Fine reason for reason / amount / importance or templateId
    var fineReason: FineReason {
        get { codableFineReason.fineReason }
        set {
            if let fineReason = newValue as? FineReasonTemplate {
                codableFineReason = CodableFineReason(reason: nil, amount: nil, importance: nil, templateId: fineReason.templateId)
            } else if let fineReason = newValue as? FineReasonCustom {
                codableFineReason = CodableFineReason(reason: fineReason.reason, amount: fineReason.amount, importance: fineReason.importance, templateId: nil)
            } else {
                fatalError("No valid fine reason")
            }
        }
    }

    init(id: ID, assoiatedPersonId: FirebasePerson.ID, date: Date, payed: Payed, number: Int, fineReason: FineReason) {
        self.id = id
        self.assoiatedPersonId = assoiatedPersonId
        self.date = date
        self.payed = payed
        self.number = number
        if let fineReason = fineReason as? FineReasonTemplate {
            codableFineReason = CodableFineReason(reason: nil, amount: nil, importance: nil, templateId: fineReason.templateId)
        } else if let fineReason = fineReason as? FineReasonCustom {
            codableFineReason = CodableFineReason(reason: fineReason.reason, amount: fineReason.amount, importance: fineReason.importance, templateId: nil)
        } else {
            fatalError("No valid fine reason")
        }
    }
}

extension FirebaseFine: FirebaseListType {

    typealias Statistic = StatisticsFine

    static let urlFromClub = URL(string: "fines")!

    static let listType: String = "fine"

    /// Coding Keys for Decodable
    enum CodingKeys: String, CodingKey {
        case id
        case assoiatedPersonId = "personId"
        case date
        case payed
        case number
        case codableFineReason = "reason"
     }

    var parameterSet: FirebaseCallParameterSet {
        FirebaseCallParameterSet(fineReason.parameterSet) { parameter in
            parameter["personId"] = assoiatedPersonId
            parameter["payedState"] = payed.state
            parameter["payedPayDate"] = payed.payDate
            parameter["payedInApp"] = payed.payedInApp
            parameter["date"] = date
            parameter["number"] = number
        }
    }
}

extension FirebaseFine: Equatable {}

extension FirebaseFine {

    /// Reason of this fine
    /// - Parameter reasonList: list of all reason templates
    /// - Returns: reason of this fine
    func reason(with reasonList: [FirebaseReasonTemplate]) -> String {
        fineReason.reason(with: reasonList)
    }

    /// Amount of this fine
    /// - Parameter reasonList: list of all reason templates
    /// - Returns: amount of this fine
    func amount(with reasonList: [FirebaseReasonTemplate]) -> Amount {
        fineReason.amount(with: reasonList)
    }

    /// Importance of this fine
    /// - Parameter reasonList: list of all reason templates
    /// - Returns: importance of this fine
    func importance(with reasonList: [FirebaseReasonTemplate]) -> Importance {
        fineReason.importance(with: reasonList)
    }

    /// `true` if payed state is `.payed(data: _, inApp: _)`, `false` otherwise
    var isPayed: Bool {
        if case .payed(date: _, inApp: _) = payed { return true }
        return false
    }

    /// `true` if payed state is `.settled`, `false` otherwise
    var isSettled: Bool {
        payed == .settled
    }

    func amountTextColor(with reasonList: [FirebaseReasonTemplate]) -> Color {
        isPayed ? .customGreen : fineReason.importance(with: reasonList).color
    }

    /// Complete amout of the fine: number times the amount plus late payment amount of the fine
    /// - Parameters:
    ///   - reasonList: list of all reason templates
    /// - Returns: complete amount of the fine
    func completeAmount(with reasonList: [FirebaseReasonTemplate]) -> Amount {
        amount(with: reasonList) * number + latePaymentInterestAmount(with: reasonList)
    }

    /// Amount of late payment interest of this fine, zero if club has no late payment interest
    /// - Parameter reasonList: list of all reason templates
    /// - Returns: amount of late payment interest
    func latePaymentInterestAmount(with reasonList: [FirebaseReasonTemplate]) -> Amount {
        guard let interest = Settings.shared.latePaymentInterest else { return .zero }
        return latePaymentInterestAmount(with: interest, reasonList: reasonList)
    }

    /// Amount of late payment interest of this fine
    /// - Parameters:
    ///   - latePaymentInterest: configuration of late payment interest
    ///   - reasonList: list of all reason templates
    /// - Returns: amount of late payment interest
    func latePaymentInterestAmount(with latePaymentInterest: LatePaymentInterest, reasonList: [FirebaseReasonTemplate]) -> Amount {

        // Get start date
        let calender = Calendar.current
        var startDate = calender.startOfDay(for: date)
        startDate = calender.date(byAdding: latePaymentInterest.interestFreePeriod.unit.dateComponentFlag, value: latePaymentInterest.interestFreePeriod.value, to: startDate) ?? startDate

        // Get end date
        var endDate = Date()
        if case .payed(date: let paymentDate, inApp: _) = payed {
            endDate = paymentDate
        }

        // Return .zero if start date is greater than the end date
        guard startDate <= endDate else { return .zero }

        // Get number of components between start and end date
        let numberBetweenDates = latePaymentInterest.interestPeriod.unit.numberBetweenDates(start: startDate, end: endDate) / latePaymentInterest.interestPeriod.value

        // Original amount
        let originalAmount = fineReason.amount(with: reasonList) * number

        // Return late payment interest
        if latePaymentInterest.compoundInterest {
            return originalAmount * (pow(1 + latePaymentInterest.interestRate / 100, Double(numberBetweenDates)) - 1)
        } else {
            return originalAmount * (latePaymentInterest.interestRate / 100 * Double(numberBetweenDates))
        }
    }
}

extension FirebaseFine {

    /// Generates random fine
    /// - Parameter generator: random number generator
    /// - Returns: random fine of nil if a list is empty
    static func random<T>(using generator: inout T, personList: [FirebasePerson], reasonList: [FirebaseReasonTemplate]) -> FirebaseFine? where T: RandomNumberGenerator {
        guard !personList.isEmpty, !reasonList.isEmpty else { return nil }
        let id = ID(rawValue: UUID())
        let assoiatedPersonId = personList.randomElement(using: &generator)!.id
        let date = Date(timeIntervalSinceReferenceDate: Double.random(in: 100_000...10_000_000, using: &generator))
        let payed = Payed.random(using: &generator)
        let number = (1...10).randomElement(using: &generator)!
        let fineReason: FineReason
        if Bool.random(using: &generator) {
            let templateId = reasonList.randomElement(using: &generator)!.id
            fineReason = FineReasonTemplate(templateId: templateId)
        } else {
            let reasonTemplate = FirebaseReasonTemplate.random(using: &generator)
            fineReason = FineReasonCustom(reason: reasonTemplate.reason, amount: reasonTemplate.amount, importance: reasonTemplate.importance)
        }
        return FirebaseFine(id: id, assoiatedPersonId: assoiatedPersonId, date: date, payed: payed, number: number, fineReason: fineReason)
    }

    /// Returns a random instace of the type
    /// - Returns: random instance of the type
    static func random(personList: [FirebasePerson], reasonList: [FirebaseReasonTemplate]) -> FirebaseFine? {
        var generator = SystemRandomNumberGenerator()
        return random(using: &generator, personList: personList, reasonList: reasonList)
    }
}

extension Array where Element == FirebaseFine {

    /// Generates a random list of given length
    /// - Parameter length: length of the list
    /// - Parameter generator: generator: random number generator
    /// - Returns: random list
    static func randomList<T>(of length: UInt, using generator: inout T, personList: [FirebasePerson], reasonList: [FirebaseReasonTemplate]) -> [FirebaseFine]? where T: RandomNumberGenerator {
        guard !personList.isEmpty, !reasonList.isEmpty else { return nil }
        return (0..<length).map { _ in FirebaseFine.random(using: &generator, personList: personList, reasonList: reasonList)! }
    }

    /// Generates a random list of given length
    /// - Parameter length: length of the list
    /// - Returns: random list
    static func randomList(of length: UInt, personList: [FirebasePerson], reasonList: [FirebaseReasonTemplate]) -> [FirebaseFine]? {
        var generator = SystemRandomNumberGenerator()
        return randomList(of: length, using: &generator, personList: personList, reasonList: reasonList)
    }

    /// Generates a random list of given length
    /// - Parameter lengthRange: length of the list
    /// - Returns: random list
    static func randomList(in lengthRange: ClosedRange<UInt>, personList: [FirebasePerson], reasonList: [FirebaseReasonTemplate]) -> [FirebaseFine]? {
        var generator = SystemRandomNumberGenerator()
        guard let length = lengthRange.randomElement(using: &generator) else { return [] }
        return randomList(of: length, using: &generator, personList: personList, reasonList: reasonList)
    }
}

/// Contains all properties of a fine in statistics
struct StatisticsFine: Decodable {

    /// Id of the fine
    let id: FirebaseFine.ID // swiftlint:disable:this identifier_name

    /// Associated person of the fine
    let person: FirebasePerson

    /// State of payement
    let payed: Payed

    /// Number of fines
    let number: Int

    /// Date when fine was created
    let date: Date

    /// Reason of fine
    let reason: StatisticsFineReason
}

/// Contains all properties of a fine reason in staistics
struct StatisticsFineReason: Decodable {

    /// Id of template reason, nil if fine reason is custom
    let id: FirebaseReasonTemplate.ID? // swiftlint:disable:this identifier_name

    /// Reason message of the fine
    let reason: String

    /// Amount of the fine
    let amount: Amount

    /// Importance of the fine
    let importance: Importance
}
