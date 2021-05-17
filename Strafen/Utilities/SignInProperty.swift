//
//  SignInProperty.swift
//  Strafen
//
//  Created by Steven on 13.05.21.
//

import Foundation

/// Contains properties for sign in
struct SignInProperty {

    /// Sign in property with userId and name
    struct UserIdName {

        /// User id of person signed in
        let userId: String

        /// Name of  person signed in
        let name: PersonName
    }

    /// Sign in property with userId and name
    struct UserIdNameClubId {

        /// User id of person signed in
        let userId: String

        /// Name of  person signed in
        let name: PersonName

        /// Id of the club
        let clubId: UUID
    }
}

extension SignInProperty.UserIdNameClubId {

    /// Init with UserIdName and club id
    /// - Parameters:
    ///   - oldSignInProperty: Sign in property with userId and name
    ///   - clubId: Id of the new club
    init(_ oldSignInProperty: SignInProperty.UserIdName, clubId: UUID) {
        self.userId = oldSignInProperty.userId
        self.name = oldSignInProperty.name
        self.clubId = clubId
    }
}
