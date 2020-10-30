//
//  LoginView.swift
//  Strafen
//
//  Created by Steven on 27.06.20.
//

import SwiftUI

/// First View in login for switching between login view
struct LoginEntryView: View {
    
    /// Indicates if sign in sheet is shown
    @State var showSignInSheet = false
    
    /// Indicates if cached sign in view is shown
    @State var showCachedState = false
    
    var body: some View {
        ZStack {
            
            // Sheet for sign in
            EmptySheetLink(isPresented: $showSignInSheet) {
                SignInView(showSignInSheet: $showSignInSheet)
            } onDismiss: {
                if SignInCache.shared.cachedStatus != nil {
                    showCachedState = true
                }
            }


            // Sheet for sign in with cached properties
            EmptySheetLink(isPresented: $showCachedState) {
                SignInCacheView(state: SignInCache.shared.cachedStatus)
            }
            
            // Login View
            LoginView(showSignInSheet: $showSignInSheet, showCachedState: $showCachedState)
                
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showCachedState = SignInCache.shared.cachedStatus != nil
            }
        }
    }
}

// TODO remove function
func changeAppereanceStyle() {
    let appStyle: [(Settings.Appearance, Settings.Style)] = [
        (.light, .default), (.dark, .default), (.dark, .plain), (.light, .plain)
    ]
    for (index, (appereance, style)) in appStyle.enumerated() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(index * 2)) {
            Settings.shared.appearance = appereance
            Settings.shared.style = style
        }
    }
}
