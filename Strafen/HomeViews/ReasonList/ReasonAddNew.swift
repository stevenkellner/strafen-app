//
//  ReasonAddNew.swift
//  Strafen
//
//  Created by Steven on 17.06.21.
//

import SwiftUI

/// View to add a new reason
struct ReasonAddNew: View {

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

        /// Error message of function call
        var functionCallErrorMessage: ErrorMessages?

        /// State of data task connection
        var connectionState: ConnectionState = .notStarted

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
                self[.amount] = AmountParser.toString(amount)
                return .valid
            }
            if setErrorMessage { self[error: .amount] = errorMessage }
            self[.amount] = AmountParser.toString(amount)
            return .invalid
        }

        mutating func validateTextField(_ textfield: TextFields, setErrorMessage: Bool) -> ValidationResult {
            switch textfield {
            case .reason: return validateReason(setErrorMessage: setErrorMessage)
            case .amount: return validateAmount(setErrorMessage: setErrorMessage)
            }
        }

        mutating func reasonTemplate(with reasonId: FirebaseReasonTemplate.ID) -> FirebaseReasonTemplate {
            amount = AmountParser.fromString(self[.amount])
            return FirebaseReasonTemplate(id: reasonId, reason: self[.reason], importance: importance, amount: amount)
        }
    }

    /// Currently logged in person
    @EnvironmentObject var person: Settings.Person

    /// Environment of the reason list
    @EnvironmentObject var reasonListEnvironment: ListEnvironment<FirebaseReasonTemplate>

    /// Used to update the environment lists
    @EnvironmentObject var listEnvironmentUpdater: ListEnvironmentUpdater

    /// Presentation mode
    @Environment(\.presentationMode) private var presentationMode

    /// Input properties
    @State var inputProperties = InputProperties()

    /// Indicates whether amount is currently editing
    @State var isAmountEditing = false

    var body: some View {
        ZStack {

            // Background color
            Color.backgroundGray

            VStack(spacing: 0) {

                // Bar to ipe sheet down
                SheetBar()

                // Title
                Header(String(localized: "reason-add-new-header-text", comment: "Header of reason add new view."))

                ScrollView(showsIndicators: false) {
                    ScrollViewReader { proxy in
                        VStack(spacing: 20) {

                            // Importance Changer
                            TitledContent(String(localized: "reason-add-new-importance-title", comment: "Plain text of importance for imporance changer title.")) {
                                ImportanceChanger(importance: $inputProperties.importance)
                                    .frame(width: 258, height: 25)
                            }

                            // Reason
                            TitledContent(String(localized: "reason-add-new-reason-title", comment: "Plain text of reason for text field title.")) {
                                CustomTextField(.reason, inputProperties: $inputProperties)
                                    .placeholder(String(localized: "reason-add-new-reason-placeholder", comment: "Plain text of reason for text field placeholder."))
                                    .defaultTextFieldSize
                                    .scrollViewProxy(proxy)
                            }

                            // Amount
                            VStack(spacing: 5) {
                                TitledContent(String(localized: "reason-add-new-amount-title", comment: "Plain text of amount for text field title.")) {
                                    HStack(spacing: 15) {

                                        // Text Field
                                        CustomTextField(.amount, inputProperties: $inputProperties)
                                            .placeholder(String(localized: "reason-add-new-amount-placeholder", comment: "Plain text of amount for text field placeholder."))
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

                            }.animation(.default, value: isAmountEditing)

                        }.padding(.vertical, 10)
                    }
                }.padding(.vertical, 10)
                    .animation(.default, value: inputProperties.errorMessages)

                Spacer()

                VStack(spacing: 5) {

                    // Error message
                    ErrorMessageView($inputProperties.functionCallErrorMessage)

                    // Cancel and confirm button
                    SplittedButton.cancelConfirm
                        .rightConnectionState($inputProperties.connectionState)
                        .onLeftClick { presentationMode.wrappedValue.dismiss() }
                        .onRightClick(perform: handleReasonSave)

                }.padding(.bottom, 35)
                    .animation(.default, value: inputProperties.functionCallErrorMessage)

            }
        }.maxFrame
    }

    /// Handles reason saving
    func handleReasonSave() async {
        await ReasonAddNew.handleReasonSave(clubId: person.club.id,
                                            inputProperties: $inputProperties,
                                            listUpdater: listEnvironmentUpdater,
                                            presentationMode: presentationMode)
    }

    /// Handles reason saving
    @discardableResult static func handleReasonSave(clubId: Club.ID,
                                                    inputProperties: Binding<InputProperties>,
                                                    listUpdater: ListEnvironmentUpdater? = nil,
                                                    presentationMode: Binding<PresentationMode>? = nil) async -> FirebaseReasonTemplate.ID? {
        guard inputProperties.wrappedValue.connectionState.restart() == .passed else { return nil }
        inputProperties.wrappedValue.functionCallErrorMessage = nil
        guard inputProperties.wrappedValue.validateAllInputs() == .valid else {
            inputProperties.wrappedValue.connectionState.failed()
            return nil
        }
        let reasonId = FirebaseReasonTemplate.ID(rawValue: UUID())
        do {
            let reason = inputProperties.wrappedValue.reasonTemplate(with: reasonId)
            let callItem = FFChangeListCall(clubId: clubId, item: reason)
            try await FirebaseFunctionCaller.shared.call(callItem)
            listUpdater?.updateReason(reason)
            presentationMode?.wrappedValue.dismiss()
            inputProperties.wrappedValue.connectionState.passed()
        } catch {

            inputProperties.wrappedValue.functionCallErrorMessage = .internalErrorSave
            inputProperties.wrappedValue.connectionState.failed()
        }
        return reasonId
    }
}
