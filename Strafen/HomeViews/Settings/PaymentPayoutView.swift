//
//  PaymentPayoutView.swift
//  Strafen
//
//  Created by Steven on 3/25/21.
//

import SwiftUI

struct PaymentPayoutView: View {
    
    enum Errors {
        
        /// Internal error
        case internalError
        
        /// Already a paout
        case alreadyPayout
        
        /// Amount zero
        case amountZero
    }
    
    ///Dismiss handler
    @Binding var dismissHandler: DismissHandler
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Fine List Data
    @ObservedObject var fineListData = ListData.fine
    
    /// Reason List Data
    @ObservedObject var reasonListData = ListData.reason
    
    @State var error: Errors? = nil
    
    @State var amount: Amount? = nil
    
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
                
                if let error = error {
                    VStack(spacing: 5) {
                        switch error {
                        case .internalError:
                            Text("Es gab ein Problem, versuch es erneut oder kontaktiere einen Verantwortlichen.").foregroundColor(Color.custom.red).configurate(size: 25).lineLimit(3).padding(.horizontal, 15)
                        case .alreadyPayout:
                            Text("Es wird gerade eine Auszahlung bearbeitet. Versuche es danach erneut.").foregroundColor(Color.custom.red).configurate(size: 25).lineLimit(3).padding(.horizontal, 15)
                        case .amountZero:
                            Text("Es ist kein Geld eingezahlt, welches ausgezahlt werden könnte.").foregroundColor(Color.custom.red).configurate(size: 25).lineLimit(3).padding(.horizontal, 15)
                        }
                    }.padding(.top, 50)
                } else if let amount = amount {
                    VStack(spacing: 5) {
                                                                                                                                                                                                                                        
                    }.padding(.top, 30)
                } else {
                    ZStack {
                        colorScheme.backgroundColor
                        ProgressView("Laden")
                    }.padding(.top, 30)
                }
                
                Spacer()
                
                if amount != nil {
                    
                }
            }
        }.edgesIgnoringSafeArea(.all)
            .setScreenSize
            .hideNavigationBarTitle()
            .onAppear {
                dismissHandler = { presentationMode.wrappedValue.dismiss() }
                fetchAmount()
            }
    }
    
    /// Fetch amount that is available to payout and check if a payout is valid
    func fetchAmount() {
        error = nil
        amount = nil
        guard let clubId = Settings.shared.person?.clubProperties.id else { return error = .internalError }
        var totalPayedInAmount: Amount?
        var availableAmount: Amount?
        var alreadyPayedOutAmount: Amount?
        var hasPendingPayout: Bool?
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        fetchTotalPayedInAmount(clubId: clubId) { amount in
            totalPayedInAmount = amount
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        fetchAvailableAmount { amount in
            availableAmount = amount
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        fetchAlreadyPayedOutAmount { pendingPayout, amount in
            alreadyPayedOutAmount = amount
            hasPendingPayout = pendingPayout
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
            guard let totalPayedInAmount = totalPayedInAmount,
                let availableAmount = availableAmount,
                let alreadyPayedOutAmount = alreadyPayedOutAmount,
                let hasPendingPayout = hasPendingPayout else { return error = .internalError }
            guard !hasPendingPayout else { return error = .alreadyPayout }
            guard availableAmount <= totalPayedInAmount - alreadyPayedOutAmount else { return error = .internalError }
            guard !availableAmount.isZero else { return error = .amountZero }
            amount = availableAmount
        }
    }
    
    /// Fetch amount of all payed in transactions, regardless if already payed out
    func fetchTotalPayedInAmount(clubId: Club.ID, handler completionHandler: @escaping (Amount?) -> Void) {
        Payment.shared.allTransactions(clubId: clubId) { transactions in
            let amount = transactions?.lazy.filter {
                $0.currencyIsoCode == "EUR" // Only transactions with Euro
            }.compactMap { transaction -> Amount? in
                guard let amountValue = Double(transaction.amount) else { return nil }
                return Amount(doubleValue: amountValue) // Get amount of transaction
            }.reduce(into: .zero) { result, amount in
                result += amount // Sum up amounts of all transactions
            }
            completionHandler(amount)
        }
    }
    
    /// Fetch amount that is available to payout
    func fetchAvailableAmount(handler completionHandler: @escaping (Amount?) -> Void) {
        Fetcher.shared.fetch { (fetchedList: [Transaction]?) in
            let amount = fetchedList?.lazy.filter { transaction in
                transaction.approved && transaction.payoutId == nil // Only transactions that are approved and hasn't payed out
            }.map {
                $0.fineIds.lazy.compactMap { fineId in
                    fineListData.list?.first {
                        $0.id == fineId
                    }?.completeAmount(with: reasonListData.list)
                }.reduce(into: .zero) { result, amount in
                    result += amount
                } // Get total amount of a transaction
            }.reduce(into: .zero) { result, amount in
                result += amount // Sum up amounts of all transactions
            }
            completionHandler(amount)
        }
    }
    
    /// Fetch amount that is already payed out and check if already a payout is pending
    func fetchAlreadyPayedOutAmount(handler completionHandler: @escaping (_ pendingPayout: Bool?, _ amount: Amount?) -> Void) {
        Fetcher.shared.fetch { (fetchedList: [Payout]?) in
            let hasActivePayout = fetchedList?.contains {
                $0.status == .pending
            }
            let amountPayedOut = fetchedList?.lazy.filter {
                $0.status == .approved // Only approved payouts
            }.reduce(into: .zero) { result, payout in
                result += payout.amount // Sum up amounts of all payouts
            }
            completionHandler(hasActivePayout, amountPayedOut)
        }
    }
}
