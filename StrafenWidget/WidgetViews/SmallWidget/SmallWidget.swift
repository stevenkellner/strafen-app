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
            case .success(person: let person, latePaymentInterest: let latePaymentInterest, fineList: let fineList):
                SmallWidgetSuccess(person: person, latePaymentInterest: latePaymentInterest, style: entry.style, fineList: fineList)
            case .noConnection:
                SmallWidgetNoConnection(style: entry.style)
            case .noPersonLoggedIn:
                SmallWidgetNoPersonLoggedIn(style: entry.style)
            }
        }
    }
}
