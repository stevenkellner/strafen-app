//
//  ContentView.swift
//  Strafen
//
//  Created by Steven on 26.06.20.
//

import SwiftUI

struct ContentView: View {
    
    @State var show = false
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    var body: some View {
        ZStack {
            if let loggedInPerson = settings.person {
                Text(loggedInPerson.name.formatted)
            } else {
                LoginView()
            }
        }.edgesIgnoringSafeArea(.all)
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
