//
//  ForceSignedOutView.swift
//  Strafen
//
//  Created by Steven on 24.06.21.
//

import SwiftUI
import FirebaseAuth

struct ForceSignedOutView: View {
    var body: some View {
        VStack {

            // Header
            Header(String(localized: "force-sign-out-header", comment: "Header of force sign out view."))
                .padding(.top, 35)

            Spacer()

            Text("force-sign-out-first-message", comment: "First message of force sign out view.")
                .foregroundColor(.textColor)
                .font(.system(size: 25, weight: .thin))
                .padding(.horizontal, 15)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Spacer()

            Text("force-sign-out-seconde-message", comment: "Second message of force sign out view.")
                .foregroundColor(.textColor)
                .font(.system(size: 25, weight: .thin))
                .padding(.horizontal, 15)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Spacer()

            // Back to log in button
            SingleButton(String(localized: "force-sign-out-button-text", comment: "Text of button in force sign out view."))
                .fontSize(27)
                .rightSymbol(name: "arrowshape.turn.up.backward")
                .rightColor(.customGreen)
                .onClick {
                    FirebaseAppSetup.shared.forceSignedOut = false
                    try? Auth.auth().signOut()
                    Settings.shared.person = nil
                }
                .padding(.bottom, 50)
        }
    }
}
