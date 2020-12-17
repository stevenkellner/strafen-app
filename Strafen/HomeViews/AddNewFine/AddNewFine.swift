//
//  AddNewFine.swift
//  Strafen
//
//  Created by Steven on 17.07.20.
//

import SwiftUI

/// View to add a new fine
struct AddNewFine: View {
    
    /// Properties for fine input
    struct FineInputProperties {
        
        /// Ids of associated persons
        var personIds = [Person.ID]()
        
        /// Fine Reason
        var fineReason: FineReason?
        
        /// Input date
        var date = Date()
        
        /// Input number
        var number = 1
        
        /// Type of person id error
        var personIdErrorMessages: ErrorMessages? = nil
        
        /// Type of fine reason error
        var fineReasonErrorMessages: ErrorMessages? = nil
        
        /// Type of date error
        var dateErrorMessages: ErrorMessages? = nil
        
        /// Type of number error
        var numberErrorMessages: ErrorMessages? = nil
        
        /// Type of function call error
        var functionCallErrorMessages: ErrorMessages? = nil
        
        /// State of data task connection
        var connectionState: ConnectionState = .passed
        
        /// Checks if an error occurs while person id input
        @discardableResult mutating func evaluatePersonIdError() -> Bool {
            if personIds.isEmpty {
                personIdErrorMessages = .noPersonsSelected
            } else {
                personIdErrorMessages = nil
                return false
            }
            return true
        }
        
        /// Checks if an error occurs while fine reason input
        @discardableResult mutating func evaluateFineReasonError() -> Bool {
            if fineReason == nil {
                fineReasonErrorMessages = .noReasonGiven
            } else {
                fineReasonErrorMessages = nil
                return false
            }
            return true
        }
        
        /// Checks if an error occurs while date input
        @discardableResult mutating func evaluateDateError() -> Bool {
            if date > Date() {
                dateErrorMessages = .futureDate
            } else {
                dateErrorMessages = nil
                return false
            }
            return true
        }
        
        /// Checks if an error occurs while number input
        @discardableResult mutating func evaluateNumberError() -> Bool {
            if !(1...99).contains(number) {
                numberErrorMessages = .invalidNumberRange
            } else {
                numberErrorMessages = nil
                return false
            }
            return true
        }
        
        /// Checks if an error occurs
        mutating func errorOccurred() -> Bool {
            evaluatePersonIdError() |!|
                evaluateFineReasonError() |!|
                evaluateDateError() |!|
                evaluateNumberError()
        }
        
        /// Reset error messages
        mutating func resetErrors() {
            personIdErrorMessages = nil
            fineReasonErrorMessages = nil
            dateErrorMessages = nil
            numberErrorMessages = nil
            functionCallErrorMessages = nil
        }
        
        /// Reset properties
        mutating func resetProperties() {
            personIds = []
            fineReason = nil
            date = Date()
            number = 1
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
                return Alert(title: Text("Strafe Hinzufügen"),
                             message: Text("Möchtest du diese Strafe wirklich hinzufügen?"),
                             primaryButton: .destructive(Text("Abbrechen")),
                             secondaryButton: .default(Text("Bestätigen"), action: action))
            }
        }
    }
    
    /// Init with person id
    let initPersonId: Person.ID?
    
    /// Default init
    init() { initPersonId = nil }
    
    /// Init with person id
    init(with personId: Person.ID) { initPersonId = personId }
    
    /// Properties for fine input
    @State var fineInputProperties = FineInputProperties()
    
    /// Alert type
    @State var alertType: AlertType? = nil
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Active home tab
    @ObservedObject var homeTabs = HomeTabs.shared
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Header
            Header("Strafen Hinzufügen")
            
            ScrollView {
                VStack(spacing: 10) {
                    
                    // Person input
                    PersonInput(fineInputProperties: $fineInputProperties)
                    
                    // Reason input
                    ReasonInput(fineInputProperties: $fineInputProperties)
                    
                    // Date input
                    DateInput(fineInputProperties: $fineInputProperties)
                    
                    // Number input
                    NumberInput(fineInputProperties: $fineInputProperties)
                    
                }.padding(.vertical, 10)
            }.padding(.vertical, 10)
                .animation(.default)
    
            Spacer(minLength: 0)
            
            VStack(spacing: 5) {
                
                // Cancel and Confirm button
                CancelConfirmButton()
                    .connectionState($fineInputProperties.connectionState)
                    .onCancelPress {
                        fineInputProperties.resetProperties()
                        homeTabs.active = .personList
                        presentationMode.wrappedValue.dismiss()
                    }
                    .onConfirmPress($alertType, value: .confirmButton(action: handleSave)) {
                        !fineInputProperties.errorOccurred()
                    }
                    .alert(item: $alertType)
                
                // Error messages
                ErrorMessageView(errorMessages: $fineInputProperties.functionCallErrorMessages)
                
            }.padding(.bottom, fineInputProperties.functionCallErrorMessages == nil ? 35 : 10)
                .animation(.default)
            
        }.onAppear {
            if let initPersonId = initPersonId {
                fineInputProperties.personIds.append(initPersonId)
            }
        }
    }
    
    /// Handles fine saving
    func handleSave() {
        fineInputProperties.resetErrors()
        guard fineInputProperties.connectionState != .loading,
            !fineInputProperties.errorOccurred(),
            let fineReason = fineInputProperties.fineReason,
            let clubId = Settings.shared.person?.clubProperties.id else { return }
        fineInputProperties.connectionState = .loading
        
        let dispatchGroup = DispatchGroup()
        for personId in fineInputProperties.personIds {
            let fineId = Fine.ID(rawValue: UUID())
            let fine = Fine(id: fineId, assoiatedPersonId: personId, date: fineInputProperties.date, payed: .unpayed, number: fineInputProperties.number, fineReason: fineReason)
            dispatchGroup.enter()
            let callItem = ChangeListCall(clubId: clubId, changeType: .add, changeItem: fine)
            FunctionCaller.shared.call(callItem) { _ in
                fineInputProperties.personIds.filtered { $0 != personId }
                dispatchGroup.leave()
            } failedHandler: { _ in
                fineInputProperties.connectionState = .failed
                fineInputProperties.functionCallErrorMessages = .internalErrorSave
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            fineInputProperties.connectionState = .passed
            fineInputProperties.resetProperties()
            homeTabs.active = .personList
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    /// Person input
    struct PersonInput: View {
        
        /// Properties for fine input
        @Binding var fineInputProperties: FineInputProperties
        
        /// Person List Data
        @ObservedObject var personListData = ListData.person
        
        /// Indicates if person selector sheet is shown
        @State var showPersonSelectorSheet = false
        
        var body: some View {
            VStack(spacing: 5) {
                
                TitledContent("Zugehörige Person") {
                    
                    GeometryReader { geometry in
                        
                        // At least one person is selected
                        if let firstPersonName = firstPersonName {
                            
                            HStack(spacing: 0) {
                                
                                // Left of Divider
                                ZStack {
                                    
                                    // Outline
                                    Outline(.left)
                                        .errorMessages($fineInputProperties.personIdErrorMessages)
                                    
                                    // Text
                                    Text(firstPersonName)
                                        .configurate(size: 20)
                                        .lineLimit(1)
                                        .padding(.horizontal, 15)
                                    
                                }.frame(width: geometry.size.width * 0.7)
                                
                                // Right of Divider
                                ZStack {
                                    
                                    // Outline
                                    Outline(.right)
                                        .fillColor(default: Color.custom.lightGreen)
                                        .fillColor(plain: Color.plain.lightGray)
                                        .errorMessages($fineInputProperties.personIdErrorMessages)
                                    
                                    // Text
                                    Text(selectMoreText)
                                        .configurate(size: 15)
                                        .lineLimit(2)
                                        .padding(.horizontal, 15)
                                }.frame(width: geometry.size.width * 0.3)
                                
                            }
                            
                        } else {
                            
                            // No person selected
                            ZStack {
                                
                                // Outline
                                Outline()
                                    .errorMessages($fineInputProperties.personIdErrorMessages)
                                
                                // Text
                                Text("Person auswählen")
                                    .configurate(size: 20)
                                    .lineLimit(1)
                                    .padding(.horizontal, 15)
                                    .opacity(0.5)
                            }
                            
                        }
                        
                    }.toggleOnTapGesture($showPersonSelectorSheet)
                    
                }.contentFrame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                
                // Error Messages
                ErrorMessageView(errorMessages: $fineInputProperties.personIdErrorMessages)
                
            }.animation(.default)
                .sheet(isPresented: $showPersonSelectorSheet) {
                    AddNewFinePerson(forSeveralPersons: !fineInputProperties.personIds.isEmpty, personIds: fineInputProperties.personIds) { personIds in
                        fineInputProperties.personIds = personIds
                        fineInputProperties.evaluatePersonIdError()
                    }
                }
        }
        
        /// First person name
        var firstPersonName: String? {
            guard let firstPersonId = fineInputProperties.personIds.first else { return nil }
            guard let firstPerson = personListData.list?.first(where: { $0.id == firstPersonId }) else { return "Unknown Person" }
            return firstPerson.name.formatted
        }
        
        /// Select more text
        var selectMoreText: String {
            if fineInputProperties.personIds.count == 1 {
                return "Weitere Auswählen"
            }
            return "\(fineInputProperties.personIds.count - 1) Weitere Ausgewählt"
        }
    }
    
    /// Reason input
    struct ReasonInput: View {
        
        /// Properties for fine input
        @Binding var fineInputProperties: FineInputProperties
        
        /// Reason List Data
        @ObservedObject var reasonListData = ListData.reason
        
        /// Indicates if reason selector sheet is shown
        @State var showReasonSelectorSheet = false
        
        var body: some View {
            VStack(spacing: 5) {
                
                TitledContent("Strafe") {
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            
                            // Left of the divider
                            ZStack {
                                
                                // Outline
                                Outline(.left)
                                    .errorMessages($fineInputProperties.fineReasonErrorMessages)
                                
                                // Text
                                Text(fineReason?.reason ?? "Strafe auswählen")
                                    .configurate(size: 20)
                                    .lineLimit(1)
                                    .padding(.horizontal, 15)
                                    .opacity(fineInputProperties.fineReason == nil ? 0.5 : 1)
                                
                            }.frame(width: geometry.size.width * 0.7, height: 50)
                            
                            // Right of divider
                            ZStack {
                                
                                // Outline
                                Outline(.right)
                                    .fillColor(fineReason?.importance.color ?? Color.custom.lightGreen)
                                    .errorMessages($fineInputProperties.fineReasonErrorMessages)
                                
                                // Amount
                                Text(String(describing: fineReason?.amount ?? .zero))
                                    .foregroundColor(plain: fineReason?.importance.color ?? Color.custom.lightGreen)
                                    .font(.text(20))
                                    .lineLimit(1)
                                
                            }.frame(width: geometry.size.width * 0.3, height: 50)
                            
                        }
                    }.toggleOnTapGesture($showReasonSelectorSheet)
                }.contentFrame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                
                // Error Messages
                ErrorMessageView(errorMessages: $fineInputProperties.fineReasonErrorMessages)
                
            }.animation(.default)
                .sheet(isPresented: $showReasonSelectorSheet) {
                    AddNewFineReason(with: fineInputProperties.fineReason) { fineReason in
                        fineInputProperties.fineReason = fineReason
                        fineInputProperties.evaluateFineReasonError()
                    }
                }
        }
        
        /// Fine reason
        var fineReason: FineReasonCustom? {
            fineInputProperties.fineReason?.complete(with: reasonListData.list)
        }
    }
    
    /// Date input
    struct DateInput: View {
        
        /// Properties for fine input
        @Binding var fineInputProperties: FineInputProperties
        
        var body: some View {
            VStack(spacing: 5) {
                    
                TitledContent("Datum") {
                    ZStack {
                        
                        // Date View
                        GeometryReader { geometry in
                            HStack(spacing: 0) {
                                
                                // Left of the divider
                                ZStack {
                                    
                                    // Outline
                                    Outline(.left)
                                        .errorMessages($fineInputProperties.dateErrorMessages)
                                    
                                    // Inside
                                    Text("Datum:")
                                        .configurate(size: 20)
                                        .lineLimit(1)
                                        .padding(.horizontal, 15)
                                        
                                }.frame(width: geometry.size.width * 0.425)
                                
                                // Right of divider
                                ZStack {
                                    
                                    // Outline
                                    Outline(.right)
                                        .fillColor(Color.custom.lightGreen)
                                        .errorMessages($fineInputProperties.dateErrorMessages)
                                    
                                    // Date
                                    Text(fineInputProperties.date.formattedDate.formatted)
                                        .configurate(size: 20)
                                        .lineLimit(1)
                                    
                                }.frame(width: geometry.size.width * 0.575)
                                
                            }
                        }
                        
                        // Date Picker
                        DatePicker("Title", selection: $fineInputProperties.date, in: ...Date(), displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                            .colorMultiply(.black)
                            .opacity(0.011)
                        
                    }
                }.contentFrame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                
                // Error Messages
                ErrorMessageView(errorMessages: $fineInputProperties.dateErrorMessages)
                
            }.animation(.default)
        }
    }
    
    /// Number input
    struct NumberInput: View {
        
        /// Properties for fine input
        @Binding var fineInputProperties: FineInputProperties
        
        var body: some View {
            VStack(spacing: 5) {
            
                TitledContent("Anzahl") {
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            
                            // Left of the divider
                            ZStack {
                                
                                // Outline
                                Outline(.left)
                                    .errorMessages($fineInputProperties.numberErrorMessages)
                                
                                // Inside
                                Text("Anzahl:")
                                    .configurate(size: 20)
                                    .lineLimit(1)
                                    .padding(.horizontal, 15)
                                    
                            }.frame(width: geometry.size.width * 0.425, height: 50)
                            
                            // Right of divider
                            ZStack {
                                
                                // Outline
                                Outline(.right)
                                    .fillColor(Color.custom.lightGreen)
                                    .errorMessages($fineInputProperties.numberErrorMessages)
                                
                                // Number
                                HStack(spacing: 15) {
                                    Text(describing: fineInputProperties.number)
                                        .configurate(size: 20)
                                        .lineLimit(1)
                                    Stepper("Title", value: $fineInputProperties.number, in: 1...99)
                                        .labelsHidden()
                                }
                                
                            }.frame(width: geometry.size.width * 0.575)
                            
                        }
                    }
                }.contentFrame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                
                // Error Messages
                ErrorMessageView(errorMessages: $fineInputProperties.numberErrorMessages)
                
            }.animation(.default)
        }
    }
}
