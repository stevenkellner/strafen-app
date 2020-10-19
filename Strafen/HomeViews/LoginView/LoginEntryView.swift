//
//  LoginView.swift
//  Strafen
//
//  Created by Steven on 27.06.20.
//

import SwiftUI

/// First View in login for switching between login view
struct LoginEntryView: View {
    
    /// Sign in cache
    @ObservedObject var signInCache = SignInCache.shared
    
    /// Indicates if sign in sheet is shown
    @State var showSignInSheet = false
    
    var body: some View {
        ZStack {
            
            // Sheet for sign in
            EmptySheetLink(isPresented: $showSignInSheet) {
                SignInView()
            }
            
            // Sheet for sign in with cached properties
            EmptySheetLink(item: $signInCache.state) { state in
                SignInCacheView(state: state)
            }
            
            // Login View
            LoginView(showSignInSheet: $showSignInSheet)
                
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: SignInCache.shared.checkSignInStatus)
        }
    }
}

// TODO remove function
func changeAppereanceStyle() {
    let appStyle: [(Settings.Appearance, Settings.Style)] = [
        (.light, .plain), (.light, .default), (.dark, .default), (.dark, .plain)
    ]
    for (index, (appereance, style)) in appStyle.enumerated() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(index * 2)) {
            Settings.shared.appearance = appereance
            Settings.shared.style = style
        }
    }
}
