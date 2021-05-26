//
//  Fine.swift
//  Strafen
//
//  Created by Steven on 12.07.20.
//

import SwiftUI

/// Contains all properties of a fine
struct Fine {
    
    /// Type of Id
    typealias ID = Tagged<(ReasonTemplate, id: Void), UUID>
    
    /// Id
    let id: ID
    
    /// Id of the associated person
    let assoiatedPersonId: Person.ID
    
    /// Date this fine was issued
    let date: Date
    
    /// Is fine payed
    var payed: Payed
    
    /// Number of fines
    let number: Int
    
    /// Fine reason for reason / amount / importance or templateId
    let fineReason: FineReason
    
    internal init(id: Fine.ID, assoiatedPersonId: Person.ID, date: Date, payed: Payed, number: Int, fineReason: FineReason) {
        self.id = id
        self.assoiatedPersonId = assoiatedPersonId
        self.date = date
        self.payed = payed
        self.number = number
        self.fineReason = fineReason
    }
    
    /// Indicates if fine is payed
    var isPayed: Bool {
        payed != .unpayed && payed != .settled
    }
    
    var isSettled: Bool {
        payed == .settled
    }
    
    /// Complete amount of this fine
    func completeAmount(with reasonList: [ReasonTemplate]?) -> Amount {
        fineReason.amount(with: reasonList) * number + (latePaymentInterestAmount(with: reasonList) ?? .zero)
    }
    
    /// Color of amount text
    func amountTextColor(with reasonList: [ReasonTemplate]?) -> Color {
        isPayed ? Color.custom.lightGreen : fineReason.importance(with: reasonList).color
    }
}

// Extension of Fine to confirm to ListType
extension Fine: ListType {
    
    /// Url for database refernce
    static var url: URL {
        guard let clubId = Settings.shared.person?.clubProperties.id else {
            fatalError("No person is logged in.")
        }
        return URL.fineList(with: clubId)
    }
    
    /// Init with id and codable self
    init(with id: ID, codableSelf: CodableSelf) {
        self.id = id
        self.assoiatedPersonId = codableSelf.personId
        self.date = codableSelf.date
        self.payed = codableSelf.payed
        self.number = codableSelf.number
        self.fineReason = codableSelf.reason.fineReason
    }
    
    #if TARGET_MAIN_APP
    /// Get fine list of ListData
    static func getDataList() -> [Fine]? {
        ListData.fine.list
    }
    
    /// Change fine list of ListData
    static func changeHandler(_ newList: [Fine]?) {
        ListData.fine.list = newList
    }
    
    
    /// Parameters for database change call
    var callParameters: Parameters {
        Parameters(fineReason.callParameters) { parameters in
            parameters["itemId"] = id
            parameters["personId"] = assoiatedPersonId
            parameters["payedState"] = payed.state
            parameters["payedPayDate"] = payed.payDate
            parameters["payedInApp"] = payed.payedInApp
            parameters["number"] = number
            parameters["date"] = date
            parameters["listType"] = "fine"
        }
    }
    #endif
}

// Extension of Fine for CodableSelf
extension Fine {
    
    /// Fine to fetch from database
    struct CodableSelf: Decodable {
        
        /// Id of the associated person
        let personId: Person.ID
        
        /// Date this fine was issued
        let date: Date
        
        /// Is fine payed
        var payed: Payed
        
        /// Number of fines
        let number: Int
        
        /// Fine reason for reason / amount / importance or templateId
        let reason: CodableFineReason
    }
}

// Extension of Fine to calculate the late payment interest
extension Fine {
    
    /// Late payment interest
    func latePaymentInterestAmount(with latePaymentInterest: Settings.LatePaymentInterest, reasonList: [ReasonTemplate]?) -> Amount {
        
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
        guard startDate <= endDate else {
            return .zero
        }
        
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
    
    /// Late payment interest
    func latePaymentInterestAmount(with reasonList: [ReasonTemplate]?) -> Amount? {
        guard let interest = Settings.shared.latePaymentInterest else { return nil }
        return latePaymentInterestAmount(with: interest, reasonList: reasonList)
    }
}
