//
//  LatePaymentInterest.swift
//  Strafen
//
//  Created by Steven on 17.05.21.
//

import Foundation

/// Late payement interest
struct LatePaymentInterest {

    /// Components of date (day / month / year)
    enum DateComponent: String {

        /// Day component
        case day

        /// Month component
        case month

        /// Year component
        case year
    }

    /// Contains value and unit of a time period
    struct TimePeriod {

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
