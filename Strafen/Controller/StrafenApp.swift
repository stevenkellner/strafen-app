//
//  StrafenApp.swift
//  Strafen
//
//  Created by Steven on 26.06.20.
//

import SwiftUI
@main
struct StrafenApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.onChange(of: scenePhase) { phase in
            if phase == .background {
                ImageData.shared.personImage = []
            }
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
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
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
