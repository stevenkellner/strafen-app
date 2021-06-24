//
//  ReasonEditor.swift
//  Strafen
//
//  Created by Steven on 18.06.21.
//

import SwiftUI

/// View to edit a reason
struct ReasonEditor: View {

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
        var connectionStateUpdate: ConnectionState = .notStarted

        /// State of data task connection
        var connectionStateDelete: ConnectionState = .notStarted

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

        mutating func setReason(to reason: FirebaseReasonTemplate) {
            self.amount = reason.amount
            self[.amount] = AmountParser.toString(amount)
            self[.reason] = reason.reason
        }
    }

    /// Currently logged in person
    @EnvironmentObject var person: Settings.Person

    /// Environment of the fine list
    @EnvironmentObject var fineListEnvironment: ListEnvironment<FirebaseFine>

    /// Presentation mode
    @Environment(\.presentationMode) private var presentationMode

    /// Reason to edit
    let oldReason: FirebaseReasonTemplate

    init(_ reason: FirebaseReasonTemplate) {
        self.oldReason = reason
    }

    /// Input properties
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
                Header(String(localized: "reason-editor-header-text", comment: "Header of reason editor view."))

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

                VStack(spacing: 5) {

                    // Error message
                    ErrorMessageView($inputProperties.functionCallErrorMessage)

                    // Delete and confirm button
                    SplittedButton.deleteConfirm
                        .leftConnectionState($inputProperties.connectionStateDelete)
                        .rightConnectionState($inputProperties.connectionStateUpdate)
                        .onLeftClick { showDeleteAlert = true }
                        .onRightClick(perform: handleReasonUpdate)

                }.padding(.bottom, 35)
                    .animation(.default)
                    .toast(isPresented: $showDeleteAlert) {
                        DeleteAlert(deleteText: String(localized: "reason-editor-delete-message", comment: "Message of delete reason alert."),
                                    showDeleteAlert: $showDeleteAlert,
                                    deleteHandler: handleReasonDelete)
                    }

            }
        }.maxFrame
            .onAppear {
                inputProperties.setReason(to: oldReason)
            }
    }

    /// Handles reason updating
    func handleReasonUpdate() async {
        await ReasonEditor.handleReasonUpdate(clubId: person.club.id,
                                              reasonId: oldReason.id,
                                              inputProperties: $inputProperties,
                                              presentationMode: presentationMode)
    }

    /// Handles reason delete
    func handleReasonDelete() {
        async {
            await ReasonEditor.handleReasonDelete(clubId: person.club.id,
                                                  reasonId: oldReason.id,
                                                  fineList: fineListEnvironment.list,
                                                  inputProperties: $inputProperties,
                                                  presentationMode: presentationMode)
        }
    }

    /// Handles reason updating
    static func handleReasonUpdate(clubId: Club.ID,
                                   reasonId: FirebaseReasonTemplate.ID,
                                   inputProperties: Binding<InputProperties>,
                                   presentationMode: Binding<PresentationMode>? = nil) async {
        guard inputProperties.wrappedValue.connectionStateDelete != .loading,
              inputProperties.wrappedValue.connectionStateUpdate.restart() == .passed else { return }
        guard inputProperties.wrappedValue.validateAllInputs() == .valid else {
            return inputProperties.wrappedValue.connectionStateUpdate.failed()
        }
        do {
            let callItem = FFChangeListCall(clubId: clubId, item: inputProperties.wrappedValue.reasonTemplate(with: reasonId))
            try await FirebaseFunctionCaller.shared.call(callItem)
            presentationMode?.wrappedValue.dismiss()
            inputProperties.wrappedValue.connectionStateUpdate.passed()
        } catch {
            inputProperties.wrappedValue.functionCallErrorMessage = .internalErrorSave
            inputProperties.wrappedValue.connectionStateUpdate.failed()
        }
    }

    /// Handles reason delete
    static func handleReasonDelete(clubId: Club.ID,
                                   reasonId: FirebaseReasonTemplate.ID,
                                   fineList: [FirebaseFine],
                                   inputProperties: Binding<InputProperties>,
                                   presentationMode: Binding<PresentationMode>? = nil) async {
        guard inputProperties.wrappedValue.connectionStateUpdate != .loading,
              inputProperties.wrappedValue.connectionStateDelete.restart() == .passed else { return }
        inputProperties.wrappedValue.errorMessages = [:]

        guard !fineList.contains(where: { ($0.fineReason as? FineReasonTemplate)?.templateId == reasonId }) else {
            inputProperties.wrappedValue.functionCallErrorMessage = .reasonUndeletable
            return inputProperties.wrappedValue.connectionStateDelete.failed()
        }

        do {
            let callItem = FFChangeListCall<FirebaseReasonTemplate>(clubId: clubId, id: reasonId)
            try await FirebaseFunctionCaller.shared.call(callItem)
            presentationMode?.wrappedValue.dismiss()
            inputProperties.wrappedValue.connectionStateDelete.passed()
        } catch {
            inputProperties.wrappedValue.functionCallErrorMessage = .internalErrorDelete
            return inputProperties.wrappedValue.connectionStateDelete.failed()
        }
    }
}
