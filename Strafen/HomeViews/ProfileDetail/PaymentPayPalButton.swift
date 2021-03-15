//
//  PaymentPayPalButton.swift
//  Strafen
//
//  Created by Steven on 3/15/21.
//

import SwiftUI
import Braintree

struct PaymentPayPalButton: View {
    
    /// Ids of fines to pay
    let fineIds: [Fine.ID]
    
    let hideSheet: () -> Void
    
    /// Fine List Data
    @ObservedObject var fineListData = ListData.fine
    
    /// Reason List Data
    @ObservedObject var reasonListData = ListData.reason
    
    var body: some View {
        ZStack {
            Outline().fillColor(Color.init(red: 0.129, green: 0.424, blue: 0.722), onlyDefault: false)
            Image("paypal_logo").resizable().scaledToFit().frame(height: 25)
        }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
            .onTapGesture(perform: handlePayment)
    }
    
    func handlePayment() {
        Payment.shared.fetchClientToken { token in
            guard let amount = amount,
                  Payment.shared.readyForPayment,
                  let token = token,
                  let braintreeClient = BTAPIClient(authorization: token) else { return }
            let payPalDriver = BTPayPalDriver(apiClient: braintreeClient)
            let payPalRequest = BTPayPalCheckoutRequest(amount: amount.forPayment)
            payPalDriver.tokenizePayPalAccount(with: payPalRequest) { tokenizedPayPal, error in
                guard let nonce = tokenizedPayPal?.nonce,
                    let clubId = Settings.shared.person?.clubProperties.id,
                    let personId = Settings.shared.person?.id else { return }
                Payment.shared.checkout(nonce: nonce, amount: amount, fineIds: fineIds) { result in
                    guard let result = result, result.success else { return }
                    let callItem = NewTransactionCall(clubId: clubId, personId: personId, transactionId: result.transaction.id, payedFinesIds: fineIds)
                    FunctionCaller.shared.call(callItem) { _ in
                        hideSheet()
                    }
                }
            }
        }
    }
    
    var amount: Amount? {
        fineListData.list?.filter {
            fineIds.contains($0.id)
        }.reduce(into: .zero) { result, fine in
            result += fine.completeAmount(with: reasonListData.list)
        }
    }
}
