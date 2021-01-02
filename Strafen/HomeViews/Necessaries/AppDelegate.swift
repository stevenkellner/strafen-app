//
//  AppDelegate.swift
//  Strafen
//
//  Created by Steven on 9/6/20.
//

import SwiftUI
import Firebase
import GoogleMobileAds
import FirebaseMessaging

/// App Delegate
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var alreadySetUp = false
    
    /// Returns the configuration data for UIKit to use when creating a new scene
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        setUpApplication()
        applyShortcut(of: options)
        return .default(session: connectingSceneSession)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        setUpApplication()
        return true
    }
    
    func setUpApplication() {
        guard !alreadySetUp else { return }
        alreadySetUp = true
        
        // Configure Firebase
        FirebaseApp.configure()
        try? Auth.auth().useUserAccessGroup("K7NTJ83ZF8.stevenkellner.Strafen.firebaseAuth")
        
        // Initialize the Google Mobile Ads SDK.
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        // Register for push notifications
        registerForPushNotifications()
        
        // Set up push messages
        Messaging.messaging().delegate = self
        Messaging.messaging().subscribe(toTopic: "daily-notification")
        if let person = Settings.shared.person {
            Messaging.messaging().subscribe(toTopic: "clubId-\(person.clubProperties.id)")
            Messaging.messaging().subscribe(toTopic: "personId-\(person.clubProperties.id)-\(person.id)")
        }
    }
    
    /// Applies shortcut
    private func applyShortcut(of options: UIScene.ConnectionOptions) {
        if let shortcutItem = options.shortcutItem {
            switch shortcutItem.type {
            case "profileDetail":
                HomeTabs.shared.active = .profileDetail
            case "personList":
                HomeTabs.shared.active = .personList
            case "reasonList":
                HomeTabs.shared.active = .reasonList
            default:
                break
            }
        }
    }
    
    /// Register for push notification
    private func registerForPushNotifications() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async(execute: UIApplication.shared.registerForRemoteNotifications)
        }
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
}
