//
//  PaymentPayoutView.swift
//  Strafen
//
//  Created by Steven on 3/25/21.
//

import SwiftUI

struct PaymentPayoutView: View {
    
    ///Dismiss handler
    @Binding var dismissHandler: DismissHandler
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            
            // Background Color
            colorScheme.backgroundColor
            
            // Back Button
            BackButton()
            
            // Content
            VStack(spacing: 0) {
                
                // Header
                Header("Auszahlung")
                    .padding(.top, 75)
                
                Spacer()
            }
        }.edgesIgnoringSafeArea(.all)
            .setScreenSize
            .hideNavigationBarTitle()
            .onAppear {
                dismissHandler = { presentationMode.wrappedValue.dismiss() }
                
//                guard let clubId = Settings.shared.person?.clubProperties.id else { return print("agfa") }
//                Payment.shared.allTransactions(clubId: clubId) { transactions in
//                    print(transactions as Any)
//                }
                Fetcher.shared.fetch { (fetchedList: [Transaction]?) in
                    print(fetchedList?.filter { transaction in
                        transaction.approved && transaction.payoutId == nil
                    } as Any)
                }
            }
    }
}
