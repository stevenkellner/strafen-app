//
//  Provider.swift
//  Strafen
//
//  Created by Steven on 24.07.20.
//

import WidgetKit
import SwiftUI

/// Timeline Provider for Strafen Widget
struct Provider: TimelineProvider {
    
    /// Time interval between two timeline requests
    ///
    /// 600sec = 10min
    static private let timeIntervalToUpdate: TimeInterval = 600
    
    /// Creates a placeholder of the widget
    func placeholder(in context: Context) -> WidgetEntry {
        ListData.fetchPlaceholderLists()
        return WidgetEntry(date: Date(), style: .skeleton)
    }
    
    /// Creates a snapshot of the widget
    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        ListData.fetchPlaceholderLists()
        completion(WidgetEntry(date: Date(), style: .placeholder))
    }
    
    /// Creates a timeline of the widget
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void) {
        Settings.shared.reload()
        ListData.shared.fetchLists {
            let dateForNextTimelineRequest = Date(timeIntervalSinceNow: Self.timeIntervalToUpdate)
            let entry = WidgetEntry(date: dateForNextTimelineRequest, style: .default)
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

/// Entry of timeline of Strafen Widget
struct WidgetEntry: TimelineEntry {
    
    /// Style
    enum Style {
        
        /// Default syle
        case `default`
        
        /// Placeholder style
        case placeholder
        
        /// Skeleton style
        case skeleton
    }

    /// Date of next timeline request
    let date: Date
    
    /// Style
    let style: Style
}
