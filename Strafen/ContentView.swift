//
//  ContentView.swift
//  Strafen
//
//  Created by Steven on 04.05.21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
            .onAppear {
                var list = [FirebasePerson]()
                FirebaseObserver.shared.observeList(FirebasePerson.self) { changeList in
                    changeList(&list)
                }
                
//                FirebaseFetcher.shared.fetchList(FirebasePerson.self).then { value in
//                    print(value)
//                }.catch { error in
//                    print(error)
//                }
            }
    }
}
