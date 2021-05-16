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
        SignInClubInputView(signInProperty: SignInProperty.UserIdName(userId: "userId", name: PersonName(firstName: "First", lastName: "LastName")))
    }
}
