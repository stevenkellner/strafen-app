//
//  LatePaymentInterest.swift
//  Strafen
//
//  Created by Steven on 17.05.21.
//

import Foundation

/// Late payement interest
struct LatePaymentInterest: Codable, Equatable {

    /// Components of date (day / month / year)
    enum DateComponent: String, Codable, Equatable, CaseIterable, Identifiable {

        /// Day component
        case day

        /// Month component
        case month

        /// Year component
        case year

        var id: String { rawValue }

        /// Same componets of Calender.Components
        var dateComponentFlag: Calendar.Component {
            switch self {
            case .day: return .day
            case .month: return .month
            case .year: return .year
            }
        }

        /// Keypath from DateComponents to same component
        var dateComponentKeyPath: KeyPath<DateComponents, Int?> {
            switch self {
            case .day: return \.day
            case .month: return \.month
            case .year: return \.year
            }
        }

        /// String value
        var string: String {
            switch self {
            case .day: return String(localized: "plain-day-text", comment: "Plain text of day.")
            case .month: return String(localized: "plain-month-text", comment: "Plain text of month.")
            case .year: return String(localized: "plain-year-text", comment: "Plain text of year.")
            }
        }

        /// Number of date component between given dates
        func numberBetweenDates(start startDate: Date, end endDate: Date) -> Int {
            let calender = Calendar.current
            let startDate = calender.startOfDay(for: startDate)
            let endDate = calender.startOfDay(for: endDate)
            let components = calender.dateComponents([dateComponentFlag], from: startDate, to: endDate)
            return components[keyPath: dateComponentKeyPath] ?? 0
        }
    }

    /// Contains value and unit of a time period
    struct TimePeriod: Codable, Equatable {

        /// Value of the time period
        var value: Int

        /// Unit of the time period
        var unit: DateComponent
    }

    /// Interest free timeinterval
    var interestFreePeriod: TimePeriod

    /// Rate of the interest
    var interestRate: Double

    /// interest timeinterval
    var interestPeriod: TimePeriod

    /// Indicates whether compound interest is active
    var compoundInterest: Bool

    /// Description
    var description: String {
        "\(interestRate.formatted())% / ^[\(interestPeriod.value) \(interestPeriod.unit.string)](inflect: true)"
    }
}

extension LatePaymentInterest.DateComponent: FirebaseParameterable {
    var primordialParameter: FirebasePrimordialParameterable { rawValue }
}

extension LatePaymentInterest {

    /// Set of parameters for firebase function call
    var parmeterSet: FirebaseCallParameterSet {
        FirebaseCallParameterSet { parameters in
            parameters["interestFreeValue"] = interestFreePeriod.value
            parameters["interestFreeUnit"] = interestFreePeriod.unit
            parameters["interestRate"] = interestRate
            parameters["interestValue"] = interestPeriod.value
            parameters["interestUnit"] = interestPeriod.unit
            parameters["compoundInterest"] = compoundInterest
        }
    }
}

/// Used to parse string to late payment interest rate
struct LatePaymentInterestRateParser {

    /// Parses string to late payment interest rate
    /// - Parameter string: string to parse
    /// - Returns: parsed late payment interest rate
    static func fromString(_ string: String) -> Double {
        var commaPassed = false
        var newString = ""

        // Filter all invalid characters out
        let validCharacters = (0..<10).map { Character(String($0)) }.appending(",")
        for char in string where validCharacters.contains(char) {
            if char == "," {
                if !commaPassed {
                    commaPassed = true
                    newString.append(".")
                }
                continue
            }
            newString.append(char)
        }

        return min(Double(newString) ?? .zero, 100)
    }

    /// Parses late payment interest rate to string
    /// - Parameter interest: interest rate to parse
    /// - Returns: parsed string
    static func toString(_ interest: Double) -> String {
        if Double(Int(interest)) == interest {
            return String(Int(interest))
        }
        return String(interest).replacingOccurrences(of: ".", with: ",")
    }
}

/// Used to parse string to late payment interest period value
struct LatePaymentInterestPeriodValueParser {

    /// Parses string to late payment interest period value
    /// - Parameter string: string to parse
    /// - Returns: parsed late payment interest period value
    static func fromString(_ string: String) -> Int {
        var newString = ""

        // Filter all invalid characters out
        let validCharacters = (0..<10).map { Character(String($0)) }.appending(",")
        for char in string where validCharacters.contains(char) {
            if char == "," { break }
            newString.append(char)
        }
        return Int(newString) ?? .zero
    }
}
