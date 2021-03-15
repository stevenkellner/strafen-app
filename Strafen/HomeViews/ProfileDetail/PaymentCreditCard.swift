//
//  PaymentCreditCard.swift
//  Strafen
//
//  Created by Steven on 3/8/21.
//

import SwiftUI
import Braintree

struct PaymentCreditCard: View {
    
    /// Card Properties
    struct CardProperties {
        
        /// Credit card validation
        var creditCardValidation = CreditCardValitation()
        
        /// Card number
        var cardNumber: String = "" { didSet { cardNumber = creditCardValidation.formatCardNumber(cardNumber) } }
        
        /// Expiration date
        var expirationDate: String = "" { didSet { expirationDate = creditCardValidation.formatExpirationDate(expirationDate) } }
        
        /// CVV
        var cvv: String = "" { didSet { cvv = creditCardValidation.formatCvv(cvv) } }
        
        /// Error messages for card number
        var cardNumberErrorMessages: ErrorMessages? = nil
        
        /// Error messages for expiration date
        var expirationDateErrorMessages: ErrorMessages? = nil
        
        /// Error messages for cvv
        var cvvErrorMessages: ErrorMessages? = nil
        
        /// Error messages for payment
        var paymentErrorMessages: ErrorMessages? = nil
        
        /// Indicated if card number keyboard is on screen
        var isCardNumberKeyboardOnScreen = false
        
        /// Indicated if expiration date keyboard is on screen
        var isExpirationDateKeyboardOnScreen = false
        
        /// Indicated if cvv keyboard is on screen
        var isCvvKeyboardOnScreen = false
        
        /// Connection state
        var connectionState: ConnectionState = .passed
        
        @discardableResult mutating func evaluateCardNumberError() -> Bool {
            if cardNumber.isEmpty {
                cardNumberErrorMessages = .emptyField
            } else if !creditCardValidation.isCardNumberValid {
                cardNumberErrorMessages = .invalidCreditCardNumber
            } else {
                cardNumberErrorMessages = nil
                return false
            }
            return true
        }
        
        @discardableResult mutating func evaluateExpirationDateError() -> Bool {
            if expirationDate.isEmpty {
                expirationDateErrorMessages = .emptyField
            } else if !creditCardValidation.isExpirationDateValid {
                expirationDateErrorMessages = .invalidDateFormat
            } else if !creditCardValidation.isExpirationDateInFuture {
                expirationDateErrorMessages = .dateInPast
            } else {
                expirationDateErrorMessages = nil
                return false
            }
            return true
        }
        
        @discardableResult mutating func evaluateCvvError() -> Bool {
            if cvv.isEmpty {
                cvvErrorMessages = .emptyField
            } else if !creditCardValidation.isCvvValid {
                cvvErrorMessages = .invalidCvv
            } else {
                cvvErrorMessages = nil
                return false
            }
            return true
        }
        
        /// Check if any errors occurs
        mutating func checkErrors() -> Bool {
            evaluateCardNumberError() |!|
                evaluateExpirationDateError() |!|
                evaluateCvvError()
        }
        
        /// Resets all error messages
        mutating func resetErrorMessages() {
            cardNumberErrorMessages = nil
            expirationDateErrorMessages = nil
            cvvErrorMessages = nil
            paymentErrorMessages = nil
        }
        
        var cardInfo: BTCard {
            let card = BTCard()
            card.number = cardNumber
            card.expirationMonth = String(expirationDate.prefix(2))
            card.expirationYear = String(expirationDate.suffix(2))
            card.cvv = cvv
            return card
        }
    }
    
    /// Ids of fines to pay
    let fineIds: [Fine.ID]
    
    let hideSheet: () -> Void
    
    /// Card Properties
    @State var cardProperties = CardProperties()
    
    /// Fine List Data
    @ObservedObject var fineListData = ListData.fine
    
    /// Reason List Data
    @ObservedObject var reasonListData = ListData.reason
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Bar to wipe sheet down
            SheetBar()
            
            // Header
            Header("Karteninfo Eingeben")
            
            Spacer()
            
            VStack(spacing: 5) {
                
                // Card number
                TitledContent("Karten Nummer") {
                    CustomTextField()
                        .title("Karten Nummer")
                        .textFieldSize(width: UIScreen.main.bounds.width * 0.95, height: 50)
                        .errorMessages($cardProperties.cardNumberErrorMessages)
                        .keyboardOnScreen($cardProperties.isCardNumberKeyboardOnScreen)
                        .textBinding($cardProperties.cardNumber)
                        .keyboardType(.decimalPad)
                        .onCompletion { cardProperties.evaluateCardNumberError() }
                }
                
                // Card icons
                GeometryReader { geometry in
                    HStack(spacing: 5) {
                        ForEach(CreditCardValitation.CardType.allCases, id: \.self) { cardType in
                            Image(cardType.imageName)
                                .resizable().scaledToFit()
                                .frame(width: geometry.size.width / CGFloat(CreditCardValitation.CardType.allCases.count) - 5)
                                .opacity(cardProperties.creditCardValidation.possibleCardTypes.contains(cardType) ? 1 : 0.4)
                        }
                    }
                }.frame(width: UIScreen.main.bounds.width * 0.95 - 5, height: 35)
                
                // Expiration date
                TitledContent("Ablaufdatum", errorMessages: $cardProperties.expirationDateErrorMessages) {
                    HStack(spacing: 15) {
                        CustomTextField()
                            .title("MM / YY")
                            .textFieldSize(width: UIScreen.main.bounds.width * 0.475, height: 50)
                            .errorMessages($cardProperties.expirationDateErrorMessages)
                            .showErrorMessage(false)
                            .keyboardOnScreen($cardProperties.isExpirationDateKeyboardOnScreen)
                            .textBinding($cardProperties.expirationDate)
                            .keyboardType(.decimalPad)
                            .onCompletion { cardProperties.evaluateExpirationDateError() }
                        
                        // Done button
                        if cardProperties.isExpirationDateKeyboardOnScreen || cardProperties.isCardNumberKeyboardOnScreen {
                            Text("Fertig")
                                .foregroundColor(Color.custom.darkGreen)
                                .font(.text(25))
                                .lineLimit(1)
                                .onTapGesture { UIApplication.shared.dismissKeyboard() }
                        }
                    }.animation(.default)
                }
                
                // CVV
                TitledContent("CVV", errorMessages: $cardProperties.cvvErrorMessages) {
                    HStack(spacing: 15) {
                        CustomTextField()
                            .title("CVV")
                            .textFieldSize(width: UIScreen.main.bounds.width * 0.475, height: 50)
                            .errorMessages($cardProperties.cvvErrorMessages)
                            .showErrorMessage(false)
                            .keyboardOnScreen($cardProperties.isCvvKeyboardOnScreen)
                            .textBinding($cardProperties.cvv)
                            .keyboardType(.decimalPad)
                            .onCompletion { cardProperties.evaluateCvvError() }
                        
                        // Done button
                        if cardProperties.isCvvKeyboardOnScreen {
                            Text("Fertig")
                                .foregroundColor(Color.custom.darkGreen)
                                .font(.text(25))
                                .lineLimit(1)
                                .onTapGesture { UIApplication.shared.dismissKeyboard() }
                        }
                    }.animation(.default)
                }
                
            }.padding(.top, 10).keyboardAdaptiveOffset.clipped()
            
            Spacer()
            
            // Cancel and Confirm button
            TitledContent(nil, errorMessages: $cardProperties.paymentErrorMessages) {
                CancelConfirmButton()
                    .title("Bezahlen")
                    .connectionState($cardProperties.connectionState)
                    .onCancelPress(handleCancel)
                    .onConfirmPress(handleConfirm)
            }.padding(.bottom, cardProperties.paymentErrorMessages == nil ? 50 : 25).animation(.default)
            
        }.setScreenSize
    }
    
    func handleCancel() {
        presentationMode.wrappedValue.dismiss()
    }
    
    func handleConfirm() {
        guard cardProperties.connectionState.start() else { return }
        cardProperties.resetErrorMessages()
        Payment.shared.fetchClientToken { token in
            guard let token = token,
                  let braintreeClient = BTAPIClient(authorization: token) else {
                cardProperties.paymentErrorMessages = .internalError
                return cardProperties.connectionState.failed()
            }
            let cardClient = BTCardClient(apiClient: braintreeClient)
            let card = cardProperties.cardInfo
            cardClient.tokenizeCard(card) { tokenizedCard, error in
                guard let tokenizedCard = tokenizedCard,
                      error == nil,
                      let amount = amount,
                      Payment.shared.readyForPayment,
                      let clubId = Settings.shared.person?.clubProperties.id,
                      let personId = Settings.shared.person?.id else {
                    cardProperties.paymentErrorMessages = .internalError
                    return cardProperties.connectionState.failed()
                }
                Payment.shared.checkout(nonce: tokenizedCard.nonce, amount: amount, fineIds: fineIds) { result in
                    guard let result = result, result.success else {
                        cardProperties.paymentErrorMessages = .internalError
                        return cardProperties.connectionState.failed()
                    }
                    let callItem = NewTransactionCall(clubId: clubId, personId: personId, transactionId: result.transaction.id, payedFinesIds: fineIds)
                    FunctionCaller.shared.call(callItem) { _ in
                        cardProperties.connectionState.passed()
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
