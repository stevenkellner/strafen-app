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
        
        /// Club identifier error type
        enum ClubIdentifierErrorType: ErrorMessageType {
            
            /// Textfield is empty
            case emptyField
            
            /// Club doesn't exist
            case clubNotExists
            
            /// Internal error
            case internalError
            
            /// Message of the error
            var message: String {
                switch self {
                case .emptyField:
                    return "Dieses Feld darf nicht leer sein!"
                case .clubNotExists:
                    return "Es gibt keinen Verein mit dieser Kennung!"
                case .internalError:
                    return "Es gab ein Problem beim Registrieren."
                }
            }
        }
        
        /// Club identifier
        var clubIdentifier: String = ""
        
        /// Type of club identifier textfield error
        var clubIdentifierErrorType: ClubIdentifierErrorType? = nil
        
        /// Evaluate error
        @discardableResult mutating func evaluateError() -> Bool {
            if clubIdentifier.isEmpty {
                clubIdentifierErrorType = .emptyField
            } else {
                clubIdentifierErrorType = nil
                return false
            }
            return true
        }
        
        /// Checks if an error occured while signing in
        mutating func evaluteErrorCode(of error: Error) {
            let errorCode = FunctionsErrorCode(rawValue: error._code)
            switch errorCode {
            case .notFound:
                clubIdentifierErrorType = .clubNotExists
            default:
                clubIdentifierErrorType = .internalError
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
                    ConfirmButton("Weiter", connectionState: $connectionState, buttonHandler: handleContinueButton)
                        .padding(.bottom, 50)
                }
            }.screenSize($screenSize, geometry: geometry)
        }
    }
    
    /// Handles continue button click
    func handleContinueButton() {
        
        let cacheProperty = SignInCache.PropertyUserIdNameClubId(userIdName: SignInCache.shared.cachedStatus?.property as! SignInCache.PropertyUserIdName, clubId: UUID(uuidString: "C0AFDCF2-53D1-427F-9958-27CF3DCBA344")!)
        let state: SignInCache.Status = .personSelection(property: cacheProperty)
        SignInCache.shared.setState(to: state)
        return isNavigationLinkActive = true
        
        guard connectionState != .loading else { return }
        connectionState = .loading
        
        if clubIdentifierProperties.evaluateError() {
            connectionState = .failed
        } else {
            Functions.functions(region: "europe-west1").httpsCallable("getClubId").call(["identifier": clubIdentifierProperties.clubIdentifier]) { result, error in
                if let error = error {
                    clubIdentifierProperties.evaluteErrorCode(of: error)
                    connectionState = .failed
                } else if let clubIdString = result?.data as? String, let clubId = UUID(uuidString: clubIdString) {
                    let cacheProperty = SignInCache.PropertyUserIdNameClubId(userIdName: SignInCache.shared.cachedStatus?.property as! SignInCache.PropertyUserIdName, clubId: clubId)
                    let state: SignInCache.Status = .personSelection(property: cacheProperty)
                    SignInCache.shared.setState(to: state)
                    isNavigationLinkActive = true
                    connectionState = .passed
                } else {
                    clubIdentifierProperties.clubIdentifierErrorType = .internalError
                    connectionState = .failed
                }
            }
        }
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
                        CustomTextField("Vereinskennung", text: $clubIdentifierProperties.clubIdentifier, errorType: $clubIdentifierProperties.clubIdentifierErrorType) {
                            clubIdentifierProperties.evaluateError()
                        }.textFieldSize(width: UIScreen.main.bounds.width * 0.75, height: 50)
                            .showErrorMessage(false)
                        
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
                    ErrorMessages(errorType: $clubIdentifierProperties.clubIdentifierErrorType)
                    
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
        
        /// Observed Object that contains all settings of the app of this device
        @ObservedObject var settings = Settings.shared
        
        var body: some View {
            ZStack {
                
                // Navigation link to new club view
                EmptyNavigationLink(isActive: $isNavigationLinkActive) {
                    Text("Club input") // TODO
                }
                
                VStack(spacing: 10) {
                    
                    // Button
                    ZStack {
                        
                        // Outline
                        Outline()
                            .fillColor(Color.custom.orange)
                        
                        // Text
                        Text("Verein Erstellen")
                            .foregroundColor(settings: settings, plain: Color.custom.orange)
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
