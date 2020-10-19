//
//  SignInCacheView.swift
//  Strafen
//
//  Created by Steven on 10/17/20.
//

import SwiftUI

/// View shown when sign in process is cached and select possiblity to continue or to start again
struct SignInCacheView: View {
    
    /// Sign in cache state
    let state: SignInCache.Status
    
    /// Idicates if navigation link is active
    @State var isNavigationLinkActive = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Bar to wipe sheet down
            SheetBar()
            
            NavigationView {
                ZStack {
                    
                    // Navigation Links
                    ZStack {
                        switch state {
                        case .nameInput(property: let property): // TODO
                            EmptyNavigationLink(isActive: $isNavigationLinkActive, destination: Text(String(reflecting: property)))
                        case .clubSelection(property: let property):
                            EmptyNavigationLink(isActive: $isNavigationLinkActive, destination: Text(String(reflecting: property)))
                        case .personSelection(property: let property):
                            EmptyNavigationLink(isActive: $isNavigationLinkActive, destination: Text(String(reflecting: property)))
                        case .clubPropertiesInput(property: let property):
                            EmptyNavigationLink(isActive: $isNavigationLinkActive, destination: Text(String(reflecting: property)))
                        }
                    }.frame(size: .zero)
                    
                    // Content
                    VStack(spacing: 0) {
                        
                        // Header
                        Header("Registrierung Fortsetzen")
                            .lineLimit(2)
                        
                        Spacer()
                        
                        // Text
                        VStack(spacing: 35) {
                            
                            Text("Du hast schon versucht dich zu registrieren.")
                                .foregroundColor(.textColor)
                                .font(.text(25))
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 15)
                            
                            Text("Möchtest du fortfahren oder erneut beginnen?")
                                .foregroundColor(.textColor)
                                .font(.text(25))
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 15)
                        }
                        
                        Spacer()
                        
                        // Cancel and continue button
                        CancelContinueButton(handleContinueClick: handleContinueClick)
                            .padding(.bottom, 50)
                        
                    }
                    
                }.navigationTitle("Title")
                    .navigationBarHidden(true)
            }
        }
    }
    
    /// Handles continue button click
    func handleContinueClick() {
        isNavigationLinkActive = true
    }
    
    /// Cancel and continue button
    struct CancelContinueButton: View {
        
        /// Handles continue button click
        let handleContinueClick: () -> Void
        
        /// Observed Object that contains all settings of the app of this device
        @ObservedObject var settings = Settings.shared
        
        /// Color scheme to get appearance of this device
        @Environment(\.colorScheme) var colorScheme
        
        /// Cancel connection state
        @State var cancelConnectionState: ConnectionState = .passed
        
        var body: some View {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                
                    // Cancel Button
                    ZStack {
                        
                        // Outline
                        Outline(.left)
                            .fillColor(Color.custom.red)
                        
                        HStack(spacing: 0) {
                            
                            // Text
                            Text("Abbrechen")
                                .foregroundColor(settings: settings, plain: Color.custom.red)
                                .font(.text(20))
                                .lineLimit(1)
                            
                            // Loading circle
                            if cancelConnectionState == .loading {
                                ProgressView()
                                    .padding(.leading, 15)
                            }
                        }
                        
                    }.frame(width: geometry.size.width / 2)
                        .onTapGesture(perform: handleCancelClick)
                    
                    // Confirm Button
                    ZStack {
                        
                        // Outline
                        Outline(.right)
                        
                        // Inside
                        HStack(spacing: 0) {
                            
                            // Text
                            Text("Fortsetzen")
                                .foregroundColor(.textColor)
                                .font(.text(20))
                                .lineLimit(1)
                            
                        }
                        
                    }.frame(width: geometry.size.width / 2)
                        .onTapGesture(perform: handleContinueClick)
                    
                }
            }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
        }
        
        /// Handles cancel button click
        func handleCancelClick() {
//            cancelConnectionState = .loading
//            // TODO Remove person from Firebase Database
//            Functions.functions().call(<#path#>) { error in
//                if error == nil {
//
//                    // Remove person from Firebase Auth
//                    if let user = Auth.auth().currentUser {
//                        user.delete { error in
//                            cancelConnectionState = error == nil ? .passed : .failed
//                        }
//                    } else {
//                        cancelConnectionState = .passed
//                    }
//
//                } else {
//                    cancelConnectionState = .failed
//                }
//            }
//
//            // TODO Clear sign in cache
//            SignInCache.shared.state = nil
        }
    }
}
