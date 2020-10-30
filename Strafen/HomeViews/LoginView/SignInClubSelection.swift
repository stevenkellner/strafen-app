//
//  SignInClubSelection.swift
//  Strafen
//
//  Created by Steven on 10/23/20.
//

import SwiftUI
import FirebaseFunctions

/// View to select or create a new club
struct SignInClubSelection: View {
    
    /// Club Identifier Properties
    struct ClubIdentifierProperties {
        
        /// Club identifier
        var clubIdentifier: String = ""
        
        /// Type of club identifier textfield error
        var clubIdentifierErrorMessages: ErrorMessages? = nil
        
        /// Evaluate error
        @discardableResult mutating func evaluateError() -> Bool {
            if clubIdentifier.isEmpty {
                clubIdentifierErrorMessages = .emptyField
            } else {
                clubIdentifierErrorMessages = nil
                return false
            }
            return true
        }
        
        /// Checks if an error occured while signing in
        mutating func evaluteErrorCode(of error: Error) {
            guard let error = error as NSError?, error.domain == FunctionsErrorDomain else {
                return clubIdentifierErrorMessages = .internalErrorSignIn
            }
            let errorCode = FunctionsErrorCode(rawValue: error.code)
            switch errorCode {
            case .notFound:
                clubIdentifierErrorMessages = .clubNotExists
            default:
                clubIdentifierErrorMessages = .internalErrorSignIn
            }
        }
    }
    
    /// Club Identifier Properties
    @State var clubIdentifierProperties = ClubIdentifierProperties()
    
    /// State of the connection
    @State var connectionState: ConnectionState = .passed
    
    /// Indicates if navigation link is active
    @State var isNavigationLinkActive = false
    
    /// Screen size of this view
    @State var screenSize: CGSize?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                // Navigation link to person selection
                EmptyNavigationLink(swipeBack: false, isActive: $isNavigationLinkActive) {
                    SignInPersonSelection()
                }
                
                VStack(spacing: 0) {
                    
                    // Bar to wipe sheet down
                    SheetBar()
                    
                    // Header
                    Header("Registrieren")
                    
                    Spacer()
                    
                    VStack(spacing: 15) {
                        
                        // Club identifier input
                        ClubIdentifierInput(clubIdentifierProperties: $clubIdentifierProperties)
                        
                        // "or" Text
                        Text("oder").configurate(size: 20)
                        
                        // Create new club button
                        CreateClubButton()
                        
                    }.animation(.default)
                    
                    Spacer()
                    
                    // Continue button
                    ConfirmButton()
                        .title("Weiter")
                        .connectionState($connectionState)
                        .onButtonPress(handleContinueButton)
                        .padding(.bottom, 50)
                }
            }.screenSize($screenSize, geometry: geometry)
        }
    }
    
    /// Handles continue button click
    func handleContinueButton() {
        guard connectionState != .loading else { return }
        connectionState = .loading
        
        if clubIdentifierProperties.evaluateError() {
            connectionState = .failed
        } else {
            let callItem = GetClubIdCall(identifier: clubIdentifierProperties.clubIdentifier)
            FunctionCaller.shared.call(callItem, passedHandler: handleCallResult, failedHandler: handleCallError)
        }
    }
    
    /// Handles result of get club id call
    func handleCallResult(clubId: GetClubIdCall.CallResult) {
        let cacheProperty = SignInCache.PropertyUserIdNameClubId(userIdName: SignInCache.shared.cachedStatus?.property as! SignInCache.PropertyUserIdName, clubId: clubId)
        let state: SignInCache.Status = .personSelection(property: cacheProperty)
        SignInCache.shared.setState(to: state)
        isNavigationLinkActive = true
        connectionState = .passed
    }
    
    /// Handles error of get club id call
    func handleCallError(error: Error) {
        clubIdentifierProperties.evaluteErrorCode(of: error)
        connectionState = .failed
    }
    
    /// Club identifier input
    struct ClubIdentifierInput: View {
        
        /// Club Identifier Properties
        @Binding var clubIdentifierProperties: ClubIdentifierProperties
        
        var body: some View {
            VStack(spacing: 10) {
                
                // Textfield and paste button
                VStack(spacing: 5) {
                    
                    // Title
                    Title("Vereinskennung")
                    
                    HStack(spacing: 0) {
                        
                        // Textfield
                        CustomTextField()
                            .title("Vereinskennung")
                            .textBinding($clubIdentifierProperties.clubIdentifier)
                            .errorMessages($clubIdentifierProperties.clubIdentifierErrorMessages)
                            .textFieldSize(width: UIScreen.main.bounds.width * 0.75, height: 50)
                            .showErrorMessage(false)
                            .onCompletion {
                                clubIdentifierProperties.evaluateError()
                            }
                        
                        Spacer()
                        
                        // Paste button
                        Button {
                            if let pasteString = UIPasteboard.general.string {
                                clubIdentifierProperties.clubIdentifier = pasteString
                            }
                        } label: {
                            Image(systemName: "doc.on.clipboard")
                                .font(.system(size: 30, weight: .light))
                                .foregroundColor(.textColor)
                        }
                        
                        Spacer()
                    }.frame(width: UIScreen.main.bounds.width * 0.95)
                    
                    // Error messages
                    ErrorMessageView(errorMessages: $clubIdentifierProperties.clubIdentifierErrorMessages)
                    
                }
                
                // Text
                Text("Du bekommst die Kennung von deinem Trainer oder Kassier.")
                    .configurate(size: 20)
                    .padding(.horizontal, 20)
                    .lineLimit(2)
                
            }
            
        }
    }
    
    /// Create new club button
    struct CreateClubButton: View {
        
        /// Indicates if navigation link is active
        @State var isNavigationLinkActive = false
        
        var body: some View {
            ZStack {
                
                // Navigation link to new club view
                EmptyNavigationLink(isActive: $isNavigationLinkActive) {
                    SignInClubInput()
                }
                
                VStack(spacing: 10) {
                    
                    // Button
                    ZStack {
                        
                        // Outline
                        Outline()
                            .fillColor(Color.custom.orange)
                        
                        // Text
                        Text("Verein Erstellen")
                            .foregroundColor(plain: Color.custom.orange)
                            .font(.text(20))
                            .lineLimit(1)
        
                    }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                        .onTapGesture {
                            isNavigationLinkActive = true
                        }
                        
                    // Text
                    Text("Wenn du der Kassier bist:\nErstelle eine neuen Verein.")
                        .configurate(size: 20)
                        .padding(.horizontal, 20)
                        .lineLimit(2)
                    
                }
            }
        }
    }
}
