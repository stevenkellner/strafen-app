//
//  LoginEntryView.swift
//  Strafen
//
//  Created by Steven on 10.05.21.
//

import SwiftUI

/// Used to navigate through all login and signin views
struct LoginEntryView: View {
    var body: some View {
        // SignInView()
        SignInPersonSelectionView(signInProperty: SignInProperty.UserIdNameClubId(SignInProperty.UserIdName(userId: "userId", name: PersonName(firstName: "First", lastName: "Last")), clubId: Club.ID(rawValue: UUID(uuidString: "041D157B-2312-484F-BB49-C1CC0DE7992F")!)))
    }
}
