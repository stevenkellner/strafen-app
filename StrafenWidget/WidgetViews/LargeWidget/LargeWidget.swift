//
//  LargeWidget.swift
//  StrafenWidgetExtension
//
//  Created by Steven on 24.07.20.
//

import SwiftUI

/// Large widget view of Strafen Widget
struct LargeWidget: View {
    
    /// Widget entry
    var entry: Provider.Entry
    
    var body: some View {
        Group {
            switch entry.widgetEntryType {
            case .success(person: let person, latePaymentInterest: let latePaymentInterest, fineList: let fineList):
                LargeWidgetSuccess(person: person, latePaymentInterest: latePaymentInterest, style: entry.style, fineList: fineList)
            case .noConnection:
                LargeWidgetNoConnection(style: entry.style)
            case .noPersonLoggedIn:
                LargeWidgetNoPersonLoggedIn(style: entry.style)
            }
        }
    }
}
