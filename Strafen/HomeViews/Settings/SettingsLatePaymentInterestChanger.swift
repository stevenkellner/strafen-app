//
//  SettingsLatePaymentInterestChanger.swift
//  Strafen
//
//  Created by Steven on 21.06.21.
//

import SwiftUI

/// Changes late payment interest
struct SettingsLatePaymentInterestChanger: View {
    typealias DateComponent = LatePaymentInterest.DateComponent
    typealias TimePeriod = LatePaymentInterest.TimePeriod

    /// Input properties
    struct InputProperties: InputPropertiesProtocol {

        /// All textfields
        enum TextFields: Int, TextFieldsProtocol {
            case interestFreePeriod, interestRate, interestPeriod
        }

        var inputProperties = [TextFields: String]()

        var errorMessages = [TextFields: ErrorMessages]()

        var firstResponders = TextFieldFirstResponders<TextFields>()

        /// Indicates whether interests are active
        var interestsActive = false

        /// Interest free period
        var interestFreePeriod = TimePeriod(value: 0, unit: .day)

        /// Interest rate
        var interestRate: Double = 0

        /// Interest period
        var interestPeriod = TimePeriod(value: 1, unit: .month)

        /// Compound interest
        var compoundInterest = false

        /// Type of function call error
        var functionCallErrorMessage: ErrorMessages?

        /// State of data task connection
        var connectionState: ConnectionState = .notStarted

        /// Validates the interest free period input and sets associated error messages
        /// - Returns: result of this validation
        private mutating func validateInterestFreePeriod(setErrorMessage: Bool = true) -> ValidationResult {
            interestFreePeriod.value = LatePaymentInterestPeriodValueParser.fromString(self[.interestFreePeriod])
            self[.interestFreePeriod] = "\(interestFreePeriod.value)"
            var errorMessage: ErrorMessages?
            if self[.interestFreePeriod].isEmpty {
                errorMessage = .emptyField
            } else {
                if setErrorMessage { self[error: .interestFreePeriod] = nil }
                return .valid
            }
            if setErrorMessage { self[error: .interestFreePeriod] = errorMessage }
            return .invalid
        }

        /// Validates the interest period input and sets associated error messages
        /// - Returns: result of this validation
        private mutating func validateInterestPeriod(setErrorMessage: Bool = true) -> ValidationResult {
            interestPeriod.value = LatePaymentInterestPeriodValueParser.fromString(self[.interestPeriod])
            self[.interestPeriod] = "\(interestPeriod.value)"
            var errorMessage: ErrorMessages?
            if self[.interestPeriod].isEmpty {
                errorMessage = .emptyField
            } else if interestPeriod.value == 0 {
                errorMessage = .periodIsZero
            } else {
                if setErrorMessage { self[error: .interestPeriod] = nil }
                return .valid
            }
            if setErrorMessage { self[error: .interestPeriod] = errorMessage }
            return .invalid
        }

        /// Validates the interest rate input and sets associated error messages
        /// - Returns: result of this validation
        private mutating func validateInterestRate(setErrorMessage: Bool = true) -> ValidationResult {
            interestRate = LatePaymentInterestRateParser.fromString(self[.interestRate])
            self[.interestRate] = LatePaymentInterestRateParser.toString(interestRate)
            var errorMessage: ErrorMessages?
            if self[.interestRate].isEmpty {
                errorMessage = .emptyField
            } else if interestRate == 0 {
                errorMessage = .rateIsZero
            } else {
                if setErrorMessage { self[error: .interestRate] = nil }
                return .valid
            }
            if setErrorMessage { self[error: .interestRate] = errorMessage }
            return .invalid
        }

        mutating func validateTextField(_ textfield: TextFields, setErrorMessage: Bool) -> ValidationResult {
            switch textfield {
            case .interestFreePeriod: return validateInterestFreePeriod(setErrorMessage: setErrorMessage)
            case .interestRate: return validateInterestRate(setErrorMessage: setErrorMessage)
            case .interestPeriod: return validateInterestPeriod(setErrorMessage: setErrorMessage)
            }
        }

        /// Late payment interest
        mutating func getLatePaymentInterest() -> LatePaymentInterest? {
            guard interestsActive else { return nil }
            interestFreePeriod.value = LatePaymentInterestPeriodValueParser.fromString(self[.interestFreePeriod])
            interestPeriod.value = LatePaymentInterestPeriodValueParser.fromString(self[.interestPeriod])
            interestRate = LatePaymentInterestRateParser.fromString(self[.interestRate])
            return .init(interestFreePeriod: interestFreePeriod, interestRate: interestRate / 100, interestPeriod: interestPeriod, compoundInterest: compoundInterest)
        }

        mutating func setProperties() {
            let latePaymentInterest = Settings.shared.latePaymentInterest
            interestsActive = latePaymentInterest != nil
            interestFreePeriod = latePaymentInterest?.interestFreePeriod ?? TimePeriod(value: 0, unit: .day)
            self[.interestFreePeriod] = "\(interestFreePeriod.value)"
            interestPeriod = latePaymentInterest?.interestPeriod ?? TimePeriod(value: 1, unit: .month)
            self[.interestPeriod] = "\(interestPeriod.value)"
            interestRate = latePaymentInterest?.interestRate ?? 0
            self[.interestRate] = LatePaymentInterestRateParser.toString(interestRate)
            compoundInterest = latePaymentInterest?.compoundInterest ?? false
        }
    }

    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode

    /// Currently logged in person
    @EnvironmentObject var person: Settings.Person

    /// Input properties
    @State var inputProperties = InputProperties()

    var body: some View {
        ZStack {

            // Background Color
            Color.backgroundGray

            // Content
            VStack(spacing: 0) {

                // Back button
                BackButton()
                    .padding(.top, 50)

                // Header
                Header(String(localized: "settings-late-payment-interest-header-text", comment: "Header of settings late payment interest view."))
                    .padding(.top, 10)

                ScrollView(showsIndicators: false) {
                    ScrollViewReader { proxy in
                        VStack(spacing: 20) {

                            // Interest active changer
                            TitledContent(String(localized: "settings-late-payment-interest-header-text", comment: "Header of settings late payment interest view.")) {
                                CustomToggle(String(localized: "settings-late-payment-interest-header-text", comment: "Header of settings late payment interest view."), isOn: $inputProperties.interestsActive)
                                    .fieldSize(width: UIScreen.main.bounds.width * 0.95, height: 50)
                            }

                            if inputProperties.interestsActive {

                                // Interest free period changer
                                InterestFreePeriodChanger(inputProperties: $inputProperties, proxy: proxy)

                                // Interest rate
                                InterestRate(inputProperties: $inputProperties, proxy: proxy)

                                // Interest period changer
                                InterestPeriodChanger(inputProperties: $inputProperties, proxy: proxy)

                                // Compound interest changer
                                TitledContent(String(localized: "settings-late-payment-interest-compound-interest-title", comment: "Title of compound interest in settings late payment interest view.")) {
                                    CustomToggle(String(localized: "settings-late-payment-interest-compound-interest-title", comment: "Title of compound interest in settings late payment interest view."), isOn: $inputProperties.compoundInterest)
                                        .fieldSize(width: UIScreen.main.bounds.width * 0.95, height: 50)
                                }.padding(.bottom, 20)
                            }
                        }.padding(.vertical, 10)
                    }
                }.padding(.top, 10)

                Spacer(minLength: 0)

                // Cancel and Confirm Button
                VStack(spacing: 5) {

                    // Error message
                    ErrorMessageView($inputProperties.functionCallErrorMessage)

                    // Cancel and Confirm button
                    SplittedButton.cancelConfirm
                        .rightConnectionState($inputProperties.connectionState)
                        .onLeftClick { presentationMode.wrappedValue.dismiss() }
                        .onRightClick(perform: handleSave)

                }.padding(.bottom, 35)
                    .animation(.default, value: inputProperties.functionCallErrorMessage)
            }

        }.maxFrame.dismissHandler
            .onAppear { inputProperties.setProperties() }
    }

    /// Handles interest saving
    func handleSave() async {
        await SettingsLatePaymentInterestChanger.handleSave(clubId: person.club.id,
                                                            inputProperties: $inputProperties,
                                                            presentationMode: presentationMode)
    }
    /// Handles interest saving
    static func handleSave(clubId: Club.ID,
                           inputProperties: Binding<InputProperties>,
                           presentationMode: Binding<PresentationMode>? = nil) async {
        guard inputProperties.wrappedValue.connectionState.restart() == .passed else { return }
        inputProperties.wrappedValue.functionCallErrorMessage = nil
        let latePaymentInterest = inputProperties.wrappedValue.getLatePaymentInterest()
        if latePaymentInterest != nil && inputProperties.wrappedValue.validateAllInputs() != .valid {
            return inputProperties.wrappedValue.connectionState.failed()
        }

        do {
            let callItem = FFChangeLatePaymentInterestCall(clubId: clubId, interest: latePaymentInterest)
            try await FirebaseFunctionCaller.shared.call(callItem)
            Settings.shared.latePaymentInterest = latePaymentInterest
            inputProperties.wrappedValue.connectionState.passed()
            presentationMode?.wrappedValue.dismiss()
        } catch {
            inputProperties.wrappedValue.connectionState.failed()
            inputProperties.wrappedValue.functionCallErrorMessage = .internalErrorSave
        }
    }

    /// Interest free period changer
    struct InterestFreePeriodChanger: View {

        /// Input properties
        @Binding var inputProperties: InputProperties

        /// Scrollview proxy
        let proxy: ScrollViewProxy

        /// Indicates whether value is on edit
        @State var valueEditMode = false

        /// Indicates whether unit is on edit
        @State var unitEditMode = false

        /// Unit of period
        @State var unit: DateComponent = .day

        var body: some View {
            TitledContent(String(localized: "settings-late-payment-interest-interest-free-period-title", comment: "Title of interest free period in settings late payment interest view.")) {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {

                        // Value text field
                        CustomTextField(.interestFreePeriod, inputProperties: $inputProperties)
                            .placeholder(String(localized: "settings-late-payment-interest-interest-free-period-title", comment: "Title of interest free period in settings late payment interest view."))
                            .keyboardType(.decimalPad)
                            .scrollViewProxy(proxy)
                            .hideErrorMessage
                            .onFocus { valueEditMode = true }
                            .onCompletion { valueEditMode = false }
                            .textFieldSize(width: UIScreen.main.bounds.width * (valueEditMode || unitEditMode ? 0.3 : 0.45), height: 50)

                        // Unit text
                        SingleOutlinedContent {
                            Text(inputProperties.interestFreePeriod.unit.string)
                                .foregroundColor(.textColor)
                                .font(.system(size: 20, weight: .thin))
                                .lineLimit(1)
                        }.frame(width: UIScreen.main.bounds.width * 0.3, height: 50)
                            .padding(.horizontal, 15)
                            .onTapGesture {
                                withAnimation {
                                    unitEditMode.toggle()
                                    valueEditMode = false
                                }
                                UIApplication.shared.dismissKeyboard()
                            }

                        // Done button
                        if unitEditMode || valueEditMode {
                            Text("done-button-text", comment: "Text of done button.")
                                .foregroundColor(.customGreen)
                                .font(.system(size: 25, weight: .thin))
                                .lineLimit(1)
                                .onTapGesture {
                                    withAnimation {
                                        unitEditMode = false
                                        valueEditMode = false
                                    }
                                    UIApplication.shared.dismissKeyboard()
                                }

                        }

                    }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)

                    // Error Message
                    ErrorMessageView($inputProperties[error: .interestFreePeriod])
                        .padding(.top, 5)

                    // Unit Picker
                    if unitEditMode {
                        Picker("", selection: $unit) {
                            Text(DateComponent.day.string).tag(DateComponent.day)
                            Text(DateComponent.month.string).tag(DateComponent.month)
                            Text(DateComponent.year.string).tag(DateComponent.year)
                        }.pickerStyle(.segmented).labelsHidden()
                            .padding(.top, 10)
                            .frame(width: UIScreen.main.bounds.width * 0.95)
                            .onChange(of: unit) { inputProperties.interestFreePeriod.unit = $0 }
                    }

                }
            }.onAppear { unit = inputProperties.interestFreePeriod.unit }
        }
    }

    /// Interest period changer
    struct InterestPeriodChanger: View {

        /// Input properties
        @Binding var inputProperties: InputProperties

        /// Scrollview proxy
        let proxy: ScrollViewProxy

        /// Indicates whether value is on edit
        @State var valueEditMode = false

        /// Indicates whether unit is on edit
        @State var unitEditMode = false

        /// Unit of period
        @State var unit: DateComponent = .day

        var body: some View {
            TitledContent(String(localized: "settings-late-payment-interest-interest-period-title", comment: "Title of interest period in settings late payment interest view.")) {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {

                        // Value text field
                        CustomTextField(.interestPeriod, inputProperties: $inputProperties)
                            .placeholder(String(localized: "settings-late-payment-interest-interest-period-title", comment: "Title of interest period in settings late payment interest view."))
                            .keyboardType(.decimalPad)
                            .scrollViewProxy(proxy)
                            .hideErrorMessage
                            .onFocus { valueEditMode = true }
                            .onCompletion { valueEditMode = false }
                            .textFieldSize(width: UIScreen.main.bounds.width * (valueEditMode || unitEditMode ? 0.3 : 0.45), height: 50)

                        // Unit text
                        SingleOutlinedContent {
                            Text(inputProperties.interestPeriod.unit.string)
                                .foregroundColor(.textColor)
                                .font(.system(size: 20, weight: .thin))
                                .lineLimit(1)
                        }.frame(width: UIScreen.main.bounds.width * 0.3, height: 50)
                            .padding(.horizontal, 15)
                            .onTapGesture {
                                withAnimation {
                                    unitEditMode.toggle()
                                    valueEditMode = false
                                }
                                UIApplication.shared.dismissKeyboard()
                            }

                        // Done button
                        if unitEditMode || valueEditMode {
                            Text("done-button-text", comment: "Text of done button.")
                                .foregroundColor(.customGreen)
                                .font(.system(size: 25, weight: .thin))
                                .lineLimit(1)
                                .onTapGesture {
                                    withAnimation {
                                        unitEditMode = false
                                        valueEditMode = false
                                    }
                                    UIApplication.shared.dismissKeyboard()
                                }

                        }

                    }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)

                    // Error Message
                    ErrorMessageView($inputProperties[error: .interestPeriod])
                        .padding(.top, 5)

                    // Unit Picker
                    if unitEditMode {
                        Picker("", selection: $unit) {
                            Text(DateComponent.day.string).tag(DateComponent.day)
                            Text(DateComponent.month.string).tag(DateComponent.month)
                            Text(DateComponent.year.string).tag(DateComponent.year)
                        }.pickerStyle(.segmented).labelsHidden()
                            .padding(.top, 10)
                            .frame(width: UIScreen.main.bounds.width * 0.95)
                            .onChange(of: unit) { inputProperties.interestPeriod.unit = $0 }
                    }

                }
            }.onAppear { unit = inputProperties.interestPeriod.unit }
        }
    }

    /// Interest rate
    struct InterestRate: View {

         /// Input properties
         @Binding var inputProperties: InputProperties

         /// Scrollview proxy
         let proxy: ScrollViewProxy

        /// Keyboard on screen
        @State var keyboardOnScreen = false

        var body: some View {
            TitledContent(String(localized: "settings-late-payment-interest-interest-rate-title", comment: "Title of interest rate in settings late payment interest view.")) {
                VStack(spacing: 0) {

                    HStack(spacing: 0) {

                        // Text Field
                        CustomTextField(.interestRate, inputProperties: $inputProperties)
                            .placeholder(String(localized: "settings-late-payment-interest-interest-rate-title", comment: "Title of interest rate in settings late payment interest view."))
                            .keyboardType(.decimalPad)
                            .hideErrorMessage
                            .scrollViewProxy(proxy)
                            .onFocus { keyboardOnScreen = true }
                            .onCompletion { keyboardOnScreen = false }
                            .textFieldSize(width: UIScreen.main.bounds.width * 0.45, height: 50)
                            .padding(.leading, 15)

                        // % - Sign
                        Text(verbatim: "%")
                            .foregroundColor(.textColor)
                            .font(.system(size: 25, weight: .thin))
                            .lineLimit(1)
                            .padding(.leading, 5)
                            .frame(height: 50)

                        // Done button
                        if keyboardOnScreen {
                            Text("done-button-text", comment: "Text of done button.")
                                .foregroundColor(.customGreen)
                                .font(.system(size: 25, weight: .thin))
                                .lineLimit(1)
                                .padding(.leading, 15)
                                .onTapGesture { UIApplication.shared.dismissKeyboard()
                                }
                        }
                    }

                    // Error Messages
                    ErrorMessageView($inputProperties[error: .interestRate])
                }
            }
        }
    }
}
