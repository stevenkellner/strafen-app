//
//  AddNewFineCustomReason.swift
//  Strafen
//
//  Created by Steven on 20.06.21.
//

import SwiftUI

/// View to select reason for new fine
struct AddNewFineCustomReason: View {

    /// Properties of inputed reason
    struct InputProperties: InputPropertiesProtocol {

        /// All textfields
        enum TextFields: Int, TextFieldsProtocol {
            case reason, amount
        }

        var inputProperties = [TextFields: String]()

        var errorMessages = [TextFields: ErrorMessages]()

        var firstResponders = TextFieldFirstResponders<TextFields>()

        /// Input amount
        var amount: Amount = .zero

        /// Input importance
        var importance: Importance = .medium

        /// Validates the reason input and sets associated error messages
        /// - Parameter setErrorMessage: Indicates whether error message will be set
        /// - Returns: result of this validation
        private mutating func validateReason(setErrorMessage: Bool = true) -> ValidationResult {
            var errorMessage: ErrorMessages?
            if self[.reason].isEmpty {
                errorMessage = .emptyField
            } else {
                if setErrorMessage { self[error: .reason] = nil }
                return .valid
            }
            if setErrorMessage { self[error: .reason] = errorMessage }
            return .invalid
        }

        /// Validates the amount input and sets associated error messages
        /// - Parameter setErrorMessage: Indicates whether error message will be set
        /// - Returns: result of this validation
        private mutating func validateAmount(setErrorMessage: Bool = true) -> ValidationResult {
            amount = AmountParser.fromString(self[.amount])
            var errorMessage: ErrorMessages?
            if self[.amount].isEmpty {
                errorMessage = .emptyField
            } else if amount == .zero {
                errorMessage = .amountZero
            } else {
                if setErrorMessage { self[error: .amount] = nil }
                self[.amount] = amount.stringValue
                return .valid
            }
            if setErrorMessage { self[error: .amount] = errorMessage }
            self[.amount] = amount.stringValue
            return .invalid
        }

        mutating func validateTextField(_ textfield: TextFields, setErrorMessage: Bool) -> ValidationResult {
            switch textfield {
            case .reason: return validateReason(setErrorMessage: setErrorMessage)
            case .amount: return validateAmount(setErrorMessage: setErrorMessage)
            }
        }

        /// Sets properties of fine reason
        mutating func setProperties(of fineReason: FineReason?, reasonList: [FirebaseReasonTemplate]) {
            guard let fineReason = fineReason else { return }
            self[.reason] = fineReason.reason(with: reasonList)
            self.amount = fineReason.amount(with: reasonList)
            self[.amount] = amount.stringValue
            self.importance = fineReason.importance(with: reasonList)
        }
    }

    /// Environment of the reason list
    @EnvironmentObject var reasonListEnvironment: ListEnvironment<FirebaseReasonTemplate>

    /// Presentation mode
    @Environment(\.presentationMode) private var presentationMode

    /// Old fine reason
    @Binding var fineReason: FineReason?

    /// Handles reason selection
    let completionHandler: () -> Void

    init(with fineReason: Binding<FineReason?>, completion completionHandler: @escaping () -> Void) {
        self._fineReason = fineReason
        self.completionHandler = completionHandler
    }

    /// Fine reason input properties
    @State var inputProperties = InputProperties()

    /// Indicates whether amount is currently editing
    @State var isAmountEditing = false

    var body: some View {
        ZStack {

            // Background color
            Color.backgroundGray

            VStack(spacing: 0) {

                // Bar to wipe sheet down
                SheetBar()

                // Header
                Header(String(localized: "add-new-fine-reason-header-text", comment: "Header of add new fine reason view."))

                ScrollView(showsIndicators: false) {
                    ScrollViewReader { proxy in
                        VStack(spacing: 20) {

                            // Importance Changer
                            TitledContent(String(localized: "reason-editor-importance-title", comment: "Plain text of importance for imporance changer title.")) {
                                ImportanceChanger(importance: $inputProperties.importance)
                                    .frame(width: 258, height: 25)
                            }

                            // Reason
                            TitledContent(String(localized: "reason-editor-reason-title", comment: "Plain text of reason for text field title.")) {
                                CustomTextField(.reason, inputProperties: $inputProperties)
                                    .placeholder(String(localized: "reason-editor-reason-placeholder", comment: "Plain text of reason for text field placeholder."))
                                    .defaultTextFieldSize
                                    .scrollViewProxy(proxy)
                            }

                            // Amount
                            VStack(spacing: 5) {
                                TitledContent(String(localized: "reason-editor-amount-title", comment: "Plain text of amount for text field title.")) {
                                    HStack(spacing: 15) {

                                        // Text Field
                                        CustomTextField(.amount, inputProperties: $inputProperties)
                                            .placeholder(String(localized: "reason-editor-amount-placeholder", comment: "Plain text of amount for text field placeholder."))
                                            .textFieldSize(width: 148, height: 50)
                                            .scrollViewProxy(proxy)
                                            .keyboardType(.decimalPad)
                                            .hideErrorMessage
                                            .onFocus { isAmountEditing = true }
                                            .onCompletion { isAmountEditing = false }

                                        // Currency sign
                                        Text(verbatim: Amount.locale.currencySymbol ?? "?")
                                            .foregroundColor(.textColor)
                                            .font(.system(size: 25, weight: .thin))
                                            .lineLimit(1)

                                        // Done button
                                        if isAmountEditing {
                                            Text("done-button-text", comment: "Text of done button.")
                                                .foregroundColor(.customGreen)
                                                .font(.system(size: 25, weight: .thin))
                                                .lineLimit(1)
                                                .onTapGesture { UIApplication.shared.dismissKeyboard() }
                                        }

                                    }.frame(height: 50)
                                }

                                // Error message
                                ErrorMessageView($inputProperties[error: .amount])

                            }.animation(.default)

                        }.padding(.vertical, 10)
                    }
                }.padding(.vertical, 10)
                    .animation(.default)

                Spacer()

                // Cancel and Confirm button
                SplittedButton.cancelConfirm
                    .onLeftClick {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .onRightClick {
                        guard inputProperties.validateAllInputs() == .valid else { return }
                        inputProperties.amount = AmountParser.fromString(inputProperties[.amount])
                        fineReason = FineReasonCustom(reason: inputProperties[.reason], amount: inputProperties.amount, importance: inputProperties.importance)
                        presentationMode.wrappedValue.dismiss()
                        completionHandler()
                    }
                    .padding(.bottom, 35)

            }
        }.maxFrame
            .onAppear {
                inputProperties.setProperties(of: fineReason, reasonList: reasonListEnvironment.list)
            }
    }
}
