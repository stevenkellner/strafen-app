//
//  FineEditor.swift
//  Strafen
//
//  Created by Steven on 11/26/20.
//

import SwiftUI

/// View to edit a  fine
struct FineEditor: View {
    
    /// Properties of inputed fine
    struct FineInputProperties {
        
        /// Input importance
        var importance: Importance = .medium
        
        /// Reason
        var reason = ""
        
        /// Input number
        var number = 1
        
        /// Input amount
        var amount: Amount = .zero
        
        /// Input amount string
        var amountString = Amount.zero.stringValue
        
        /// Input date
        var date = Date()
        
        /// Template id
        var templateId: ReasonTemplate.ID?
        
        /// Type of reason textfield error
        var reasonErrorMessages: ErrorMessages? = nil
        
        /// Type of amount textfield error
        var amountErrorMessages: ErrorMessages? = nil
        
        /// Type of function call error
        var functionCallErrorMessages: ErrorMessages? = nil
        
        /// State of data task connection
        var connectionStateDelete: ConnectionState = .passed
        
        /// State of data task connection
        var connectionStateUpdate: ConnectionState = .passed
        
        /// Set properties of given fine
        mutating func setProperties(of fine: NewFine, with reasonList: [ReasonTemplate]?) {
            importance = fine.fineReason.importance(with: reasonList)
            reason = fine.fineReason.reason(with: reasonList)
            amount = fine.fineReason.amount(with: reasonList)
            templateId = (fine.fineReason as? NewFineReasonTemplate)?.templateId
            amountString = amount.stringValue
            number = fine.number
            date = fine.date
        }
        
        /// Set properties of given reason template
        mutating func setProperties(with reason: ReasonTemplate) {
            self.reason = reason.reason
            amount = reason.amount
            amountString = amount.stringValue
            importance = reason.importance
            templateId = reason.id
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
        
        /// Get updated fine with inputed properties
        mutating func getFine(old oldFine: NewFine, with reasonList: [ReasonTemplate]?) -> NewFine? {
            var isError = false
            isError = evaluteReasonError() || isError
            isError = evaluteAmount() || isError
            guard !isError else { return nil }
            
            var fineReason: NewFineReason = NewFineReasonCustom(reason: reason, amount: amount, importance: importance)
            if let templateId = templateId {
                let fineReasonTemplate = NewFineReasonTemplate(templateId: templateId)
                if fineReason.reason(with: reasonList) == fineReasonTemplate.reason(with: reasonList) &&
                    fineReason.amount(with: reasonList) == fineReasonTemplate.amount(with: reasonList) &&
                    fineReason.importance(with: reasonList) == fineReasonTemplate.importance(with: reasonList) {
                    fineReason = fineReasonTemplate
                }
            }
            
            return NewFine(id: oldFine.id, assoiatedPersonId: oldFine.assoiatedPersonId, date: date, payed: oldFine.payed, number: number, fineReason: fineReason)
        }
        
        /// Reset all error messages
        mutating func resetErrorMessages() {
            reasonErrorMessages = nil
            amountErrorMessages = nil
            functionCallErrorMessages = nil
        }
    }
    
    /// Alert type
    enum AlertType: AlertTypeProtocol {
        
        /// Alert when delete button is pressed
        case deleteButton(action: () -> Void)
        
        /// Alert when confirm button is pressed
        case confirmButton(action: () -> Void)
        
        /// Id for Identifiable
        var id: Int {
            switch self {
            case .deleteButton(action: _):
                return 0
            case .confirmButton(action: _):
                return 1
            }
        }
        
        /// Alert of all alert types
        var alert: Alert {
            switch self {
            case .deleteButton(action: let action):
                return Alert(title: Text("Strafe Löschen"),
                             message: Text("Möchtest du diese Strafe wirklich löschen?"),
                             primaryButton: .cancel(Text("Abbrechen")),
                             secondaryButton: .destructive(Text("Löschen"), action: action))
            case .confirmButton(action: let action):
                return Alert(title: Text("Strafe Ändern"),
                             message: Text("Möchtest du diese Strafe wirklich ändern?"),
                             primaryButton: .destructive(Text("Abbrechen")),
                             secondaryButton: .default(Text("Bestätigen"), action: action))
            }
        }
    }
    
    /// Fine to edit
    let fine: NewFine
    
    /// Properties of inputed fine
    @State var fineInputProperties = FineInputProperties()
    
    /// Alert type
    @State var alertType: AlertType? = nil
    
    /// Reason List Data
    @ObservedObject var reasonListData = NewListData.reason
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
        
    var body: some View {
        VStack(spacing: 0) {
            
            // Bar to wipe sheet down
            SheetBar()
            
            // Title
            Header("Strafe Ändern")
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Importance changer
                    TitledContent("Wichtigkeit") {
                        ImportanceChanger(importance: $fineInputProperties.importance)
                            .frame(width: 258, height: 25)
                    }
                    
                    // Reason
                    TitledContent("Grund") {
                        CustomTextField()
                            .title("Grund")
                            .textBinding($fineInputProperties.reason)
                            .errorMessages($fineInputProperties.reasonErrorMessages)
                            .textFieldSize(width: UIScreen.main.bounds.width * 0.95, height: 50)
                            .onCompletion { fineInputProperties.evaluteReasonError() }
                    }
                    
                    // Amount
                    AmountInput(fineInputProperties: $fineInputProperties)
                    
                    // Date
                    Text("am \(fineInputProperties.date.formattedLong)")
                        .configurate(size: 25)
                        .lineLimit(1)
                        .animation(.none)
                    
                    // Advanced and template button
                    AdvancesTemplateButton(fineInputProperties: $fineInputProperties)
                    
                }.padding(.vertical, 10)
                    .keyboardAdaptiveOffset
            }.padding(.vertical, 10)
                .animation(.default)
            
            Spacer()
            
            VStack(spacing: 5) {
                
                // Delete and confirm button
                DeleteConfirmButton()
                    .deleteConnectionState($fineInputProperties.connectionStateDelete)
                    .confirmConnectionState($fineInputProperties.connectionStateUpdate)
                    .onDeletePress($alertType, value: .deleteButton(action: handleFineDelete))
                    .onConfirmPress($alertType, value: .confirmButton(action: handleFineUpdate)) {
                        fineInputProperties.getFine(old: fine, with: reasonListData.list) != nil
                    }
                    .alert(item: $alertType)
                
                // Error messages
                ErrorMessageView(errorMessages: $fineInputProperties.functionCallErrorMessages)
                
            }.padding(.bottom, fineInputProperties.functionCallErrorMessages == nil ? 50 : 25)
                .animation(.default)
            
        }.setScreenSize
            .onAppear {
                fineInputProperties.setProperties(of: fine, with: reasonListData.list)
            }
    }
    
    /// Handles fine delete
    func handleFineDelete() {
        guard fineInputProperties.connectionStateDelete != .loading,
            fineInputProperties.connectionStateUpdate != .loading,
            let clubId = NewSettings.shared.properties.person?.clubProperties.id else { return }
        fineInputProperties.connectionStateDelete = .loading
        fineInputProperties.resetErrorMessages()
        
        let callItem = ChangeListCall(clubId: clubId, changeType: .delete, changeItem: fine)
        FunctionCaller.shared.call(callItem) { _ in
            fineInputProperties.connectionStateDelete = .passed
            presentationMode.wrappedValue.dismiss()
        } failedHandler: { _ in
            fineInputProperties.connectionStateDelete = .failed
            fineInputProperties.functionCallErrorMessages = .internalErrorDelete
        }
    }
    
    /// Handles fine update
    func handleFineUpdate() {
        guard fineInputProperties.connectionStateDelete != .loading,
            fineInputProperties.connectionStateUpdate != .loading,
            let clubId = NewSettings.shared.properties.person?.clubProperties.id else { return }
        fineInputProperties.connectionStateUpdate = .loading
        fineInputProperties.resetErrorMessages()
        
        guard let updatedFine = fineInputProperties.getFine(old: fine, with: reasonListData.list) else { return }
        let callItem = ChangeListCall(clubId: clubId, changeType: .update, changeItem: updatedFine)
        FunctionCaller.shared.call(callItem) { _ in
            fineInputProperties.connectionStateDelete = .passed
            presentationMode.wrappedValue.dismiss()
        } failedHandler: { _ in
            fineInputProperties.connectionStateUpdate = .failed
            fineInputProperties.functionCallErrorMessages = .internalErrorSave
        }

    }
    
    /// Amount input
    struct AmountInput: View {
        
        /// Properties of inputed fine
        @Binding var fineInputProperties: FineInputProperties
        
        /// Indicated if amount keyboard is on screen
        @State var isAmountKeyboardOnScreen = false
        
        var body: some View {
            TitledContent("Betrag") {
                VStack(spacing: 5) {
                    
                    HStack(spacing: 15) {
                        
                        // Number
                        if fineInputProperties.number != 1 {
                            Text("\(fineInputProperties.number) *")
                                .configurate(size: 25)
                                .lineLimit(1)
                        }
                        
                        // Text Field
                        CustomTextField()
                            .title("Betrag")
                            .textBinding($fineInputProperties.amountString)
                            .keyboardOnScreen($isAmountKeyboardOnScreen)
                            .errorMessages($fineInputProperties.amountErrorMessages)
                            .showErrorMessage(false)
                            .textFieldSize(width: 148)
                            .keyboardType(.decimalPad)
                            .onCompletion { fineInputProperties.evaluteAmount() }

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
                    ErrorMessageView(errorMessages: $fineInputProperties.amountErrorMessages)
                    
                }
            }
        }
    }
    
    /// Advanced and template button
    struct AdvancesTemplateButton: View {
        
        /// Properties of inputed fine
        @Binding var fineInputProperties: FineInputProperties
        
        /// Indicated if advanced sheet is shown
        @State var advancedSheetShowing = false
        
        /// Indicated if template sheet is shown
        @State var templateSheetShowing = false
        
        var body: some View {
            HStack(spacing: 0) {
                Spacer()
                
                // Advanced button
                ZStack {
                    
                    // Outline
                    Outline()
                        .fillColor(Color.custom.lightGreen)
                    
                    // Text
                    Text("Erweitert")
                        .foregroundColor(plain: Color.custom.lightGreen)
                        .font(.text(15))
                        .lineLimit(1)
                    
                }.frame(width: 150, height: 35)
                    .toggleOnTapGesture($advancedSheetShowing)
                    .sheet(isPresented: $advancedSheetShowing) {
                        FineEditorAdvanced(fineInputProperties: $fineInputProperties)
                    }
                
                Spacer()
                
                // Template button
                ZStack {
                    
                    // Outline
                    Outline()
                        .fillColor(Color.custom.yellow)
                    
                    // Text
                    Text("Strafe Auswählen")
                        .foregroundColor(plain: Color.custom.yellow)
                        .font(.text(15))
                        .lineLimit(1)
                    
                }.frame(width: 150, height: 35)
                    .toggleOnTapGesture($templateSheetShowing)
                    .sheet(isPresented: $templateSheetShowing) {
                        FineEditorTemplate { reason in
                            fineInputProperties.setProperties(with: reason)
                        }
                    }
                
                Spacer()
            }
        }
    }
}
