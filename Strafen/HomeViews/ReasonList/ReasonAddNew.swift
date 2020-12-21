//
//  ReasonAddNew.swift
//  Strafen
//
//  Created by Steven on 17.07.20.
//

import SwiftUI

/// View to add a new reason
struct ReasonAddNew: View {
    
    /// Properties of reason input
    struct ReasonInputProperties {
        
        /// Input importance
        var importance: Importance = .medium
        
        /// Reason
        var reason = ""
        
        /// Input amount
        var amount: Amount = .zero
        
        /// Input amount string
        var amountString = Amount.zero.stringValue
        
        /// Type of reason textfield error
        var reasonErrorMessages: ErrorMessages? = nil
        
        /// Type of amount textfield error
        var amountErrorMessages: ErrorMessages? = nil
        
        /// Type of function call error
        var functionCallErrorMessages: ErrorMessages? = nil
        
        /// State of data task connection
        var connectionState: ConnectionState = .passed
        
        /// Checks if an error occurs while reason input
        @discardableResult mutating func evaluteReasonError() -> Bool {
            if reason.isEmpty {
                reasonErrorMessages = .emptyField
            } else {
                reasonErrorMessages = nil
                return false
            }
            return true
        }
        
        /// Parse amount from amount string and checks if an error occurs while amount input
        @discardableResult mutating func evaluteAmount() -> Bool {
            amount = amountString.amountValue
            amountString = amount.stringValue
            if amount == .zero {
                amountErrorMessages = .amountZero
            } else {
                amountErrorMessages = nil
                return false
            }
            return true
        }
        
        /// Checks if an error occurs
        mutating func errorOccurred() -> Bool {
            evaluteReasonError() |!| evaluteAmount()
        }
    }
    
    /// Alert type
    enum AlertType: AlertTypeProtocol {
        
        /// Alert when confirm button is pressed
        case confirmButton(action: () -> Void)
        
        /// Id for Identifiable
        var id: Int {
            switch self {
            case .confirmButton(action: _):
                return 0
            }
        }
        
        /// Alert of all alert types
        var alert: Alert {
            switch self {
            case .confirmButton(action: let action):
                return Alert(title: Text("Vorlage Hinzufügen"),
                             message: Text("Möchtest du diese Vorlage wirklich hinzufügen?"),
                             primaryButton: .destructive(Text("Abbrechen")),
                             secondaryButton: .default(Text("Bestätigen"), action: action))
            }
        }
    }
    
    /// Properties of reason input
    @State var reasonInputProperties = ReasonInputProperties()
    
    /// Alert type
    @State var alertType: AlertType? = nil
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Bar to wipe sheet down
            SheetBar()
            
            // Title
            Header("Vorlage Hinzufügen")
            
            ScrollView {
                VStack(spacing: 20) {
                    Spacer()
                    
                    // Importance changer
                    TitledContent("Wichtigkeit") {
                        ImportanceChanger(importance: $reasonInputProperties.importance)
                            .frame(width: 258, height: 25)
                    }
                    
                    // Reason
                    TitledContent("Grund") {
                        CustomTextField()
                            .title("Grund")
                            .textBinding($reasonInputProperties.reason)
                            .errorMessages($reasonInputProperties.reasonErrorMessages)
                            .textFieldSize(width: UIScreen.main.bounds.width * 0.95, height: 50)
                            .onCompletion { reasonInputProperties.evaluteReasonError() }
                    }
                    
                    // Amount
                    AmountInput(reasonInputProperties: $reasonInputProperties)
                    
                    Spacer()
                }.padding(.vertical, 10)
                    .keyboardAdaptiveOffset
            }.padding(.vertical, 10)
                .animation(.default)
            
            VStack(spacing: 5) {
                
                // Confirm button
                ConfirmButton()
                    .connectionState($reasonInputProperties.connectionState)
                    .onButtonPress($alertType, value: .confirmButton(action: handleSave)) {
                        !reasonInputProperties.errorOccurred()
                    }
                    .alert(item: $alertType)
                
                // Error messages
                ErrorMessageView(errorMessages: $reasonInputProperties.functionCallErrorMessages)
                
            }.padding(.bottom, reasonInputProperties.functionCallErrorMessages == nil ? 50 : 25)
                .animation(.default)
            
        }.setScreenSize
    }
    
    /// Handles reason saving
    func handleSave() {
        guard reasonInputProperties.connectionState != .loading,
            !reasonInputProperties.errorOccurred(),
            let clubId = Settings.shared.person?.clubProperties.id else { return }
        reasonInputProperties.connectionState = .loading
        reasonInputProperties.functionCallErrorMessages = nil
        
        let reasonId = ReasonTemplate.ID(rawValue: UUID())
        let reason = ReasonTemplate(id: reasonId, reason: reasonInputProperties.reason, importance: reasonInputProperties.importance, amount: reasonInputProperties.amount)
        let callItem = ChangeListCall(clubId: clubId, changeType: .add, changeItem: reason)
        FunctionCaller.shared.call(callItem) { _ in
            reasonInputProperties.connectionState = .passed
            presentationMode.wrappedValue.dismiss()
        } failedHandler: { _ in
            reasonInputProperties.connectionState = .failed
            reasonInputProperties.functionCallErrorMessages = .internalErrorSave
        }
    }
    
    /// Amount input
    struct AmountInput: View {
        
        /// Properties of inputed reason
        @Binding var reasonInputProperties: ReasonInputProperties
        
        /// Indicated if amount keyboard is on screen
        @State var isAmountKeyboardOnScreen = false
        
        var body: some View {
            TitledContent("Betrag") {
                VStack(spacing: 5) {
                    
                    HStack(spacing: 15) {
                        
                        // Text Field
                        CustomTextField()
                            .title("Betrag")
                            .textBinding($reasonInputProperties.amountString)
                            .keyboardOnScreen($isAmountKeyboardOnScreen)
                            .errorMessages($reasonInputProperties.amountErrorMessages)
                            .showErrorMessage(false)
                            .textFieldSize(width: 148)
                            .keyboardType(.decimalPad)
                            .onCompletion { reasonInputProperties.evaluteAmount() }

                        // Currency sign
                        Text(Amount.locale.currencySymbol ?? "€")
                            .configurate(size: 25)
                            .lineLimit(1)
                        
                        // Done button
                        if isAmountKeyboardOnScreen {
                            Text("Fertig")
                                .foregroundColor(Color.custom.darkGreen)
                                .font(.text(25))
                                .lineLimit(1)
                                .onTapGesture {
                                    UIApplication.shared.dismissKeyboard()
                                }
                        }
                        
                    }.frame(height: 50)
                    
                    // Error messages
                    ErrorMessageView(errorMessages: $reasonInputProperties.amountErrorMessages)
                    
                }
            }
        }
    }
}
