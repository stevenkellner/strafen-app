//
//  Settings+LatePaymentInterest.swift
//  Strafen
//
//  Created by Steven on 9/4/20.
//

import Foundation

extension Settings {
    
    /// Late payment interest
    struct LatePaymentInterest: Codable, Equatable {
        
        /// Compontents of date (day / month / year)
        enum DateComponents: String, CaseIterable, Identifiable, Codable {
            
            /// Day
            case day
            
            /// Month
            case month
            
            /// Year
            case year
            
            /// Id
            public var id: String {
                rawValue
            }
            
            /// Singular
            var singular: String {
                switch self {
                case .day:
                    return "Tag"
                case .month:
                    return "Monat"
                case .year:
                    return "Jahr"
                }
            }
            
            /// Plural
            var plural: String {
                switch self {
                case .day:
                    return "Tage"
                case .month:
                    return "Monate"
                case .year:
                    return "Jahre"
                }
            }
        }
        
        /// Contains value and unit of a time period
        struct TimePeriod: Codable, Equatable {
            
            /// Value
            var value: Int
            
            /// Unit
            var unit: DateComponents
        }
        
        /// Interest free period
        var interestFreePeriod: TimePeriod
        
        /// Interest rate
        var interestRate: Double
        
        /// Interest period
        var interestPeriod: TimePeriod
        
        /// Compound interest
        var compoundInterest: Bool
        
        /// Description
        var description: String {
            "\(interestRate)% / \(interestPeriod.value) \(interestPeriod.value == 1 ? interestPeriod.unit.singular : interestPeriod.unit.plural)"
        }
        
        /// POST parameters
        var parameters: [String : Any] {
            [
                "interestFreeValue": interestFreePeriod.value,
                "interestFreeUnit": interestFreePeriod.unit.rawValue,
                "interestRate": interestRate,
                "interestValue": interestPeriod.value,
                "interestUnit": interestPeriod.unit.rawValue,
                "compoundInterest": compoundInterest
            ]
        }
    }
}
