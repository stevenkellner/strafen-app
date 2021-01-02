//
//  DailyNotificationContent.swift
//  StrafenNotificationService
//
//  Created by Steven on 1/1/21.
//

import UserNotifications

/// Notification Content for daily notification
struct DailyNotificationContent {
    
    /// Shared instance for singelton
    static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    func getContent(initial content: UNMutableNotificationContent?, handler completionHandler: @escaping (UNMutableNotificationContent?) -> Void) {
        Settings.shared.reload()
        ListData.shared.fetchLists {
            guard let person = Settings.shared.person,
                  let reasonList = ListData.reason.list,
                  let unpayedAmountSum = ListData.fine.list?.amountSum(of: person.id, with: reasonList).unpayed,
                  unpayedAmountSum != .zero else { return completionHandler(nil) }
            content?.title = "\(person.name.firstName), bezahl deine Strafen!"
            content?.subtitle = "Du hast noch \(String(describing: unpayedAmountSum)) offene Strafen."
            content?.body = "Bezahl deine \(String(describing: unpayedAmountSum)) Strafe bis zum nächsten Training oder Spiel."
            completionHandler(content)
        }
    }
}
