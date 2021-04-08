//
//  PaymentApplePayButton.swift
//  Strafen
//
//  Created by Steven on 3/15/21.
//

import SwiftUI
import PassKit
import Braintree

struct PaymentApplePayButton: View {
    
    /// Ids of fines to pay
    let fineIds: [Fine.ID]
    
    let hideSheet: () -> Void
    
    /// Fine List Data
    @ObservedObject var fineListData = ListData.fine
    
    /// Reason List Data
    @ObservedObject var reasonListData = ListData.reason
    
    let controller = PaymentApplePayController()
 
    var body: some View {
        ZStack {
            controller
            Outline().fillColor(.clear, onlyDefault: false)
        }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
            .onTapGesture {
                guard let amount = amount else { return }
                controller.handlePayment(amount: amount, fineIds: fineIds, hideSheet: hideSheet)
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

struct PaymentApplePayController: UIViewControllerRepresentable {
    
    let viewController = PaymentApplePayViewController()
    
    func makeUIViewController(context: Context) -> PaymentApplePayViewController { viewController }
    
    func updateUIViewController(_ uiViewController: PaymentApplePayViewController, context: Context) {}
    
    func handlePayment(amount: Amount, fineIds: [Fine.ID], hideSheet: @escaping () -> Void) {
        viewController.handlePayment(amount: amount, fineIds: fineIds, hideSheet: hideSheet)
    }
}

class PaymentApplePayViewController: UIViewController {
    
    var applePayClient: BTApplePayClient!
    
    var amount: Amount!
    
    var fineIds: [Fine.ID]!
    
    var hideSheet: (() -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if PKPaymentAuthorizationViewController.canMakePayments() {
            let button = PKPaymentButton(paymentButtonType: .checkout, paymentButtonStyle: .black)
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            view.addConstraints([NSLayoutConstraint.Attribute.top, .bottom, .leading, .trailing].map({ NSLayoutConstraint(item: button, attribute: $0, relatedBy: .equal, toItem: view, attribute: $0, multiplier: 1, constant: 0) }))
        }
    }
    
    func handlePayment(amount: Amount, fineIds: [Fine.ID], hideSheet: @escaping () -> Void) {
        Payment.shared.fetchClientToken { token in
            guard Payment.shared.readyForPayment,
                  let token = token,
                  let braintreeClient = BTAPIClient(authorization: token) else { return }
            self.amount = amount
            self.fineIds = fineIds
            self.hideSheet = hideSheet
            self.applePayClient = BTApplePayClient(apiClient: braintreeClient)
            self.applePayClient.paymentRequest { paymentRequest, _ in
                guard let paymentRequest = paymentRequest else { return }
                paymentRequest.currencyCode = "EUR"
                paymentRequest.merchantCapabilities = .capability3DS
                paymentRequest.requiredBillingContactFields = [.name]
                paymentRequest.paymentSummaryItems = [PKPaymentSummaryItem(label: "Strafen", amount: NSDecimalNumber(string: amount.forPayment))]
                if let viewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) {
                    viewController.delegate = self
                    self.present(viewController, animated: true)
                }
            }
        }
    }
}

extension PaymentApplePayViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        applePayClient.tokenizeApplePay(payment) { tokenizedApplePay, _ in
            guard let tokenizedApplePay = tokenizedApplePay,
                let clubId = Settings.shared.person?.clubProperties.id,
                let personId = Settings.shared.person?.id else { return completion(PKPaymentAuthorizationResult(status: .failure, errors: nil)) }
            Payment.shared.checkout(nonce: tokenizedApplePay.nonce, amount: self.amount, fineIds: self.fineIds) { result in
                guard let result = result, result.success else { return completion(PKPaymentAuthorizationResult(status: .failure, errors: nil)) }
                let transaction = Transaction(id: result.transaction.id.rawValue, fineIds: self.fineIds, name: payment.billingContact?.name?.optionalPersonName, personId: personId)
                let callItem = NewTransactionCall(clubId: clubId, transaction: transaction)
                FunctionCaller.shared.call(callItem) { _ in
                    completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                    self.hideSheet()
                }
            }
        }
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        applePayClient.tokenizeApplePay(payment) { tokenizedApplePay, _ in
            guard let tokenizedApplePay = tokenizedApplePay,
                let clubId = Settings.shared.person?.clubProperties.id,
                let personId = Settings.shared.person?.id else { return completion(.failure) }
            Payment.shared.checkout(nonce: tokenizedApplePay.nonce, amount: self.amount, fineIds: self.fineIds) { result in
                guard let result = result, result.success else { return completion(.failure) }
                let transaction = Transaction(id: result.transaction.id.rawValue, fineIds: self.fineIds, name: payment.billingContact?.name?.optionalPersonName, personId: personId)
                let callItem = NewTransactionCall(clubId: clubId, transaction: transaction)
                FunctionCaller.shared.call(callItem) { _ in
                    completion(.success)
                    self.hideSheet()
                }
            }
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        dismiss(animated: true)
    }
}
