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
        
        // Register for push notifications
        registerForPushNotifications()
        
        // Schedule notification
        scheduleNotification()
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
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted else { return }
            center.getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    /// Schedule notification
    private func scheduleNotification() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Bezahl deine Strafen!"
        content.subtitle = "Du könntest noch offene Strafen haben."
        content.body = "Öffne die App um nachzusehen, wieviel du noch zahlen musst und zahl es bis zum nächsten Training."
        content.categoryIdentifier = "daily-notification"
        content.sound = .default
        content.badge = 1

        var dateComponents = DateComponents()
        dateComponents.hour = 18
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
}
