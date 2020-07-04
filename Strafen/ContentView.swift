//
//  ContentView.swift
//  Strafen
//
//  Created by Steven on 26.06.20.
//

import SwiftUI

struct ContentView: View {
    
    @State var show = false
    
    var body: some View {
        // LoginView()
        Text("Show Sheet")
            .font(.text(35))
            .foregroundColor(.textColor)
            .onTapGesture {
                show = true
            }
            .sheet(isPresented: $show) {
                SignInSelectPersonView(personName: PersonName(firstName: "Steven", lastName: "Kellner"), personLogin: PersonLoginEmail(email: "steven.kellner@web.de", password: "Password00"), clubId: UUID(uuidString: "38646570-1920-4E55-A870-C4970B700183"), clubName: "SG Kleinsendelbach / Hetzles", showSignInSheet: $show)
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                Settings.shared.applySettings()
            }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
