//
//  FFNewTestClubCall.swift
//  StrafenTests
//
//  Created by Steven on 05.05.21.
//

import Foundation
@testable import Strafen

/// Creates a new test club in database of given type
struct FFNewTestClubCall: FFCallable {

    /// Type of new test club
    enum TestClubType: String, FirebaseParameterable {

        /// For fetcher test
        case fetcherTestClub

        var primordialParameter: FirebasePrimordialParameterable { rawValue }
    }

    /// Id of new test club
    let clubId: UUID

    /// Type of new test club
    let testClubType: TestClubType

    let functionName = "newTestClub"

    var parameters: FirebaseCallParameterSet {
        FirebaseCallParameterSet { parameters in
            parameters["clubId"] = clubId
            parameters["testClubType"] = testClubType
        }
    }
}
