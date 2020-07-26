//
//  SmallWidget.swift
//  StrafenWidgetExtension
//
//  Created by Steven on 24.07.20.
//

import SwiftUI

/// Small widget view of Strafen Widget
struct SmallWidget: View {
    
    /// Widget entry
    var entry: Provider.Entry
    
    var body: some View {
        Group {
            switch entry.widgetEntryType {
            case .success(person: let person, fineList: let fineList):
                EmptyView()
            case .noConnection:
                EmptyView()
            case .noPersonLoggedIn:
                EmptyView()
            }
        }
    }
}
