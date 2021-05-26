//
//  PaymentCreditCard.swift
//  Strafen
//
//  Created by Steven on 3/8/21.
//

import SwiftUI
import Braintree
import FirebaseDatabase

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
        
        /// First name
        var firstName: String = ""
        
        /// Last name
        var lastName: String = ""
        
        /// Error messages for card number
        var cardNumberErrorMessages: ErrorMessages? = nil
        
        /// Error messages for expiration date
        var expirationDateErrorMessages: ErrorMessages? = nil
        
        /// Error messages for cvv
        var cvvErrorMessages: ErrorMessages? = nil
        
        /// Error messages for first name
        var firstNameErrorMessages: ErrorMessages? = nil
        
        /// Error messages for last name
        var lastNameErrorMessages: ErrorMessages? = nil
        
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
                cardNumberErrorMessages = .emptyField(code: 14)
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
                expirationDateErrorMessages = .emptyField(code: 15)
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
                cvvErrorMessages = .emptyField(code: 16)
            } else if !creditCardValidation.isCvvValid {
                cvvErrorMessages = .invalidCvv
            } else {
                cvvErrorMessages = nil
                return false
            }
            return true
        }
        
        @discardableResult mutating func evaluateFirstNameError() -> Bool {
            if firstName.isEmpty {
                firstNameErrorMessages = .emptyField(code: 17)
            } else {
                firstNameErrorMessages = nil
                return false
            }
            return true
        }
        
        @discardableResult mutating func evaluateLastNameError() -> Bool {
            if lastName.isEmpty {
                lastNameErrorMessages = .emptyField(code: 18)
            } else {
                lastNameErrorMessages = nil
                return false
            }
            return true
        }
        
        /// Check if any errors occurs
        mutating func checkErrors() -> Bool {
            evaluateCardNumberError() |!|
                evaluateExpirationDateError() |!|
                evaluateCvvError() |!|
                evaluateFirstNameError() |!|
                evaluateLastNameError()
        }
        
        /// Resets all error messages
        mutating func resetErrorMessages() {
            cardNumberErrorMessages = nil
            expirationDateErrorMessages = nil
            cvvErrorMessages = nil
            paymentErrorMessages = nil
            firstNameErrorMessages = nil
            lastNameErrorMessages = nil
        }
        
        var cardInfo: BTCard {
            let card = BTCard()
            card.number = cardNumber
            card.expirationMonth = String(expirationDate.prefix(2))
            card.expirationYear = String(expirationDate.suffix(2))
            card.cvv = cvv
            return card
        }
        
        var creditCardInformation: CreditCardInformation {
            CreditCardInformation(firstName: firstName, lastName: lastName, cardNumber: cardNumber, expirationDate: expirationDate, cvv: cvv)
        }
        
        mutating func setFromInformation(_ information: CreditCardInformation) {
            resetErrorMessages()
            if let firstName = information.firstName { self.firstName = firstName }
            if let lastName = information.lastName { self.firstName = lastName }
            cardNumber = information.cardNumber
            expirationDate = information.expirationDate
            cvv = information.cvv
        }
    }
    
    /// Ids of fines to pay
    let fineIds: [Fine.ID]
    
    let hideSheet: () -> Void
    
    /// Card Properties
    @State var cardProperties = CardProperties()
    
    /// Last credit card information
    @State var lastCreditCard: CreditCardInformation? = nil
    
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
            
            ScrollView {
                VStack(spacing: 5) {
                    
                    // Last credit card
                    if let lastCreditCard = lastCreditCard {
                        TitledContent("Letzte Karte benutzen") {
                            ZStack {
                                Outline()
                                VStack(spacing: 0) {
                                    HStack(spacing: 0) {
                                        Text(lastCreditCard.maskedCardNumber).configurate(size: lastCreditCard.formattedName == nil ? 25 : 17.5).lineLimit(1)
                                        Spacer()
                                        Text(lastCreditCard.expirationDate).configurate(size: lastCreditCard.formattedName == nil ? 25 : 17.5).lineLimit(1)
                                    }.padding(.horizontal, 15)
                                    if let name = lastCreditCard.formattedName {
                                        HStack(spacing: 0) {
                                            Text(name).configurate(size: 17.5).lineLimit(1)
                                            Spacer()
                                        }.padding(.horizontal, 15)
                                    }
                                }
                            }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                        }.titleColor(Color.custom.orange).padding(.bottom, 10)
                            .onTapGesture { cardProperties.setFromInformation(lastCreditCard) }
                    }
                    
                    // Name
                    TitledContent("Name") {
                        
                        // First name
                        CustomTextField()
                            .title("Vorname")
                            .textBinding($cardProperties.firstName)
                            .errorMessages($cardProperties.firstNameErrorMessages)
                            .textFieldSize(width: UIScreen.main.bounds.width * 0.95, height: 50)
                            .onCompletion { cardProperties.evaluateFirstNameError() }
                        
                        // Last name
                        CustomTextField()
                            .title("Nachname")
                            .textBinding($cardProperties.lastName)
                            .errorMessages($cardProperties.lastNameErrorMessages)
                            .textFieldSize(width: UIScreen.main.bounds.width * 0.95, height: 50)
                            .onCompletion { cardProperties.evaluateLastNameError() }
                        
                    }
                    
                    // Card number
                    TitledContent("Karten Nummer", errorMessages: $cardProperties.cardNumberErrorMessages) {
                        HStack(spacing: 15) {
                            CustomTextField()
                                .title("Karten Nummer")
                                .textFieldSize(width: UIScreen.main.bounds.width * 0.95 - (cardProperties.isCardNumberKeyboardOnScreen ? 80 : 0), height: 50)
                                .errorMessages($cardProperties.cardNumberErrorMessages)
                                .showErrorMessage(false)
                                .keyboardOnScreen($cardProperties.isCardNumberKeyboardOnScreen)
                                .textBinding($cardProperties.cardNumber)
                                .keyboardType(.decimalPad)
                                .onCompletion { cardProperties.evaluateCardNumberError() }
                            
                            // Done button
                            if cardProperties.isCardNumberKeyboardOnScreen {
                                Text("Fertig")
                                    .foregroundColor(Color.custom.darkGreen)
                                    .font(.text(25))
                                    .lineLimit(1)
                                    .onTapGesture { UIApplication.shared.dismissKeyboard() }
                            }
                        }.animation(.default)
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
                            if cardProperties.isExpirationDateKeyboardOnScreen {
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
                    
                }.padding(.vertical, 5).keyboardAdaptiveOffset.clipped()
            }.padding(.vertical, 5)
            
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
            .onAppear {
                cardProperties.firstName = Settings.shared.person?.name.firstName ?? ""
                cardProperties.lastName = Settings.shared.person?.name.lastName ?? ""
                fetchCardInformation()
            }
    }
    
    func handleCancel() {
        presentationMode.wrappedValue.dismiss()
    }
    
    func handleConfirm() {
        guard cardProperties.connectionState.start(),
              !cardProperties.checkErrors() else { return }
        cardProperties.resetErrorMessages()
        Payment.shared.fetchClientToken { token in
            guard Payment.shared.readyForPayment,
                  let token = token,
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
                    let transaction = Transaction(id: result.transaction.id.rawValue, fineIds: fineIds, name: OptionalPersonName(first: cardProperties.firstName, last: cardProperties.lastName), personId: personId)
                    let callItem = NewTransactionCall(clubId: clubId, transaction: transaction)
                    FunctionCaller.shared.call(callItem) { _ in
                        cardProperties.connectionState.passed()
                        hideSheet()
                    }
                    guard let information = cardProperties.creditCardInformation.encrypted?.isoLatin1String else { return }
                    let callItemSave = SaveCreditCardCall(clubId: clubId, personId: personId, information: information)
                    FunctionCaller.shared.call(callItemSave) { _ in }
                }
            }
        }
    }
    
    func fetchCardInformation() {
        guard let personId = Settings.shared.person?.id,
              let clubId = Settings.shared.person?.clubProperties.id else { return }
        let url = URL(string: Bundle.main.firebaseClubsComponent)!
            .appendingPathComponent(clubId.uuidString)
            .appendingPathComponent("persons")
            .appendingPathComponent(personId.uuidString)
            .appendingPathComponent("creditCard")
        Database.database().reference(withPath: url.path).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(),
                  let encryptedData = snapshot.value as? String,
                  let encryptedByteList = encryptedData.isoLatin1ByteList else { return }
            let information = CreditCardInformation(encrypted: encryptedByteList)
            lastCreditCard = information
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
