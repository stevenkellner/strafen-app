//
//  LatePaymentInterestChangerView.swift
//  Strafen
//
//  Created by Steven on 9/2/20.
//

import SwiftUI

/// Changes late payment interest
struct LatePaymentInterestChangerView: View {
    
    typealias DateComponents = Settings.LatePaymentInterest.DateComponent
    
    typealias TimePeriod = Settings.LatePaymentInterest.TimePeriod
    
    /// Input properties
    struct InputProperties {
        
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
        
        /// Type of interest rate error
        var rateErrorMessages: ErrorMessages? = nil
        
        /// Type of interest period error
        var periodErrorMessages: ErrorMessages? = nil
        
        /// Type of function call error
        var functionCallErrorMessages: ErrorMessages? = nil
        
        /// State of data task connection
        @State var connectionState: ConnectionState = .passed
        
        mutating func setProperties() {
            let latePaymentInterest = Settings.shared.latePaymentInterest
            interestsActive = latePaymentInterest != nil
            interestFreePeriod = latePaymentInterest?.interestPeriod ?? TimePeriod(value: 0, unit: .day)
            interestRate = latePaymentInterest?.interestRate ?? 0
            interestPeriod = latePaymentInterest?.interestPeriod ?? TimePeriod(value: 1, unit: .month)
            compoundInterest = latePaymentInterest?.compoundInterest ?? false
        }
        
        /// Checks if an error occurs while rate input
        @discardableResult mutating func evaluteRateError() -> Bool {
            if interestRate == 0 {
                rateErrorMessages = .rateIsZero
            } else {
                rateErrorMessages = nil
                return false
            }
            return true
        }
        
        /// Checks if an error occurs while period input
        @discardableResult mutating func evalutePeriodError() -> Bool {
            if interestPeriod.value == 0 {
                periodErrorMessages = .periodIsZero
            } else {
                periodErrorMessages = nil
                return false
            }
            return true
        }
        
        /// Late payment interest
        var latePaymentInterest: Settings.LatePaymentInterest? {
            guard interestsActive else { return nil }
            return .init(interestFreePeriod: interestFreePeriod, interestRate: interestRate, interestPeriod: interestPeriod, compoundInterest: compoundInterest)
        }
        
        /// Checks if an error occurs
        mutating func errorOccurred() -> Bool {
            evaluteRateError() |!|
                evalutePeriodError()
        }
        
        /// Reset all error messges
        mutating func resetErrors() {
            periodErrorMessages = nil
            rateErrorMessages = nil
            functionCallErrorMessages = nil
        }
    }
    
    /// Alert type
    enum AlertType: AlertTypeProtocol {

        /// Alert when confirm button is pressed
        case confirmButton(action: () -> Void)

        /// Id for Identifiable
        var id: Int {
            switch self {
            case .confirmButton(action: _):
                return 0
            }
        }

        /// Alert of all alert types
        var alert: Alert {
            switch self {
            case .confirmButton(action: let action):
                return Alert(title: Text("Verzugszinsen Ändern"),
                             message: Text("Möchtest du die Verzugszinsen wirklich ändern?"),
                             primaryButton: .destructive(Text("Abbrechen")),
                             secondaryButton: .default(Text("Bestätigen"), action: action))
            }
        }
    }
    
    ///Dismiss handler
    @Binding var dismissHandler: DismissHandler
    
    /// Input properties
    @State var inputProperties = InputProperties()
    
    /// Alert type
    @State var alertType: AlertType? = nil
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            
            // Background Color
            colorScheme.backgroundColor
            
            // Back Button
            BackButton()
            
            // Content
            VStack(spacing: 0) {
                
                // Header
                Header("Verzugszinsen")
                    .padding(.top, 75)
                
                ScrollView(showsIndicators: true) {
                    VStack(spacing: 20) {
                        
                        // Interest active changer
                        VStack(spacing: 0) {
                            
                            // Title
                            SettingsView.Title("Verzugszinsen")
                            
                            // Changer
                            BooleanChanger(boolToChange: $inputProperties.interestsActive)
                                .frame(width: UIScreen.main.bounds.width * 0.7, height: 25)
                            
                        }
                        
                        if inputProperties.interestsActive {
                            
                            // Interest free period changer
                            InterestFreePeriod(inputProperties: $inputProperties)
                            
                            // Interest rate
                            InterestRate(inputProperties: $inputProperties)
                            
                            // Interest period changer
                            InterestPeriod(inputProperties: $inputProperties)
                            
                            // Compound interest changer
                            VStack(spacing: 0) {
                                
                                // Title
                                SettingsView.Title("Zinseszins")
                                
                                // Changer
                                BooleanChanger(boolToChange: $inputProperties.compoundInterest)
                                    .frame(width: UIScreen.main.bounds.width * 0.7, height: 25)
                                
                            }
                            
                        }
                        
                        Spacer()
                    }.padding(.vertical, 10)
                        .keyboardAdaptiveOffset
                    
                }.padding(.vertical, 10)
                
                // Cancel and Confirm Button
                VStack(spacing: 5) {
                    
                    // Cancel and Confirm button
                    CancelConfirmButton()
                        .connectionState($inputProperties.connectionState)
                        .onCancelPress { presentationMode.wrappedValue.dismiss() }
                        .onConfirmPress($alertType, value: .confirmButton(action: handleSave)) {
                            guard Settings.shared.latePaymentInterest != inputProperties.latePaymentInterest else {
                                presentationMode.wrappedValue.dismiss()
                                return false
                            }
                            return !inputProperties.errorOccurred()
                        }
                        .alert(item: $alertType)
                    
                    // Error messages
                    ErrorMessageView(errorMessages: $inputProperties.functionCallErrorMessages)
                    
                }.padding(.bottom, inputProperties.functionCallErrorMessages == nil ? 35 : 10)
                    .animation(.default)
                
            }
            
        }.edgesIgnoringSafeArea(.all)
            .hideNavigationBarTitle()
            .onAppear {
                dismissHandler = { presentationMode.wrappedValue.dismiss() }
                inputProperties.setProperties()
            }
    }
    
    /// Handles interest saving
    func handleSave() {
        inputProperties.resetErrors()
        guard inputProperties.connectionState != .loading,
              !inputProperties.errorOccurred(),
              let clubId = Settings.shared.person?.clubProperties.id else { return }
        inputProperties.connectionState = .loading
        
        let callItem = LatePaymentInterestCall(latePaymentInterest: inputProperties.latePaymentInterest, clubId: clubId)
        FunctionCaller.shared.call(callItem) { _ in
            inputProperties.connectionState = .passed
            Settings.shared.latePaymentInterest = inputProperties.latePaymentInterest
            presentationMode.wrappedValue.dismiss()
        } failedHandler: { _ in
            inputProperties.connectionState = .failed
            inputProperties.functionCallErrorMessages = .internalErrorSave(code: 11)
        }
    }
    
    /// Interest free period
    struct InterestFreePeriod: View {
        
        /// Input properties
        @Binding var inputProperties: InputProperties
        
        /// String of value of interest free period
        @State var interestValueString = ""
        
        /// Indicates whether value is on edit
        @State var valueEditMode = false
        
        /// Indicates whether unit is on edit
        @State var unitEditMode = false
        
        var body: some View {
            VStack(spacing: 0) {
                
                // Title
                SettingsView.Title("Zinsfreie Zeit")
                
                HStack(spacing: 0) {
                    
                    // Value Text Field
                    CustomTextField()
                        .title("Zinsfreie Zeit")
                        .textBinding($interestValueString)
                        .keyboardType(.decimalPad)
                        .keyboardOnScreen($valueEditMode)
                        .onCompletion {
                            inputProperties.interestFreePeriod.value = interestValueString.positiveInt
                            interestValueString = String(inputProperties.interestFreePeriod.value)
                        }
                        .frame(width: UIScreen.main.bounds.width * (valueEditMode || unitEditMode ? 0.3 : 0.45), height: 50)
                    
                    // Unit Text
                    ZStack {
                        
                        // Outline
                        Outline()
                        
                        // Text
                        Text(unitName)
                            .configurate(size: 20)
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
                        Text("Fertig")
                            .foregroundColor(Color.custom.darkGreen)
                            .font(.text(25))
                            .lineLimit(1)
                            .onTapGesture {
                                withAnimation {
                                    unitEditMode = false
                                    valueEditMode = false
                                }
                                UIApplication.shared.dismissKeyboard()
                            }
                    }
                    
                }
                
                // Unit Picker
                if unitEditMode {
                    Picker("title", selection: $inputProperties.interestFreePeriod.unit) {
                        ForEach(DateComponents.allCases) { component in
                            Text(component.singular)
                                .tag(component)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                        .labelsHidden()
                        .padding(.top, 10)
                        .frame(width: UIScreen.main.bounds.width * 0.95)
                }
                
            }.onAppear {
                interestValueString = String(inputProperties.interestFreePeriod.value)
            }
        }
        
        /// Unit name
        var unitName: String {
            if inputProperties.interestFreePeriod.value == 1 {
                return inputProperties.interestFreePeriod.unit.singular
            } else {
                return inputProperties.interestFreePeriod.unit.plural
            }
        }
    }
    
    /// Interest rate
    struct InterestRate: View {
        
        /// Input properties
        @Binding var inputProperties: InputProperties
        
        /// Interest rate string
        @State var interestRateString = ""
        
        /// Keyboard on screen
        @State var keyboardOnScreen = false
        
        var body: some View {
            VStack(spacing: 0) {
                
                // Title
                SettingsView.Title("Zinssatz")
                
                HStack(spacing: 0) {
                    
                    // Text Field
                    CustomTextField()
                        .title("Zinssatz")
                        .textBinding($interestRateString)
                        .keyboardType(.decimalPad)
                        .keyboardOnScreen($keyboardOnScreen)
                        .errorMessages($inputProperties.rateErrorMessages)
                        .showErrorMessage(false)
                        .onCompletion {
                            inputProperties.interestRate = interestRateString.interestRateValue
                            interestRateString = inputProperties.interestRate.stringValue
                            inputProperties.evaluteRateError()
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.45, height: 50)
                        .padding(.leading, 15)
                    
                    // % - Sign
                    Text("%")
                        .configurate(size: 25)
                        .lineLimit(1)
                        .padding(.leading, 5)
                        .frame(height: 50)
                    
                    // Done button
                    if keyboardOnScreen {
                        Text("Fertig")
                            .foregroundColor(Color.custom.darkGreen)
                            .font(.text(25))
                            .lineLimit(1)
                            .padding(.leading, 15)
                            .onTapGesture {
                                UIApplication.shared.dismissKeyboard()
                            }
                    }
                    
                }
                
                // Error Messages
                ErrorMessageView(errorMessages: $inputProperties.rateErrorMessages)
                
            }.onAppear {
                interestRateString = inputProperties.interestRate.stringValue
            }
        }
    }
    
    /// Interest period
    struct InterestPeriod: View {
        
        /// Input properties
        @Binding var inputProperties: InputProperties
        
        /// String of value of interest free period
        @State var interestValueString = ""
        
        /// Indicates whether value is on edit
        @State var valueEditMode = false
        
        /// Indicates whether unit is on edit
        @State var unitEditMode = false
        
        var body: some View {
            VStack(spacing: 0) {
                
                // Title
                SettingsView.Title("Zins Zeitraum")
                
                HStack(spacing: 0) {
                    
                    // Value Text Field
                    CustomTextField()
                        .title("Zins Zeitraum")
                        .textBinding($interestValueString)
                        .keyboardType(.decimalPad)
                        .keyboardOnScreen($valueEditMode)
                        .errorMessages($inputProperties.periodErrorMessages)
                        .showErrorMessage(false)
                        .onCompletion {
                            inputProperties.interestPeriod.value = interestValueString.positiveInt
                            interestValueString = String(inputProperties.interestPeriod.value)
                            inputProperties.evalutePeriodError()
                        }
                        .frame(width: UIScreen.main.bounds.width * (valueEditMode || unitEditMode ? 0.3 : 0.45), height: 50)
                    
                    // Unit Text
                    ZStack {
                        
                        // Outline
                        Outline()
                        
                        // Text
                        Text(unitName)
                            .configurate(size: 20)
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
                        Text("Fertig")
                            .foregroundColor(Color.custom.darkGreen)
                            .font(.text(25))
                            .lineLimit(1)
                            .onTapGesture {
                                withAnimation {
                                    unitEditMode = false
                                    valueEditMode = false
                                }
                                UIApplication.shared.dismissKeyboard()
                            }
                    }
                    
                }
                
                // Unit Picker
                if unitEditMode {
                    Picker("title", selection: $inputProperties.interestPeriod.unit) {
                        ForEach(DateComponents.allCases) { component in
                            Text(component.singular)
                                .tag(component)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                        .labelsHidden()
                        .padding(.top, 10)
                        .frame(width: UIScreen.main.bounds.width * 0.95)
                }
                
                // Error messages
                ErrorMessageView(errorMessages: $inputProperties.periodErrorMessages)
                
            }.onAppear {
                interestValueString = String(inputProperties.interestPeriod.value)
            }
        }
        
        /// Unit name
        var unitName: String {
            if inputProperties.interestPeriod.value == 1 {
                return inputProperties.interestPeriod.unit.singular
            } else {
                return inputProperties.interestPeriod.unit.plural
            }
        }
    }
}
