//
//  ListData.swift
//  Strafen
//
//  Created by Steven on 11/7/20.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import CodableFirebase
import WidgetKit

/// Data of all list types
class ListData: ObservableObject {
    
    /// List data of person list
    static let person = DataTypeList<Person>()
    
    /// List data of reason list
    static let reason = DataTypeList<ReasonTemplate>()
    
    /// List data of fine list
    static let fine = DataTypeList<Fine>()
    
    /// Shared instace for singleton
    static let shared = ListData()

    /// Private init for singleton
    private init() {}
    
    #if TARGET_MAIN_APP
    /// Connection state for list fetching
    @Published var connectionState: ConnectionState = .loading
    
    /// Person is force signed out
    @Published var forceSignedOut = false
    
    /// Email not verificated in last month
    @Published var emailNotVerificated = false
    
    /// Setups list data
    func setup() {
        
        // Set connection state
        connectionState = .loading
        HomeTabs.shared.active = .profileDetail
        
        // Fetch lists from database
        fetchLists { [weak self] in
            
            // Check person properties
            self?.checkPersonProperties()
            
            // Observe lists on database
            self?.observeLists()
        }
    }
    #endif
    
    /// Fetches lists from database
    func fetchLists(onSuccess successHandler: @escaping () -> Void) {
        Logging.shared.log(with: .info, "Start fetching lists from database")
        
        // Reset lists
        Self.person.list = nil
        Self.fine.list = nil
        Self.reason.list = nil
        
        // Dispatch group
        let dispatchGroup = DispatchGroup()
        
        // Fetch person list
        dispatchGroup.enter()
        Self.person.fetch {
            dispatchGroup.leave()
        } failedHandler: { [weak self] in
            Logging.shared.log(with: .error, "Unable to fetch person list.")
            #if TARGET_MAIN_APP
            self?.connectionState = .failed
            #endif
        }
        
        // Fetch fine list
        dispatchGroup.enter()
        Self.fine.fetch {
            dispatchGroup.leave()
        } failedHandler: { [weak self] in
            Logging.shared.log(with: .error, "Unable to fetch fine list.")
            #if TARGET_MAIN_APP
            self?.connectionState = .failed
            #endif
        }
        
        // Fetch reason list
        dispatchGroup.enter()
        Self.reason.fetch {
            dispatchGroup.leave()
        } failedHandler: { [weak self] in
            Logging.shared.log(with: .error, "Unable to fetch reason list.")
            #if TARGET_MAIN_APP
            self?.connectionState = .failed
            #endif
        }
        
        // Notify dispatch group
        dispatchGroup.notify(queue: .main) {
            successHandler()
            #if TARGET_MAIN_APP
            WidgetCenter.shared.reloadTimelines(ofKind: "StrafenWidget")
            #endif
        }
    }
    
    #if TARGET_MAIN_APP
    /// Observes lists on database
    private func observeLists() {
        
        // Observe person list
        Self.person.observe()
        
        // Observe fine list
        Self.fine.observe()
        
        // Observe reason list
        Self.reason.observe()
    }
    
    /// Check if properties of logged in person is valid
    ///
    /// - Note:
    ///     - Check if person is forced sign out by the cashier
    ///     - Check if email is verificated
    ///     - Set late payment interest
    ///     - Set region code
    private func checkPersonProperties() {
        guard let loggedInPerson = Settings.shared.person else {
            fatalError("No person is signed in.")
        }
        
        // Check if person is forced sign out by the cashier
        guard let person = Self.person.list?.first(where: { $0.id == loggedInPerson.id }) else {
           try? Auth.auth().signOut()
            return forceSignedOut = true
        }
        guard let signInData = person.signInData else {
            try? Auth.auth().signOut()
            return forceSignedOut = true
        }
        
        // Check if email is verificated
        guard let user = Auth.auth().currentUser else {
            return forceSignedOut = true
        }
        if user.email != nil && !user.isEmailVerified {
            let monthsSinceSignIn = Calendar.current.dateComponents([.month], from: signInData.signInDate, to: Date()).month!
            if monthsSinceSignIn >= 1 {
                return emailNotVerificated = true
            }
        }
        
        let dispatchGroup = DispatchGroup()
        let basePath = "clubs/\(loggedInPerson.clubProperties.id.uuidString.uppercased())"
        
        // Get late payment interest
        dispatchGroup.enter()
        Database.database().reference(withPath: basePath + "/latePaymentInterest").observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(), let data = snapshot.value else {
                Settings.shared.latePaymentInterest = nil
                dispatchGroup.leave()
                return
            }
            let decoder = FirebaseDecoder()
            let latePaymentInterest = try? decoder.decode(Settings.LatePaymentInterest?.self, from: data)
            Settings.shared.latePaymentInterest = latePaymentInterest
            dispatchGroup.leave()
        }
        
        // Get region code
        dispatchGroup.enter()
        Database.database().reference(withPath: basePath + "/regionCode").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard snapshot.exists(), let data = snapshot.value else {
                self?.connectionState = .failed
                return
            }
            let decoder = FirebaseDecoder()
            let regionCode = try! decoder.decode(String.self, from: data)
            Settings.shared.person?.clubProperties.regionCode = regionCode
            dispatchGroup.leave()
        }
        
        // Notify dispatch group
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.connectionState = .passed
        }
    }
    #endif
}
