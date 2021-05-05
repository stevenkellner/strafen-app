//
//  AppDelegate.swift
//  Strafen
//
//  Created by Steven on 9/6/20.
//

import SwiftUI
import Firebase

/// App Delegate
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    /// Indicates wether the app is already is set up
    var alreadySetUp = false
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        setUpApplication()
        return .default(session: connectingSceneSession)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        setUpApplication()
        return true
    }
    
    /// Set up the app only once by launch.
    ///
    /// - Configure the firebase app
    func setUpApplication() {
        guard !alreadySetUp else { return }
        alreadySetUp = true
        
        // Configure Firebase
        FirebaseApp.configure()
    }
}
