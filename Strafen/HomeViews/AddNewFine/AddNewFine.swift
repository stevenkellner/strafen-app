//
//  AddNewFine.swift
//  Strafen
//
//  Created by Steven on 19.06.21.
//

import SwiftUI

struct AddNewFine: View {

    /// Properties for fine input
    struct InputProperties {

        /// Ids of associated persons
        var personIds = [FirebasePerson.ID]()

        /// Fine Reason
        var fineReason: FineReason?

        /// Input date
        var date = Date()

        /// Input number
        var number = 1

        /// Error message of person id
        var personIdErrorMessage: ErrorMessages?

        /// Error message of fine reason
        var fineReasonErrorMessage: ErrorMessages?

        /// Error message of date
        var dateErrorMessage: ErrorMessages?

        /// Error message of number
        var numberErrorMessage: ErrorMessages?

        /// Error message of function call
        var functionCallErrorMessage: ErrorMessages?

        /// State of data task connection
        var connectionState: ConnectionState = .passed

        /// Validates the person id input and sets associated error messages
        /// - Returns: result of this validation
        private mutating func validatePersonId() -> ValidationResult {
            if personIds.isEmpty {
                personIdErrorMessage = .noPersonSelected
            } else {
                personIdErrorMessage = nil
                return .valid
            }
            return .invalid
        }

        /// Validates the fine reason input and sets associated error messages
        /// - Returns: result of this validation
        private mutating func validateFineReason() -> ValidationResult {
            if fineReason == nil {
                fineReasonErrorMessage = .noReasonGiven
            } else {
                fineReasonErrorMessage = nil
                return .valid
            }
            return .invalid
        }

        /// Validates the date input and sets associated error messages
        /// - Returns: result of this validation
        private mutating func validateDate() -> ValidationResult {
            if date > Date() {
                dateErrorMessage = .futureDate
            } else {
                dateErrorMessage = nil
                return .valid
            }
            return .invalid
        }

        /// Validates the number input and sets associated error messages
        /// - Returns: result of this validation
        private mutating func validateNumber() -> ValidationResult {
            if !(1...99).contains(number) {
                numberErrorMessage = .invalidNumberRange
            } else {
                numberErrorMessage = nil
                return .valid
            }
            return .invalid
        }

        /// Validates all input and sets associated error messages
        /// - Returns: result of this validation
        public mutating func validateAllInputs() -> ValidationResult {
            .evaluate {
                validatePersonId()
                validateFineReason()
                validateDate()
                validateNumber()
            }
        }

        /// Appends person id
        public mutating func appendPersonId(_ personId: FirebasePerson.ID?) {
            guard let personId = personId else { return }
            self.personIds.append(personId)
        }

        /// Reset all properties
        public mutating func resetProperties() {
            self.personIds = []
            self.fineReason = nil
            self.date = Date()
            self.number = 1
        }

        public func fine(with fineId: FirebaseFine.ID, personId: FirebasePerson.ID) -> FirebaseFine? {
            guard let fineReason = fineReason else { return nil }
            return FirebaseFine(id: fineId, assoiatedPersonId: personId, date: date, payed: .unpayed, number: number, fineReason: fineReason)
        }
    }

    /// Presentation mode
    @Environment(\.presentationMode) private var presentationMode

    /// Currently logged in person
    @EnvironmentObject var person: Settings.Person

    /// Active home tab
    @EnvironmentObject var homeTab: HomeTab

    /// Person id of refered person detail
    let oldPersonId: FirebasePerson.ID?

    /// Indicates whether this view is a sheet
    let isSheet: Bool

    /// Init with person id
    init(with personId: FirebasePerson.ID? = nil, isSheet: Bool) {
        self.oldPersonId = personId
        self.isSheet = isSheet
    }

    /// Input properties
    @State var inputProperties = InputProperties()

    var body: some View {
        ZStack {

            // Background color
            Color.backgroundGray

            VStack(spacing: 0) {

                // Bar to wipe sheet down
                if isSheet {
                    SheetBar()
                }

                // Title
                Header(String(localized: "add-new-fine-header-text", comment: "Header of add new fine view."))
                    .padding(.top, isSheet ? 0 : 50)

                ScrollView(showsIndicators: false) {
                    ScrollViewReader { _ in
                        VStack(spacing: 20) {

                            // Person input
                            PersonInput(inputProperties: $inputProperties)

                            // Reason input
                            FineReasonInput(inputProperties: $inputProperties)

                            // Date input
                            DateChanger(date: $inputProperties.date, errorMessage: $inputProperties.dateErrorMessage)

                            // Number input
                            NumberInput(inputProperties: $inputProperties)

                        }.padding(.vertical, 10)
                    }
                }.padding(.top, 10)

                Spacer()

                VStack(spacing: 5) {

                    // Error message
                    ErrorMessageView($inputProperties.functionCallErrorMessage)

                    // Cancel and Confirm button
                    if isSheet {
                        SplittedButton.cancelConfirm
                            .rightConnectionState($inputProperties.connectionState)
                            .onLeftClick {
                                inputProperties.resetProperties()
                                homeTab.active = .personList
                                presentationMode.wrappedValue.dismiss()
                            }
                            .onRightClick(perform: handleFinesSave)
                    } else {
                        SingleButton.confirm
                            .connectionState($inputProperties.connectionState)
                            .onClick(perform: handleFinesSave)
                    }

                }.padding(.bottom, isSheet ? 35 : 20)
            }
        }.maxFrame
            .onAppear {
                inputProperties.appendPersonId(oldPersonId)
            }
    }

    /// Handles fine save
    func handleFinesSave() async {
        await AddNewFine.handleFinesSave(clubId: person.club.id,
                                        inputProperties: $inputProperties,
                                        homeTab: $homeTab,
                                        presentationMode: presentationMode)
    }

    /// Handles fine save
    @discardableResult static func handleFinesSave(clubId: Club.ID,
                                                   inputProperties: Binding<InputProperties>,
                                                   homeTab: EnvironmentObject<HomeTab>.Wrapper? = nil,
                                                   presentationMode: Binding<PresentationMode>? = nil) async -> [FirebaseFine.ID]? {
        guard inputProperties.wrappedValue.connectionState.restart() == .passed else { return nil }
        inputProperties.wrappedValue.functionCallErrorMessage = nil
        guard inputProperties.wrappedValue.validateAllInputs() == .valid else {
            inputProperties.wrappedValue.connectionState.failed()
            return nil
        }

        let fineIds = await withTaskGroup(of: FirebaseFine.ID?.self, returning: [FirebaseFine.ID]?.self) { group in
            for personId in inputProperties.wrappedValue.personIds {
                group.async {
                    do {
                        let fineId = FirebaseFine.ID(rawValue: UUID())
                        guard let fine = inputProperties.wrappedValue.fine(with: fineId, personId: personId) else { return nil }
                        let callItem = FFChangeListCall(clubId: clubId, item: fine)
                        try await FirebaseFunctionCaller.shared.call(callItem)
                        inputProperties.wrappedValue.personIds.removeAll { $0 == personId }
                        return fineId
                    } catch { return nil }
                }
            }
            return await group.reduce(into: []) { result, fineId in
                guard let fineId = fineId else { return result = nil }
                result?.append(fineId)
            }
        }

        guard let fineIds = fineIds else {
            inputProperties.wrappedValue.functionCallErrorMessage = .internalErrorSave
            inputProperties.wrappedValue.connectionState.failed()
            return nil
        }

        inputProperties.wrappedValue.resetProperties()
        homeTab?.active.wrappedValue = .personList
        inputProperties.wrappedValue.connectionState.passed()
        presentationMode?.wrappedValue.dismiss()
        return fineIds
    }

    /// Person input
    struct PersonInput: View {

        /// Environment of the person list
        @EnvironmentObject var personListEnvironment: ListEnvironment<FirebasePerson>

        /// Input properties
        @Binding var inputProperties: InputProperties

        /// Indicates if person selector sheet is shown
        @State var showPersonSelectorSheet = false

        var body: some View {
            VStack(spacing: 5) {
                TitledContent(String(localized: "add-new-fine-person-title", comment: "Plain text of person id for text field title.")) {
                    SingleOutlinedContent {
                        if let firstPersonId = inputProperties.personIds.first {
                            HStack(spacing: 0) {
                                if inputProperties.personIds.count != 1 { Spacer() }
                                Text(personListEnvironment.list.first { $0.id == firstPersonId }?.name.formatted ?? String(localized: "add-new-fine-unknown-person-name", comment: "Name of person if no name is given."))
                                    .foregroundColor(.textColor)
                                    .font(.system(size: 20, weight: .thin))
                                    .lineLimit(1)
                                    .padding(.horizontal, 15)
                                if inputProperties.personIds.count != 1 {
                                    Spacer()
                                    VStack(spacing: 0) {
                                        Spacer()
                                        Text("add-new-fine-and-more-\(inputProperties.personIds.count - 1)", comment: "And number persons more text.")
                                            .foregroundColor(.textColor)
                                            .font(.system(size: 15, weight: .thin))
                                            .lineLimit(2)
                                            .multilineTextAlignment(.leading)
                                            .padding([.trailing, .bottom], 10)
                                    }
                                }
                            }
                        } else {
                            Text("add-new-fine-select-persons-text", comment: "Placeholder text to select persons.")
                                .foregroundColor(.textColor)
                                .font(.system(size: 20, weight: .thin))
                                .lineLimit(1)
                                .padding(.horizontal, 15)
                                .opacity(0.5)
                        }
                    }.strokeColor(inputProperties.personIdErrorMessage.map { _ in .customRed })
                        .lineWidth(inputProperties.personIdErrorMessage.map { _ in 2 })
                        .frame(width: UIScreen.main.bounds.width * 0.95, height: 55)
                        .toggleOnTapGesture($showPersonSelectorSheet)
                }

                // Error Messages
                ErrorMessageView($inputProperties.personIdErrorMessage)

            }.animation(.default, value: inputProperties.personIdErrorMessage)
                .sheet(isPresented: $showPersonSelectorSheet) {
                    AddNewFinePerson(personIds: $inputProperties.personIds)
                }
        }
    }

    /// Fine reason input
    struct FineReasonInput: View {

        /// Environment of the reason list
        @EnvironmentObject var reasonListEnvironment: ListEnvironment<FirebaseReasonTemplate>

        /// Input properties
        @Binding var inputProperties: InputProperties

        /// Indicates if reason selector sheet is shown
        @State var showReasonSelectorSheet = false

        var body: some View {
            VStack(spacing: 5) {
                TitledContent(String(localized: "add-new-fine-reason-title", comment: "Plain text of reason for text field title.")) {
                    SplittedOutlinedContent {

                        // Left content
                        Text(inputProperties.fineReason?.reason(with: reasonListEnvironment.list) ?? String(localized: "add-new-fine-select-reason-text", comment: "Placeholder text to select reason."))
                            .foregroundColor(.textColor)
                            .font(.system(size: 20, weight: .thin))
                            .lineLimit(1)
                            .padding(.horizontal, 10)
                            .opacity(inputProperties.fineReason == nil ? 0.5 : 1)

                    } rightContent: {

                        // Right content
                        Text(describing: inputProperties.fineReason?.amount(with: reasonListEnvironment.list) ?? .zero)
                            .foregroundColor(inputProperties.fineReason?.importance(with: reasonListEnvironment.list).color ?? .customGreen)
                            .font(.system(size: 20, weight: .thin))
                            .lineLimit(1)

                    }.leftWidthPercentage(0.7)
                        .leftStrokeColor(inputProperties.fineReasonErrorMessage.map { _ in .customRed })
                        .rightStrokeColor(inputProperties.fineReasonErrorMessage.map { _ in .customRed })
                        .leftLineWidth(inputProperties.fineReasonErrorMessage.map { _ in 2 })
                        .rightLineWidth(inputProperties.fineReasonErrorMessage.map { _ in 2 })
                        .frame(width: UIScreen.main.bounds.width * 0.95, height: 55)
                        .toggleOnTapGesture($showReasonSelectorSheet)
                }

                // Error Messages
                ErrorMessageView($inputProperties.fineReasonErrorMessage)

            }.animation(.default, value: inputProperties.fineReasonErrorMessage)
                .sheet(isPresented: $showReasonSelectorSheet) {
                    AddNewFineReason(fineReason: $inputProperties.fineReason)
                }
        }
    }

    /// Number input
    struct NumberInput: View {

        /// Input properties
        @Binding var inputProperties: InputProperties

        var body: some View {
            VStack(spacing: 5) {
                TitledContent(String(localized: "add-new-fine-number-title", comment: "Plain text of number for text field title.")) {
                    SingleOutlinedContent {
                        HStack(spacing: 0) {
                            Spacer()

                            // Left outline
                            Text(verbatim: "\(String(localized: "add-new-fine-number-placeholder", comment: "Plain text of number for text field placeholder.")):")
                                .foregroundColor(.textColor)
                                .font(.system(size: 20, weight: .thin))
                                .lineLimit(1)
                                .padding(.horizontal, 10)

                            Spacer()

                            // Number
                            Text("\(inputProperties.number)")
                                .foregroundColor(.textColor)
                                .font(.system(size: 20, weight: .thin))
                                .lineLimit(1)
                                .padding(.horizontal, 10)

                            Spacer()

                            // Right outline
                            Stepper("", value: $inputProperties.number, in: 1...99)
                                .labelsHidden()
                                .padding(.trailing, 10)

                            Spacer()
                        }
                    }.strokeColor(inputProperties.numberErrorMessage.map { _ in .customRed})
                        .lineWidth(inputProperties.numberErrorMessage.map { _ in 2 })
                }.contentFrame(width: UIScreen.main.bounds.width * 0.95, height: 50)

                // Error Messages
                ErrorMessageView($inputProperties.numberErrorMessage)

            }.animation(.default, value: inputProperties.numberErrorMessage)
        }
    }
}
