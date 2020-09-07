//
//  MediumWidget.swift
//  StrafenWidgetExtension
//
//  Created by Steven on 24.07.20.
//

import SwiftUI

/// Medium widget view of Strafen Widget
struct MediumWidget: View {
    
    /// Widget entry
    var entry: Provider.Entry
    
    var body: some View {
        Group {
            switch entry.widgetEntryType {
            case .success(person: let person, latePaymentInterest: let latePaymentInterest, fineList: let fineList):
                MediumWidgetSuccess(person: person, latePaymentInterest: latePaymentInterest, style: entry.style, fineList: fineList)
            case .noConnection:
                MediumWidgetNoConnection(style: entry.style)
            case .noPersonLoggedIn:
                MediumWidgetNoPersonLoggedIn(style: entry.style)
            }
        }
    }
}
