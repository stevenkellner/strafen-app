//
//  AddNewFine.swift
//  Strafen
//
//  Created by Steven on 17.07.20.
//

import SwiftUI

/// View to add a new fine
struct AddNewFine: View {
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Active home tab
    @ObservedObject var homeTabs = HomeTabs.shared
    
    /// Person List Data
    @ObservedObject var personListData = ListData.person
    
    /// Id of associated person
    @State var personId: UUID?
    
    /// Fine Reason
    @State var fineReason: FineReason?
    
    /// Input date
    @State var date = Date()
    
    /// Input number
    @State var number = 1
    
    /// Indicates if person selector sheet is shown
    @State var showPersonSelectorSheet = false
    
    /// Indicates if reason selector sheet is shown
    @State var showReasonSelectorSheet = false
    
    /// Indicates if confirm button is pressed and shows the confirm alert
    @State var showConfirmAlert = false
    
    /// State of data task connection
    @State var connectionState: ConnectionState = .passed
    
    /// Indicates if no connection alert is shown
    @State var noConnectionAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Header
            Header("Strafen Hinzufügen")
            
            VStack(spacing: 0) {
                Spacer()
                
                // Person
                VStack(spacing: 0) {
                    
                    // Title
                    HStack(spacing: 0) {
                        Text("Zugehörige Person:")
                            .foregroundColor(.textColor)
                            .font(.text(20))
                            .padding(.leading, 10)
                        Spacer()
                    }
                    
                    // Person Field
                    ZStack {
                        
                        // Outline
                        Outline()
                        
                        // Text
                        Text(personId == nil ? "Person auswählen" : personListData.list!.first(where: { $0.id == personId! })!.personName.formatted)
                            .foregroundColor(.textColor)
                            .font(.text(20))
                            .lineLimit(1)
                            .padding(.horizontal, 15)
                            .opacity(personId == nil ? 0.5 : 1)
                        
                    }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                        .padding(.top, 5)
                        .onTapGesture {
                            showPersonSelectorSheet = true
                        }
                        .sheet(isPresented: $showPersonSelectorSheet) {
                            AddNewFinePerson { personId in
                                self.personId = personId
                            }
                        }
                    
                }
                
                Spacer()

                // Reason
                HStack(spacing: 0) {
                    
                    // Left of the divider
                    ZStack {
                        
                        // Outline
                        Outline(.left)
                        
                        // Text
                        Text(fineReason?.reason ?? "Strafe auswählen")
                            .foregroundColor(.textColor)
                            .font(.text(20))
                            .lineLimit(1)
                            .padding(.horizontal, 15)
                            .opacity(fineReason == nil ? 0.5 : 1)
                            
                    }.frame(width: UIScreen.main.bounds.width * 0.675, height: 50)
                    
                    // Right of divider
                    ZStack {
                        
                        // Outline
                        Outline(.right)
                            .fillColor(fineReason?.importance.color ?? Color.custom.lightGreen)
                        
                        // Amount
                        Text(String(describing: fineReason?.amount ?? .zero))
                            .foregroundColor(settings.style == .default ? .textColor : fineReason?.importance.color ?? Color.custom.lightGreen)
                            .font(.text(20))
                            .lineLimit(1)
                        
                    }.frame(width: UIScreen.main.bounds.width * 0.275, height: 50)
                    
                }
                    .onTapGesture {
                        showReasonSelectorSheet = true
                    }
                    .sheet(isPresented: $showReasonSelectorSheet) {
                        AddNewFineReason(fineReason: fineReason) { fineReason in
                            self.fineReason = fineReason
                        }
                    }
                
                Spacer()
                
                // Date
                ZStack {
                    
                    // Date View
                    HStack(spacing: 0) {
                        
                        // Left of the divider
                        ZStack {
                            
                            // Outline
                            Outline(.left)
                            
                            // Inside
                            Text("Datum:")
                                .foregroundColor(.textColor)
                                .font(.text(20))
                                .lineLimit(1)
                                .padding(.horizontal, 15)
                                
                        }.frame(width: UIScreen.main.bounds.width * 0.4, height: 50)
                        
                        // Right of divider
                        ZStack {
                            
                            // Outline
                            Outline(.right)
                                .fillColor(Color.custom.lightGreen)
                            
                            // Date
                            Text(date.formattedDate.formatted)
                                .foregroundColor(.textColor)
                                .font(.text(20))
                                .lineLimit(1)
                            
                        }.frame(width: UIScreen.main.bounds.width * 0.55, height: 50)
                        
                    }
                    
                    // Date Picker
                    DatePicker("Title", selection: $date, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                        .colorMultiply(.black)
                        .frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                        .opacity(0.011)
                    
                }
                
                Spacer()
                
                // Number
                HStack(spacing: 0) {
                    
                    // Left of the divider
                    ZStack {
                        
                        // Outline
                        Outline(.left)
                        
                        // Inside
                        Text("Anzahl:")
                            .foregroundColor(.textColor)
                            .font(.text(20))
                            .lineLimit(1)
                            .padding(.horizontal, 15)
                            
                    }.frame(width: UIScreen.main.bounds.width * 0.4, height: 50)
                    
                    // Right of divider
                    ZStack {
                        
                        // Outline
                        Outline(.right)
                            .fillColor(Color.custom.lightGreen)
                        
                        // Number
                        HStack(spacing: 15) {
                            Text("\(number)")
                                .foregroundColor(.textColor)
                                .font(.text(20))
                                .lineLimit(1)
                            Stepper("Title", value: $number, in: 1...99)
                                .labelsHidden()
                        }
                        
                    }.frame(width: UIScreen.main.bounds.width * 0.55, height: 50)
                    
                }
                
                Spacer()
            }.alert(isPresented: $noConnectionAlert) {
                Alert(title: Text("Kein Internet"), message: Text("Für diese Aktion benötigst du eine Internetverbindung."), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Erneut versuchen"), action: handleSave))
            }
            
            CancelConfirmButton {
                personId = nil
                fineReason = nil
                date = Date()
                number = 1
                presentationMode.wrappedValue.dismiss()
            } confirmButtonHandler: {
                showConfirmAlert = true
            }.padding(.bottom, 30)
                .alert(isPresented: $showConfirmAlert) {
                    if personId == nil {
                        return Alert(title: Text("Keine zugehörige Person"), message: Text("Bitte gebe eine zugehörige Person für diese Strafe ein."), dismissButton: .default(Text("Verstanden")))
                    } else if fineReason == nil {
                        return Alert(title: Text("Keine Strafe Angegeben"), message: Text("Bitte gebe einen Grund für diese Strafe ein."), dismissButton: .default(Text("Verstanden")))
                    }
                    return Alert(title: Text("Strafe Hinzufügen"), message: Text("Möchtest du diese Strafe wirklich hinzufügen?"), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Bestätigen"), action: handleSave))
                }

        }
    }
    
    /// Handles fine saving
    func handleSave() {
        connectionState = .loading
        let newFine = Fine(personId: personId!, date: date.formattedDate, payed: .unpayed, number: number, id: UUID(), fineReason: fineReason!)
        ListChanger.shared.change(.add, item: newFine) { taskState in
            if taskState == .passed {
                connectionState = .passed
                personId = nil
                fineReason = nil
                date = Date()
                number = 1
                DispatchQueue.main.async {
                    homeTabs.active = .personList
                }
                presentationMode.wrappedValue.dismiss()
            } else {
                connectionState = .failed
                noConnectionAlert = true
            }
        }
    }
}
