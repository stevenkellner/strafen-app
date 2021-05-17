//
//  FFChangeLatePaymentInterestCall.swift
//  Strafen
//
//  Created by Steven on 17.05.21.
//

import Foundation

/// Changes late payment interest
struct FFChangeLatePaymentInterestCall: FFCallable {

    /// Type of the change
    enum ChangeType {

        /// Update / set a late payment interest
        case update(interest: LatePaymentInterest)

        /// Remove a late payment interest
        case remove

        /// Late payment interest
        var latePaymentInterest: LatePaymentInterest? {
            switch self {
            case .update(interest: let interest):
                return interest
            case .remove:
                return nil
            }
        }
    }

    /// Id of the club
    let clubId: Club.ID

    /// Type of the change
    let changeType: ChangeType

    /// Used to remove late pament interest
    /// - Parameter clubId: Club id
    init(clubId: Club.ID) {
        self.clubId = clubId
        self.changeType = .remove
    }

    /// Used to update late payment interest
    /// - Parameters:
    ///   - clubId: Club id
    ///   - interest: late payment interest
    init(clubId: Club.ID, interest: LatePaymentInterest) {
        self.clubId = clubId
        self.changeType = .update(interest: interest)
    }

    let functionName = "changeLatePaymentInterest"

    var parameters: FirebaseCallParameterSet {
        FirebaseCallParameterSet(changeType.latePaymentInterest?.parmeterSet) { parameters in
            parameters["clubId"] = clubId
            parameters["changeType"] = changeType
        }
    }
}

extension FFChangeLatePaymentInterestCall.ChangeType: FirebaseParameterable {
    var primordialParameter: FirebasePrimordialParameterable {
        switch self {
        case .update(interest: _):
            return "update"
        case .remove:
            return "remove"
        }
    }
}
