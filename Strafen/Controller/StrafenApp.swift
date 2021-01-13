//
//  StrafenApp.swift
//  Strafen
//
//  Created by Steven on 26.06.20.
//

import SwiftUI

@main
struct StrafenApp: App {
    
    /// App Delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    /// Scene Phase
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.onChange(of: scenePhase, perform: handleScenePhaseChange)
    }
    
    /// Handles change of scene phase
    func handleScenePhaseChange(to phase: ScenePhase) {
        switch phase {
        case .active:
            UIApplication.shared.applicationIconBadgeNumber = 0
        case .inactive:
            break
        case .background:
            ImageStorage.shared.clear()
        @unknown default:
            break
        }
    }
}
