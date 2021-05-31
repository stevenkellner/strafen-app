//
//  FineEditor.swift
//  Strafen
//
//  Created by Steven on 30.05.21.
//

import SwiftUI
import ToastUI

/// View to edit a  fine
struct FineEditor: View {

    /// Properties of inputed fine
    struct InputProperties: InputPropertiesProtocol {

        /// All textfields
        enum TextFields: Int, TextFieldsProtocol {
            case reason, amount
        }

        var inputProperties = [TextFields: String]()

        var errorMessages = [TextFields: ErrorMessages]()

        var firstResponders = TextFieldFirstResponders<TextFields>()

        /// Old fine
        var oldFine: FirebaseFine?

        /// Input importance
        var importance: Importance = .medium

        /// Input number
        var number = 1

        /// Input amount
        var amount: Amount = .zero

        /// Input date
        var date = Date()

        /// Error message of number
        var numberErrorMessages: ErrorMessages?

        /// Error message of date
        var dateErrorMessages: ErrorMessages?

        /// Error message of function call
        var functionCallErrorMessage: ErrorMessages?

        /// State of data task connection
        var connectionStateDelete: ConnectionState = .notStarted

        /// State of data task connection
        var connectionStateUpdate: ConnectionState = .notStarted

        /// Set properties of given fine
        mutating func setProperties(of fine: FirebaseFine, with reasonList: [FirebaseReasonTemplate]) {
            oldFine = fine
            importance = fine.importance(with: reasonList)
            self[.reason] = fine.reason(with: reasonList)
            amount = fine.amount(with: reasonList)
            self[.amount] = amount.stringValue
            number = fine.number
            date = fine.date
        }

        /// Get updated fine
        mutating func updatedFine(with reasonList: [FirebaseReasonTemplate]) -> FirebaseFine? {
            guard let oldFine = oldFine else { return nil }
            amount = AmountParser.fromString(self[.amount])
            var fineReason: FineReason = FineReasonCustom(reason: self[.reason], amount: amount, importance: importance)
            if let fineReasonTemplate = oldFine.fineReason as? FineReasonTemplate {
                if fineReason.reason(with: reasonList) == fineReasonTemplate.reason(with: reasonList),
                   fineReason.amount(with: reasonList) == fineReasonTemplate.amount(with: reasonList),
                   fineReason.importance(with: reasonList) == fineReasonTemplate.importance(with: reasonList) {
                    fineReason = fineReasonTemplate
                }
            }
            return FirebaseFine(id: oldFine.id, assoiatedPersonId: oldFine.assoiatedPersonId, date: date, payed: oldFine.payed, number: number, fineReason: fineReason)
        }

        /// Indicates whether updated fine is inequal to old fine
        mutating func hasFineChanged(with reasonList: [FirebaseReasonTemplate]) -> Bool {
            guard let oldFine = oldFine else { return false }
            return updatedFine(with: reasonList) != oldFine
        }

        /// Validates the date input and sets associated error messages
        /// - Returns: result of this validation
        private mutating func validateDate() -> ValidationResult {
            if date > Date() {
                dateErrorMessages = .futureDate
            } else {
                dateErrorMessages = nil
                return .valid
            }
            return .invalid
        }

        /// Validates the numver input and sets associated error messages
        /// - Returns: result of this validation
        private mutating func validateNumber() -> ValidationResult {
            if !(1...99).contains(number) {
                numberErrorMessages = .invalidNumberRange
            } else {
                numberErrorMessages = nil
                return .valid
            }
            return .invalid
        }

        /// Validates the reason input and sets associated error messages
        /// - Parameter setErrorMessage: Indicates whether error message will be set
        /// - Returns: result of this validation
        private mutating func validateReason(setErrorMessage: Bool = true) -> ValidationResult {
            var errorMessage: ErrorMessages?
            if self[.reason].isEmpty {
                errorMessage = .emptyField(code: 10)
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
                errorMessage = .emptyField(code: 11)
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

        /// Validates all input and sets associated error messages
        /// - Returns: result of this validation
        public mutating func validateAllInputs() -> ValidationResult {
            [TextFields.allCases.validateAll { textField in
                validateTextField(textField)
            }, validateDate(), validateNumber()].validateAll
        }

        /// Set all error messages to nil
        public mutating func resetErrorMessages() {
            errorMessages = [:]
            dateErrorMessages = nil
            numberErrorMessages = nil
            functionCallErrorMessage = nil
        }
    }

    /// Presentation mode
    @Environment(\.presentationMode) private var presentationMode

    /// Environment of the reason list
    @EnvironmentObject var reasonListEnvironment: ListEnvironment<FirebaseReasonTemplate>

    /// Currently logged in person
    @EnvironmentObject var person: Settings.Person

    /// Fine to edit
    let fine: FirebaseFine

    /// Properties of inputed fine
    @State var inputProperties = InputProperties()

    /// Indicates whether amount is currently editing
    @State var isAmountEditing = false

    /// Indicates whether delete alert is currently shown
    @State var showDeleteAlert = false

    var body: some View {
        ZStack {

            // Background color
            Color.backgroundGray

            VStack(spacing: 0) {

                // Bar to ipe sheet down
                SheetBar()

                // Title
                Header("fine-editor-header-text", table: .profileDetail, comment: "Fine editor header text")

                ScrollView(showsIndicators: false) {
                    ScrollViewReader { proxy in
                        VStack(spacing: 20) {

                            // Importance Changer
                            TitledContent("fine-editor-importance-title", table: .profileDetail, comment: "Fine editor importance title") {
                                ImportanceChanger(importance: $inputProperties.importance)
                                    .frame(width: 258, height: 25)
                            }

                            // Reason
                            TitledContent("fine-editor-reason-text", table: .profileDetail, comment: "Fine editor reason text") {
                                CustomTextField(.reason, inputProperties: $inputProperties)
                                    .placeholder("fine-editor-reason-text", table: .profileDetail, comment: "Fine editor reason text")
                                    .defaultTextFieldSize
                                    .scrollViewProxy(proxy)
                            }

                            // Amount
                            VStack(spacing: 5) {
                                TitledContent("fine-editor-amount-text", table: .profileDetail, comment: "Fine editor amount text") {
                                    HStack(spacing: 15) {

                                        // Number
                                        if inputProperties.number != 1 {
                                            Text("\(inputProperties.number) *")
                                                .foregroundColor(.textColor)
                                                .font(.system(size: 30, weight: .light))
                                                .lineLimit(1)
                                        }

                                        // Text Field
                                        CustomTextField(.amount, inputProperties: $inputProperties)
                                            .placeholder(NSLocalizedString("fine-editor-amount-text", table: .profileDetail, comment: "Fine editor amount text"))
                                            .textFieldSize(width: 148, height: 50)
                                            .scrollViewProxy(proxy)
                                            .keyboardType(.decimalPad)
                                            .hideErrorMessage
                                            .onFocus { isAmountEditing = true }
                                            .onCompletion { isAmountEditing = false }

                                        // Currency sign
                                        Text(Amount.locale.currencySymbol ?? "?")
                                            .foregroundColor(.textColor)
                                            .font(.system(size: 25, weight: .thin))
                                            .lineLimit(1)

                                        // Done button
                                        if isAmountEditing {
                                            Text("done-button-text", table: .otherTexts, comment: "Text for done button")
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

                            // Number
                            VStack(spacing: 5) {
                                TitledContent("fine-editor-number-text", table: .profileDetail, comment: "Fine editor number text") {
                                    SingleOutlinedContent {
                                        HStack(spacing: 0) {
                                            Spacer()

                                            // Left outline
                                            Text("\(NSLocalizedString("fine-editor-number-text", table: .profileDetail, comment: "Fine editor number text")):")
                                                .foregroundColor(.textColor)
                                                .font(.system(size: 20, weight: .thin))
                                                .lineLimit(1)
                                                .padding(.horizontal, 15)

                                            Spacer()

                                            // Right outline
                                            Stepper("", value: $inputProperties.number, in: 1...99)
                                                .labelsHidden()
                                                .padding(.trailing, 15)

                                            Spacer()
                                        }
                                    }.strokeColor(inputProperties.numberErrorMessages.map { _ in .customRed})
                                        .lineWidth(inputProperties.numberErrorMessages.map { _ in 2 })
                                }.contentFrame(width: UIScreen.main.bounds.width * 0.95, height: 50)

                                // Error Messages
                                ErrorMessageView($inputProperties.numberErrorMessages)

                            }.animation(.default)

                            // Date
                            DateChanger(date: $inputProperties.date, errorMessage: $inputProperties.dateErrorMessages)

                        }.padding(.vertical, 10)
                    }
                }.padding(.vertical, 10)
                    .animation(.default)

                Spacer()

                VStack(spacing: 5) {

                    // Error message
                    ErrorMessageView($inputProperties.functionCallErrorMessage)

                    // Delete and confirm button
                    SplittedButton.deleteConfirm
                        .leftConnectionState($inputProperties.connectionStateDelete)
                        .rightConnectionState($inputProperties.connectionStateUpdate)
                        .onLeftClick { showDeleteAlert = true }
                        .onRightClick(perform: handleFineUpdate)

                }.padding(.bottom, 35)
                    .animation(.default)
                    .toast(isPresented: $showDeleteAlert) {
                        DeleteAlert(deleteText: NSLocalizedString("fine-editor-delete-message", table: .profileDetail, comment: "Fine editor delete message"),
                                    showDeleteAlert: $showDeleteAlert,
                                    deleteHandler: handleFineDelete)
                    }
            }

        }.maxFrame
            .onAppear {
                inputProperties.setProperties(of: fine, with: reasonListEnvironment.list)
            }
    }

    /// Handles fine delete
    func handleFineDelete() {
        guard person.isCashier else { return }
        guard inputProperties.connectionStateUpdate != .loading,
              inputProperties.connectionStateDelete.restart() == .passed else { return }
        inputProperties.resetErrorMessages()

        let callItem = FFChangeListCall<FirebaseFine>(clubId: person.club.id, id: fine.id)
        FirebaseFunctionCaller.shared.call(callItem).then { _ in
            presentationMode.wrappedValue.dismiss()
            inputProperties.connectionStateDelete.passed()
        }.catch { _ in
            inputProperties.functionCallErrorMessage = .internalErrorDelete(code: 1)
            inputProperties.connectionStateDelete.failed()
        }
    }

    /// Handles fine update
    func handleFineUpdate() {
        guard person.isCashier else { return }
        guard inputProperties.connectionStateDelete != .loading,
              inputProperties.connectionStateUpdate.restart() == .passed else { return }
        inputProperties.functionCallErrorMessage = nil
        guard inputProperties.validateAllInputs() == .valid else {
            return inputProperties.connectionStateUpdate.failed()
        }
        guard inputProperties.hasFineChanged(with: reasonListEnvironment.list) else {
            return presentationMode.wrappedValue.dismiss()
        }

        guard let updatedFine = inputProperties.updatedFine(with: reasonListEnvironment.list) else {
            return presentationMode.wrappedValue.dismiss()
        }
        let callItem = FFChangeListCall(clubId: person.club.id, item: updatedFine)
        FirebaseFunctionCaller.shared.call(callItem).then { _ in
            presentationMode.wrappedValue.dismiss()
            inputProperties.connectionStateUpdate.passed()
        }.catch { _ in
            inputProperties.functionCallErrorMessage = .internalErrorSave(code: 3)
            inputProperties.connectionStateUpdate.failed()
        }
    }
}
