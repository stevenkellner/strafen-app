//
//  ReasonEditor.swift
//  Strafen
//
//  Created by Steven on 17.07.20.
//

import SwiftUI

/// View to edit a reason
struct ReasonEditor: View {
    
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
        var connectionStateUpdate: ConnectionState = .passed
        
        /// State of data task connection
        var connectionStateDelete: ConnectionState = .passed
        
        /// Sets properties with reason
        mutating func setProperties(with reason: ReasonTemplate) {
            importance = reason.importance
            self.reason = reason.reason
            amount = reason.amount
            amountString = amount.stringValue
        }
        
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
        
        mutating func resetErrors() {
            reasonErrorMessages = nil
            amountErrorMessages = nil
            functionCallErrorMessages = nil
        }
    }
    
    /// Alert type
    enum AlertType: AlertTypeProtocol {
        
        /// Alert when confirm button is pressed
        case confirmButton(action: () -> Void)
        
        /// Alert when delete button is pressed
        case deleteButton(action: () -> Void)
        
        /// Alert when reason isn't deletable
        case reasonUndeletable
        
        /// Id for Identifiable
        var id: Int {
            switch self {
            case .confirmButton(action: _):
                return 0
            case .deleteButton(action: _):
                return 1
            case .reasonUndeletable:
                return 2
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
            case .deleteButton(action: let action):
                return Alert(title: Text("Vorlage Löschen"),
                             message: Text("Möchtest du diese Vorlage wirklich löschen?"),
                             primaryButton: .cancel(Text("Abbrechen")),
                             secondaryButton: .destructive(Text("Löschen"), action: action))
            case .reasonUndeletable:
                return Alert(title: Text("Nicht Löschbar"),
                             message: Text("Die Vorlage kann nicht gelöscht werden, da es Strafen gibt, die diese Vorlage benutzen."),
                             dismissButton: .default(Text("Verstanden")))
                
            }
        }
    }
    
    /// Reason to edit
    let reasonToEdit: ReasonTemplate
    
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
            Header("Vorlage Ändern")
            
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
                DeleteConfirmButton()
                    .deleteConnectionState($reasonInputProperties.connectionStateDelete)
                    .confirmConnectionState($reasonInputProperties.connectionStateUpdate)
                    .onDeletePress($alertType, value: .deleteButton(action: handleDelete))
                    .onConfirmPress($alertType, value: .confirmButton(action: handleUpdate)) {
                        !reasonInputProperties.errorOccurred()
                    }
                    .alert(item: $alertType)
                
                // Error messages
                ErrorMessageView(errorMessages: $reasonInputProperties.functionCallErrorMessages)
                
            }.padding(.bottom, reasonInputProperties.functionCallErrorMessages == nil ? 50 : 25)
                .animation(.default)
            
        }.setScreenSize
            .onAppear {
                reasonInputProperties.setProperties(with: reasonToEdit)
            }
    }
    
    /// Handles reason deleting
    func handleDelete() {
        reasonInputProperties.resetErrors()
        guard reasonInputProperties.connectionStateDelete != .loading,
              reasonInputProperties.connectionStateUpdate != .loading,
              let clubId = NewSettings.shared.properties.person?.clubProperties.id else { return }
        reasonInputProperties.connectionStateDelete = .loading
        
        guard !(NewListData.fine.list?.contains(where: { ($0.fineReason as? NewFineReasonTemplate)?.templateId == reasonToEdit.id }) ?? true) else {
            reasonInputProperties.connectionStateDelete = .failed
            return alertType = .reasonUndeletable
        }
        
        let callItem = ChangeListCall(clubId: clubId, changeType: .delete, changeItem: reasonToEdit)
        FunctionCaller.shared.call(callItem) { _ in
            reasonInputProperties.connectionStateDelete = .passed
            presentationMode.wrappedValue.dismiss()
        } failedHandler: { _ in
            reasonInputProperties.connectionStateDelete = .failed
            reasonInputProperties.functionCallErrorMessages = .internalErrorDelete
        }
    }
    
    /// Handles reason updating
    func handleUpdate() {
        reasonInputProperties.resetErrors()
        guard reasonInputProperties.connectionStateDelete != .loading,
              reasonInputProperties.connectionStateUpdate != .loading,
              !reasonInputProperties.errorOccurred(),
              let clubId = NewSettings.shared.properties.person?.clubProperties.id else { return }
        reasonInputProperties.connectionStateUpdate = .loading
        
        let reason = ReasonTemplate(id: reasonToEdit.id, reason: reasonInputProperties.reason, importance: reasonInputProperties.importance, amount: reasonInputProperties.amount)
        let callItem = ChangeListCall(clubId: clubId, changeType: .update, changeItem: reason)
        FunctionCaller.shared.call(callItem) { _ in
            reasonInputProperties.connectionStateUpdate = .passed
            presentationMode.wrappedValue.dismiss()
        } failedHandler: { _ in
            reasonInputProperties.connectionStateUpdate = .failed
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
