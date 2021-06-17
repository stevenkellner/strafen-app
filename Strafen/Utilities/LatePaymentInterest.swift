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
    enum DateComponent: String, Codable, Equatable {

        /// Day component
        case day

        /// Month component
        case month

        /// Year component
        case year

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
