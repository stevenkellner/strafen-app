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
    
    /// Alert type
    enum AlertType {
        
        /// Confirm
        case confirm
        
        /// Interest rate is zero
        case rateIsZero
        
        /// Interest period value is zero
        case periodIsZero
        
        /// No connection
        case noConnection
    }
    
    ///Dismiss handler
    @Binding var dismissHandler: (() -> ())?
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Indicates whether interests are active
    @State var interestsActive = true
    
    /// Interest free period
    @State var interestFreePeriod = TimePeriod(value: 0, unit: .day)
    
    /// Interest rate
    @State var interestRate: Double = 0
    
    /// Interest period
    @State var interestPeriod = TimePeriod(value: 1, unit: .month)
    
    /// Compound interest
    @State var compoundInterest = false
    
    /// Indicates whether keyboard is on screen for edit interest free period
    @State var isInterestFreePeriodKeyboardOnScreen = false
    
    /// Indicates whether keyboard is on screen for edit interest period
    @State var isInterestPeriodKeyboardOnScreen = false
    
    /// State of data task connection
    @State var connectionState: ConnectionState = .passed
    
    /// Indicates whether an alert is shown
    @State var showAlert = false
    
    /// Type of the alert
    @State var alertType: AlertType = .confirm
    
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
                            BooleanChanger(boolToChange: $interestsActive)
                                .frame(width: UIScreen.main.bounds.width * 0.7, height: 25)
                            
                        }
                        
                        if interestsActive {
                            
                            // Interest free period changer
                            InterestPeriod(title: "Zinsfreie Zeit", interestPeriod: $interestFreePeriod, editMode: $isInterestFreePeriodKeyboardOnScreen)
                            
                            // Interest rate
                            InterestRate(interestRate: $interestRate)
                            
                            // Interest period changer
                            InterestPeriod(title: "Zins Zeitraum", interestPeriod: $interestPeriod, editMode: $isInterestPeriodKeyboardOnScreen)
                            
                            // Compound interest changer
                            VStack(spacing: 0) {
                                
                                // Title
                                SettingsView.Title("Zinseszins")
                                
                                // Changer
                                BooleanChanger(boolToChange: $compoundInterest)
                                    .frame(width: UIScreen.main.bounds.width * 0.7, height: 25)
                                
                            }
                            
                        }
                    }.padding(.vertical, 20)
                        .offset(y: isInterestPeriodKeyboardOnScreen ? -25 : 0)
                    
                    Spacer()
                }.padding(.vertical, 10)
                
                // Cancel and Confirm Button
                CancelConfirmButton(connectionState: $connectionState) {
                    presentationMode.wrappedValue.dismiss()
                } confirmButtonHandler: {
                    handleConfirm()
                }.padding(.bottom, 30)
                    .alert(isPresented: $showAlert) {
                        switch alertType {
                        case .confirm:
                            return Alert(title: Text("Verzugszinsen Ändern"), message: Text("Möchtest du die Verzugszinsen wirklich ändern?"), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Bestätigen"), action: handleSave))
                        case .rateIsZero:
                            return Alert(title: Text("Falscher Zinssatz"), message: Text("Zinssatz darf nicht null sein."), dismissButton: .default(Text("Verstanden")))
                        case .periodIsZero:
                            return Alert(title: Text("Falscher Zeitraum"), message: Text("Zeitraum darf nicht null sein."), dismissButton: .default(Text("Verstanden")))
                        case .noConnection:
                            return Alert(title: Text("Kein Internet"), message: Text("Für diese Aktion benötigst du eine Internetverbindung."), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Erneut versuchen"), action: handleSave))
                        }
                    }
                
            }
            
        }.edgesIgnoringSafeArea(.all)
            .navigationTitle("title")
            .navigationBarHidden(true)
            .onAppear {
                dismissHandler = {
                    presentationMode.wrappedValue.dismiss()
                }
                let latePaymentInterest = Settings.shared.latePaymentInterest
                interestsActive = latePaymentInterest != nil
                interestFreePeriod = latePaymentInterest?.interestFreePeriod ?? TimePeriod(value: 0, unit: .day)
                interestRate = latePaymentInterest?.interestRate ?? 0
                interestPeriod = latePaymentInterest?.interestPeriod ?? TimePeriod(value: 1, unit: .month)
                compoundInterest = latePaymentInterest?.compoundInterest ?? false
            }
    }
    
    /// Handles confirm button clicked
    func handleConfirm() {
        if interestsActive {
            let latePaymentInterest = Settings.LatePaymentInterest(interestFreePeriod: interestFreePeriod, interestRate: interestRate, interestPeriod: interestPeriod, compoundInterest: compoundInterest)
            if Settings.shared.latePaymentInterest == latePaymentInterest {
                return presentationMode.wrappedValue.dismiss()
            } else if interestRate == 0 {
                alertType = .rateIsZero
            } else if interestPeriod.value == 0 {
                alertType = .periodIsZero
            } else {
                alertType = .confirm
            }
        } else {
            if Settings.shared.latePaymentInterest == nil {
                return presentationMode.wrappedValue.dismiss()
            } else {
                alertType = .confirm
            }
        }
        showAlert = true
    }
    
    /// Handles interest saving
    func handleSave() {
        connectionState = .loading
        var latePaymentInterest: Settings.LatePaymentInterest?
        if interestsActive {
            latePaymentInterest = .init(interestFreePeriod: interestFreePeriod, interestRate: interestRate, interestPeriod: interestPeriod, compoundInterest: compoundInterest)
        }
        let changeItem = LatePaymentInterestChange(latePaymentInterest: latePaymentInterest)
        Changer.shared.change(changeItem) {
            connectionState = .passed
            Settings.shared.latePaymentInterest = latePaymentInterest
            presentationMode.wrappedValue.dismiss()
        } failedHandler: {
            connectionState = .failed
            alertType = .noConnection
            showAlert = true
        }
    }
    
    /// Interest period
    struct InterestPeriod: View {
        
        /// Title
        let title: String
        
        /// Interest period
        @Binding var interestPeriod: TimePeriod
        
        /// String of value of interest free period
        @State var interestValueString = ""
        
        /// Indicates whether keyboard is on screen or unit is on edit
        @Binding var editMode: Bool
        
        /// Indicates whether unit is on edit
        @State var unitEditMode = false
        
        var body: some View {
            VStack(spacing: 0) {
                
                // Title
                SettingsView.Title(title)
                
                HStack(spacing: 0) {
                    
                    // Value Text Field
                    CustomTextField(title, text: $interestValueString, keyboardType: .decimalPad, keyboardOnScreen: $editMode) {
                        interestPeriod.value = interestValueString.positiveInt
                        interestValueString = String(interestPeriod.value)
                    }.frame(width: UIScreen.main.bounds.width * (editMode || unitEditMode ? 0.3 : 0.45), height: 50)
                    
                    // Unit Text
                    ZStack {
                        
                        // Outline
                        Outline()
                        
                        // Text
                        Text(interestPeriod.value == 1 ? interestPeriod.unit.singular : interestPeriod.unit.plural)
                            .foregroundColor(.textColor)
                            .font(.text(20))
                            .lineLimit(1)
                    }.frame(width: UIScreen.main.bounds.width * 0.3, height: 50)
                        .padding(.horizontal, 15)
                        .onTapGesture {
                            withAnimation {
                                unitEditMode.toggle()
                            }
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    
                    // Done button
                    if editMode || unitEditMode {
                        Text("Fertig")
                            .foregroundColor(Color.custom.darkGreen)
                            .font(.text(25))
                            .lineLimit(1)
                            .onTapGesture {
                                withAnimation {
                                    unitEditMode = false
                                }
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                    }
                }
                
                // Unit Picker
                if unitEditMode {
                    Picker("title", selection: $interestPeriod.unit) {
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
                interestValueString = String(interestPeriod.value)
            }
        }
    }
    
    /// Interest rate
    struct InterestRate: View {
        
        /// Interest rate
        @Binding var interestRate: Double
        
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
                    CustomTextField("Zinssatz", text: $interestRateString, keyboardType: .decimalPad, keyboardOnScreen: $keyboardOnScreen) {
                        interestRate = interestRateString.interestRateValue
                        interestRateString = interestRate.stringValue
                    }.frame(width: UIScreen.main.bounds.width * 0.45, height: 50)
                        .padding(.leading, 15)
                    
                    // % - Sign
                    Text("%")
                        .frame(height: 50)
                        .foregroundColor(.textColor)
                        .font(.text(25))
                        .lineLimit(1)
                        .padding(.leading, 5)
                    
                    // Done button
                    if keyboardOnScreen {
                        Text("Fertig")
                            .foregroundColor(Color.custom.darkGreen)
                            .font(.text(25))
                            .lineLimit(1)
                            .padding(.leading, 15)
                            .onTapGesture {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                    }
                    
                }
            }.onAppear {
                interestRateString = interestRate.stringValue
            }
        }
    }
}
