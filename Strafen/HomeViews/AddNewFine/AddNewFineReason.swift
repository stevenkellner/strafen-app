//
//  AddNewFineReason.swift
//  Strafen
//
//  Created by Steven on 17.07.20.
//

import SwiftUI

/// View to select reason for new fine
struct AddNewFineReason: View {
    
    /// Fine Reason input properties
    struct FineReasonInputProperties {
        
        /// Input importance
        var importance: Importance = .medium
        
        /// Input reason
        var reason = ""
        
        /// Input amount
        var amount: Amount = .zero
        
        /// Input amount string
        var amountString = Amount.zero.stringValue
        
        /// Id of selected template
        var templateId: ReasonTemplate.ID?
        
        /// Type of reason textfield error
        var reasonErrorMessages: ErrorMessages? = nil
        
        /// Type of amount textfield error
        var amountErrorMessages: ErrorMessages? = nil
        
        /// Set properties of given fine reason
        mutating func setProperties(of fineReason: NewFineReason?, reasonList: [ReasonTemplate]?) {
            templateId = (fineReason as? NewFineReasonTemplate)?.templateId
            guard let complete = fineReason?.complete(with: reasonList) else { return }
            importance = complete.importance
            reason = complete.reason
            amount = complete.amount
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
        @discardableResult mutating func evaluteAmountError() -> Bool {
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
            evaluteReasonError() |!|
                evaluteAmountError()
        }
    }
    
    /// Old fine reason
    let oldFineReason: NewFineReason?
    
    /// Handles reason selection
    let completionHandler: (NewFineReason) -> Void
    
    init(with fineReason: NewFineReason?, completion completionHandler: @escaping (NewFineReason) -> Void) {
        self.oldFineReason = fineReason
        self.completionHandler = completionHandler
    }
    
    /// Fine reason input properties
    @State var fineReasonInputProperties = FineReasonInputProperties()
    
    /// Reason List Data
    @ObservedObject var reasonListData = NewListData.reason
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Bar to wipe sheet down
            SheetBar()
            
            // Header
            Header("Strafe Auswählen")
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Importance changer
                    TitledContent("Wichtigkeit") {
                        ImportanceChanger(importance: $fineReasonInputProperties.importance)
                            .frame(width: 258, height: 25)
                    }
                    
                    // Reason
                    TitledContent("Grund") {
                        CustomTextField()
                            .title("Grund")
                            .textBinding($fineReasonInputProperties.reason)
                            .errorMessages($fineReasonInputProperties.reasonErrorMessages)
                            .textFieldSize(width: UIScreen.main.bounds.width * 0.95, height: 50)
                            .onCompletion { fineReasonInputProperties.evaluteReasonError() }
                    }
                    
                    // Amount
                    AmountInput(fineReasonInputProperties: $fineReasonInputProperties)

                    // Template button
                    TemplateButton(fineReasonInputProperties: $fineReasonInputProperties)
                        .padding(.top, 10)
                    
                }.padding(.vertical, 10)
                    .keyboardAdaptiveOffset
            }.padding(.vertical, 10)
                .animation(.default)
            
            Spacer()
            
            // Cancel and Confirm button
            CancelConfirmButton()
                .onCancelPress { presentationMode.wrappedValue.dismiss() }
                .onConfirmPress {
                    guard !fineReasonInputProperties.errorOccurred() else { return }
                    var fineReason: NewFineReason = NewFineReasonCustom(reason: fineReasonInputProperties.reason, amount: fineReasonInputProperties.amount, importance: fineReasonInputProperties.importance)
                    if let templateId = fineReasonInputProperties.templateId {
                        let fineReasonTemplate = NewFineReasonTemplate(templateId: templateId)
                        let complete = fineReasonTemplate.complete(with: reasonListData.list)
                        if fineReason as? NewFineReasonCustom == complete {
                            fineReason = fineReasonTemplate
                        }
                    }
                    completionHandler(fineReason)
                    presentationMode.wrappedValue.dismiss()
                }
                .padding(.bottom, 50)
                    
        }.setScreenSize
            .onAppear {
                fineReasonInputProperties.setProperties(of: oldFineReason, reasonList: reasonListData.list)
            }
    }
    
    /// Amount input
    struct AmountInput: View {
        
        /// Properties of inputed fine
        @Binding var fineReasonInputProperties: FineReasonInputProperties
        
        /// Indicated if amount keyboard is on screen
        @State var isAmountKeyboardOnScreen = false
        
        var body: some View {
            TitledContent("Betrag") {
                VStack(spacing: 5) {
                    
                    HStack(spacing: 15) {
                        
                        // Text Field
                        CustomTextField()
                            .title("Betrag")
                            .textBinding($fineReasonInputProperties.amountString)
                            .keyboardOnScreen($isAmountKeyboardOnScreen)
                            .errorMessages($fineReasonInputProperties.amountErrorMessages)
                            .showErrorMessage(false)
                            .textFieldSize(width: 148)
                            .keyboardType(.decimalPad)
                            .onCompletion { fineReasonInputProperties.evaluteAmountError() }

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
                    ErrorMessageView(errorMessages: $fineReasonInputProperties.amountErrorMessages)
                    
                }
            }
        }
    }
    
    /// Template button
    struct TemplateButton: View {
        
        /// Properties of inputed fine reason
        @Binding var fineReasonInputProperties: FineReasonInputProperties
        
        /// Reason List Data
        @ObservedObject var reasonListData = NewListData.reason
        
        /// Indicated if template sheet is shown
        @State var templateSheetShowing = false
        
        var body: some View {
            HStack(spacing: 0) {
                Spacer()
                
                Text("Bevorzugt:")
                    .configurate(size: 20)
                    .lineLimit(1)
                    .padding(.trailing, 15)
                    .frame(height: 35)
                
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
                    .padding(.trailing, 15)
                    .toggleOnTapGesture($templateSheetShowing)
                    .sheet(isPresented: $templateSheetShowing) {
                        FineEditorTemplate { reason in
                            let fineReason = NewFineReasonTemplate(templateId: reason.id)
                            fineReasonInputProperties.setProperties(of: fineReason, reasonList: reasonListData.list)
                            fineReasonInputProperties.evaluteReasonError()
                            fineReasonInputProperties.evaluteAmountError()
                        }
                    }
            }
        }
    }
}
