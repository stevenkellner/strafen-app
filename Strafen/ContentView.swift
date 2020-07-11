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
        LoginView()
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
