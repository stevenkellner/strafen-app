//
//  NotificationService.swift
//  StrafenNotificationService
//
//  Created by Steven on 1/1/21.
//

import UserNotifications
import Firebase

class NotificationService: UNNotificationServiceExtension {
    
    override init() {
        super.init()
        FirebaseApp.configure()
        try? Auth.auth().useUserAccessGroup("K7NTJ83ZF8.stevenkellner.Strafen.firebaseAuth")
    }

    /// Handles notification content
    var contentHandler: ((UNNotificationContent) -> Void)?
    
    /// Received content
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        switch bestAttemptContent?.userInfo["category"] as? String {
        case "daily-notification":
            DailyNotificationContent.shared.getContent(initial: bestAttemptContent) { [weak self] content in
                self?.bestAttemptContent = content
                dispatchGroup.leave()
            }
        default:
            dispatchGroup.leave()
        }
        
        if let bestAttemptContent = bestAttemptContent {
            dispatchGroup.notify(queue: .main) {
                contentHandler(bestAttemptContent)
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler,
           let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
