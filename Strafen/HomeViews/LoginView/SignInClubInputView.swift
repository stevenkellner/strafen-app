//
//  SignInClubInputView.swift
//  Strafen
//
//  Created by Steven on 15.05.21.
//

import SwiftUI
import FirebaseFunctions

struct SignInClubInputView: View {

    // MARK: input properties

    /// Contains all properties of the textfield inputs
    struct InputProperties: InputPropertiesProtocol {

        /// All textfields
        enum TextFields: Int, TextFieldsProtocol {
            case clubName, clubIdentifier
        }

        var inputProperties = [TextFields: String]()

        var errorMessages = [TextFields: ErrorMessages]()

        var firstResponders = TextFieldFirstResponders<TextFields>()

        /// Region code
        var regionCode: String?

        /// Is in app paypent active
        var inAppPayment: Bool = true

        /// Error message of region code
        var regionCodeErrorMessage: ErrorMessages?

        /// Error message of in app payment
        var inAppPaymentErrorMessage: ErrorMessages?

        /// Validates the club name input and sets associated error messages
        /// - Parameter setErrorMessage: Indicates whether error message will be set
        /// - Returns: result of this validation
        private mutating func validateClubName(setErrorMessage: Bool = true) -> ValidationResult {
            var errorMessage: ErrorMessages?
            if self[.clubName].isEmpty {
                errorMessage = .emptyField
            } else {
                if setErrorMessage { self[error: .clubName] = nil }
                return .valid
            }
            if setErrorMessage { self[error: .clubName] = errorMessage }
            return .invalid
        }

        /// Validates the club identifer input and sets associated error messages
        /// - Parameter setErrorMessage: Indicates whether error message will be set
        /// - Returns: result of this validation
        private mutating func validateClubIdentifier(setErrorMessage: Bool = true) -> ValidationResult {
            var errorMessage: ErrorMessages?
            if self[.clubIdentifier].isEmpty {
                errorMessage = .emptyField
            } else {
                if setErrorMessage { self[error: .clubIdentifier] = nil }
                return .valid
            }
            if setErrorMessage { self[error: .clubIdentifier] = errorMessage }
            return .invalid
        }

        mutating func validateTextField(_ textfield: TextFields, setErrorMessage: Bool) -> ValidationResult {
            switch textfield {
            case .clubName: return validateClubName(setErrorMessage: setErrorMessage)
            case .clubIdentifier: return validateClubIdentifier(setErrorMessage: setErrorMessage)
            }
        }

        /// Validates the region code and sets associated error messages
        /// - Returns: result of this validation
        mutating func validateRegionCode() -> ValidationResult {
            if regionCode == nil {
                regionCodeErrorMessage = .noRegionGiven
            } else {
                regionCodeErrorMessage = nil
                return .valid
            }
            return .invalid
        }

        /// Validates in app payment and sets associated error messages
        /// - Returns: result of this validation
        mutating func validateActivateInAppPayment() -> ValidationResult {
            if inAppPayment, let regionCode = regionCode {
                let languageCodeKey = Locale.current.languageCode ?? "de"
                let identifier = Locale.identifier(fromComponents: [
                    "kCFLocaleCountryCodeKey": regionCode,
                    "kCFLocaleLanguageCodeKey": languageCodeKey
                ])
                let locale = Locale(identifier: identifier)
                if locale.currencyCode != "EUR" {
                    inAppPaymentErrorMessage = .notEuro
                    return .invalid
                }
            }
            inAppPaymentErrorMessage = nil
            return .valid
        }

        /// Validates all input and sets associated error messages
        /// - Returns: result of this validation
        public mutating func validateAllInputs() -> ValidationResult {
            [TextFields.allCases.validateAll { textField in
                validateTextField(textField)
            }, validateRegionCode(), validateActivateInAppPayment()].validateAll
        }

        /// State of continue button press
        var connectionState: ConnectionState = .notStarted

        /// Evaluates auth error and sets associated error messages
        /// - Parameter error: auth error
        mutating func evaluateErrorCode(of error: NSError) {
            guard error.domain == FunctionsErrorDomain else { return self[error: .clubName] = .internalErrorSignIn }
            let errorCode = FunctionsErrorCode(rawValue: error.code)
            switch errorCode {
            case .alreadyExists:
                self[error: .clubIdentifier] = .identifierAlreadyExists
            default:
                self[error: .clubName] = .internalErrorSignIn
            }
        }
    }

    // MARK: properties

    /// Sign in property with userId and name
    let oldSignInProperty: SignInProperty.UserIdName

    /// Init with sign in property
    /// - Parameter signInProperty: Sign in property with userId and name
    init(signInProperty: SignInProperty.UserIdName) {
        self.oldSignInProperty = signInProperty
    }

    /// All properties of the textfield inputs
    @State private var inputProperties = InputProperties()

    // MARK: body

    var body: some View {
        ZStack {

            // Background color
            Color.backgroundGray

            // Content
            VStack(spacing: 0) {

                // Back button
                BackButton()
                    .padding(.top, 50)

                // Header
                Header("Neuer Verein")
                    .padding(.top, 10)

                Spacer()

                ScrollView(showsIndicators: false) {
                    ScrollViewReader { proxy in
                        VStack(spacing: 15) {

                            // Club name

                            TitledContent("Vereinsname") {
                                CustomTextField(.clubName, inputProperties: $inputProperties)
                                    .placeholder("Vereinsname")
                                    .defaultTextFieldSize
                                    .scrollViewProxy(proxy)

                            }

                            // Region code
                            VStack(spacing: 5) {
                                TitledContent("Region") {
                                    RegionInput(inputProperties: $inputProperties)
                                }
                                ErrorMessageView($inputProperties.regionCodeErrorMessage)
                            }

                            // Aktivate in app payment
                            VStack(spacing: 5) {
                                VStack(spacing: 5) {
                                    TitledContent("In App Payment") {
                                        CustomToggle("In App Payment", isOn: $inputProperties.inAppPayment)
                                            .fieldSize(width: UIScreen.main.bounds.width * 0.95, height: 55)
                                            .errorMessage($inputProperties.inAppPaymentErrorMessage)
                                    }
                                    ErrorMessageView($inputProperties.inAppPaymentErrorMessage)
                                }

                                Text("Wenn aktiv können deine Mitspieler die Strafen in der App zahlen und du sie dann auszahlen lassen.")
                                    .foregroundColor(.white)
                                    .font(.system(size: 24, weight: .thin))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 15)
                                    .lineLimit(3)
                            }

                            // Club identifier
                            VStack(spacing: 5) {
                                TitledContent("Vereinskennung") {
                                    CustomTextField(.clubIdentifier, inputProperties: $inputProperties)
                                        .placeholder("Vereinskennung")
                                        .defaultTextFieldSize
                                        .scrollViewProxy(proxy)
                                }

                                // Text
                                Text("Benutze die eindeutige Kennung um andere Spieler hinzuzufügen.")
                                    .foregroundColor(.white)
                                    .font(.system(size: 24, weight: .thin))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 15)
                                    .lineLimit(2)

                            }

                        }
                    }
                }

                Spacer()

                // Confirm button
                SingleButton.confirm
                    .connectionState($inputProperties.connectionState)
                    .onClick(perform: handleConfirmButtonPress)
                    .padding(.bottom, 55)

            }

        }.maxFrame
    }

    // MARK: handle cofirm button press

    /// Handles the click on the confirm button
    func handleConfirmButtonPress() {
        Self.handleConfirmButtonPress(oldSignInProperty: oldSignInProperty, inputProperties: $inputProperties)
    }

    /// Handles the click on the confirm button
    /// - Parameter oldSignInProperty: sign in property with userId and name
    /// - Parameter inputProperties: binding of the input properties
    /// - Parameter level: level of function call
    /// - Parameter completionHandler: handler executed after club was created or a error occured at this
    static func handleConfirmButtonPress(oldSignInProperty: SignInProperty.UserIdName, inputProperties: Binding<InputProperties>, onCompletion completionHandler: ((Club.ID?) -> Void)? = nil) {
        guard inputProperties.wrappedValue.connectionState.restart() == .passed else { return }
        guard inputProperties.wrappedValue.validateAllInputs() == .valid else {
            return inputProperties.wrappedValue.connectionState.failed()
        }
        checkClubIdentifierExists(inputProperties: inputProperties) {
            createNewClub(oldSignInProperty: oldSignInProperty, inputProperties: inputProperties, onCompletion: completionHandler)
        } onFailure: {
            completionHandler?(nil)
        }
    }

    /// Checks if club with identifier already exists
    /// - Parameters:
    ///   - inputProperties: binding of the input properties
    ///   - successHandler: executed if no club with identifier exists
    ///   - failureHandler: executed if a error occured
    static func checkClubIdentifierExists(inputProperties: Binding<InputProperties>, handler successHandler: @escaping () -> Void, onFailure failureHandler: @escaping () -> Void) {
        let callItem = FFExistsClubWithIdentifierCall(identifier: inputProperties.wrappedValue[.clubIdentifier])
        FirebaseFunctionCaller.shared.call(callItem).then { clubExists in
            if clubExists {
                inputProperties.wrappedValue[error: .clubIdentifier] = .identifierAlreadyExists
                inputProperties.wrappedValue.connectionState.failed()
                failureHandler()
            } else {
                successHandler()
            }
        }.catch { _ in
            inputProperties.wrappedValue[error: .clubName] = .internalErrorSignIn
            inputProperties.wrappedValue.connectionState.failed()
            failureHandler()
        }
    }

    /// Creates a new club
    /// - Parameters:
    ///   - oldSignInProperty: sign in property with userId and name
    ///   - inputProperties: binding of the input properties
    ///   - completionHandler: handler executed after club was created
    static func createNewClub(oldSignInProperty: SignInProperty.UserIdName, inputProperties: Binding<InputProperties>, onCompletion completionHandler: ((Club.ID?) -> Void)?) {
        let callItem = FFNewClubCall(
            signInProperty: oldSignInProperty,
            clubId: Club.ID(rawValue: UUID()),
            personId: FirebasePerson.ID(rawValue: UUID()),
            clubName: inputProperties.wrappedValue[.clubName],
            regionCode: inputProperties.wrappedValue.regionCode!,
            clubIdentifier: inputProperties.wrappedValue[.clubIdentifier],
            inAppPayment: inputProperties.wrappedValue.inAppPayment)
        FirebaseFunctionCaller.shared.call(callItem).then { _ in
            inputProperties.wrappedValue.connectionState.passed()
            // TODO set settings
        }.catch { error in
            inputProperties.wrappedValue.evaluateErrorCode(of: error as NSError)
            inputProperties.wrappedValue.connectionState.failed()
        }.always {
            completionHandler?(callItem.clubId)
        }
    }

    // MARK: region nput

    /// Region input
    struct RegionInput: View {

        /// All properties of the textfield inputs
        @Binding var inputProperties: InputProperties

        var body: some View {
            SingleOutlinedContent {
                Picker({ () -> String in
                    guard let regionCode = inputProperties.regionCode else { return "Region auswählen" }
                    return Locale.regionName(of: regionCode)
                }(), selection: $inputProperties.regionCode) {
                    ForEach(Locale.availableRegionCodes, id: \.self) { regionCode in
                        Text(Locale.regionName(of: regionCode))
                            .tag(regionCode as String?)
                    }
                }.pickerStyle(MenuPickerStyle())
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(.textColor)
                    .lineLimit(1)
            }.strokeColor(inputProperties.regionCodeErrorMessage.map { _ in .customRed })
                .lineWidth(inputProperties.regionCodeErrorMessage.map { _ in 2 })
                .frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                .onAppear {
                    if let regionCode = Locale.current.regionCode,
                       Locale.availableRegionCodes.contains(regionCode) {
                        inputProperties.regionCode = regionCode
                    }
                }
        }
    }
}
