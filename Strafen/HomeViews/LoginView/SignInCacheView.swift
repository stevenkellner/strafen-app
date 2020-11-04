//
//  SignInCacheView.swift
//  Strafen
//
//  Created by Steven on 10/17/20.
//

import SwiftUI
import FirebaseAuth

/// View shown when sign in process is cached and select possiblity to continue or to start again
struct SignInCacheView: View {
    
    /// Sign in cache state
    @State var state: SignInCache.Status?
    
    /// Idicates if navigation link is active
    @State var isNavigationLinkActive = false
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                
                // Navigation Links
                ZStack {
                    switch state {
                    case .nameInput(property: _):
                        EmptyNavigationLink(isActive: $isNavigationLinkActive, destination: SignInNameInput())
                    case .clubSelection(property: _):
                        EmptyNavigationLink(isActive: $isNavigationLinkActive, destination: SignInClubSelection())
                    case .personSelection(property: _):
                        EmptyNavigationLink(isActive: $isNavigationLinkActive, destination: SignInPersonSelection())
                    case .none:
                        Text("Invalid State")
                            .onAppear { presentationMode.wrappedValue.dismiss() }
                    }
                }.frame(size: .zero)
                
                // Content
                VStack(spacing: 0) {
                    
                    // Bar to wipe sheet down
                    SheetBar()
                    
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
    
    /// Handles continue button click
    func handleContinueClick() {
        isNavigationLinkActive = true
    }
    
    /// Cancel and continue button
    struct CancelContinueButton: View {
        
        /// Handles continue button click
        let handleContinueClick: () -> Void
        
        /// Color scheme to get appearance of this device
        @Environment(\.colorScheme) var colorScheme
        
        /// Cancel connection state
        @State var cancelConnectionState: ConnectionState = .passed
        
        /// Presentation mode
        @Environment(\.presentationMode) var presentationMode
        
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
                                .foregroundColor(plain: Color.custom.red)
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
            guard cancelConnectionState != .loading else { return }
            cancelConnectionState = .loading
            
            if let user = Auth.auth().currentUser {
                let callItem = UserIdAlreadyExistsCall(userId: user.uid)
                FunctionCaller.shared.call(callItem) { (personExists: UserIdAlreadyExistsCall.CallResult) in
                    if personExists {
                        dismissSheet(with: .passed)
                    } else {
                        user.delete { error in
                            dismissSheet(with: error == nil ? .passed : .failed)
                        }
                    }
                } failedHandler: { _ in
                    dismissSheet(with: .failed)
                }
            } else {
                dismissSheet(with: .passed)
            }
        }
        
        func dismissSheet(with connectionState: ConnectionState) {
            SignInCache.shared.setState(to: nil)
            cancelConnectionState = connectionState
            presentationMode.wrappedValue.dismiss()
        }
    }
}
