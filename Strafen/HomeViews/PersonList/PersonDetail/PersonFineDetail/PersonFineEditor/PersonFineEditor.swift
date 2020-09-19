//
//  PersonFineEditor.swift
//  Strafen
//
//  Created by Steven on 16.07.20.
//

import SwiftUI

/// View to edit a person fine
struct PersonFineEditor: View {
    
    /// Edited fine
    let fine: Fine
    
    /// Completion handler
    let completionHandler: (Fine) -> ()
    
    init(fine: Fine, _ completionHandler: @escaping (Fine) -> ()) {
        self.fine = fine
        self.completionHandler = completionHandler
    }
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Input importance
    @State var importance: Fine.Importance = .high
    
    /// Input reason
    @State var reason = ""
    
    /// Input amount
    @State var amount: Euro = .zero
    
    /// Input amount string
    @State var amountString = Euro.zero.stringValue
    
    /// Input date
    @State var date = Date()
    
    /// Input number
    @State var number = 1
    
    /// Id of selected template
    @State var templateId: UUID?
    
    /// Indicated if amount keyboard is on screen
    @State var isAmountKeyboardOnScreen = false
    
    /// Indicated if advanced sheet is shown
    @State var advancedSheetShowing = false
    
    /// Indicated if template sheet is shown
    @State var templateSheetShowing = false
    
    /// Indicates if delete button is pressed and shows the delete alert
    @State var showDeleteAlert = false
    
    /// Indicates if confirm button is pressed and shows the confirm alert
    @State var showConfirmAlert = false
    
    /// State of data task connection
    @State var connectionStateDelete: ConnectionState = .passed
    
    /// Indicates if no connection alert is shown
    @State var noConnectionAlertDelete = false
    
    /// State of data task connection
    @State var connectionStateUpdate: ConnectionState = .passed
    
    /// Indicates if no connection alert is shown
    @State var noConnectionAlertUpdate = false
    
    /// Screen size
    @State var screenSize: CGSize?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                // Bar to wipe sheet down
                SheetBar()
                
                // Title
                Header("Strafe Ändern")
                
                VStack(spacing: 0){
                    Spacer()
                    
                    // Importance changer
                    ImportanceChanger(importance: $importance)
                        .frame(width: 258, height: 25)
                    
                    Spacer()
                    
                    // Reason
                    CustomTextField("Grund", text: $reason)
                        .frame(width: 345, height: 50)
                        .alert(isPresented: $noConnectionAlertDelete) {
                            Alert(title: Text("Kein Internet"), message: Text("Für diese Aktion benötigst du eine Internetverbindung."), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Erneut versuchen"), action: handleFineDelete))
                        }
                    
                    Spacer()
                    
                    // Amount
                    HStack(spacing: 0) {
                        
                        // Number
                        if number != 1 {
                            Text("\(number) *")
                                .frame(height: 50)
                                .foregroundColor(.textColor)
                                .font(.text(25))
                                .lineLimit(1)
                        }
                        
                        // Text Field
                        CustomTextField("Betrag", text: $amountString, keyboardType: .decimalPad, keyboardOnScreen: $isAmountKeyboardOnScreen) {
                            amount = amountString.euroValue
                            amountString = amount.stringValue
                        }.frame(width: 148, height: 50)
                            .padding(.leading, 15)
                        
                        // € - Sign
                        Text("€")
                            .frame(height: 50)
                            .foregroundColor(.textColor)
                            .font(.text(25))
                            .lineLimit(1)
                        
                        // Done button
                        if isAmountKeyboardOnScreen {
                            Text("Fertig")
                                .foregroundColor(Color.custom.darkGreen)
                                .font(.text(25))
                                .lineLimit(1)
                                .padding(.leading, 15)
                                .onTapGesture {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                        }
                        
                    }.alert(isPresented: $showDeleteAlert) {
                        Alert(title: Text("Strafe Löschen"), message: Text("Möchtest du diese Strafe wirklich löschen?"), primaryButton: .cancel(Text("Abbrechen")), secondaryButton: .destructive(Text("Löschen"), action: handleFineDelete))
                    }
                    
                    // Date
                    Text("am \(date.formattedDate.formatted)")
                        .font(.text(25))
                        .foregroundColor(.textColor)
                        .lineLimit(1)
                        .padding(.top, 30)
                
                    Spacer()
                
                    // Advanced and template button
                    HStack(spacing: 0) {
                        Spacer()
                        
                        // Advanced button
                        ZStack {
                            
                            // Outline
                            Outline()
                                .fillColor(Color.custom.lightGreen)
                            
                            // Text
                            Text("Erweitert")
                                .foregroundColor(settings.style == .default ? .textColor : Color.custom.lightGreen)
                                .font(.text(15))
                                .lineLimit(1)
                            
                        }.frame(width: 150, height: 35)
                            .onTapGesture {
                                advancedSheetShowing = true
                            }
                            .sheet(isPresented: $advancedSheetShowing) {
                                PersonFineAdvanced(date: $date, number: $number)
                            }
                        
                        Spacer()
                        
                        // Template button
                        ZStack {
                            
                            // Outline
                            Outline()
                                .fillColor(Color.custom.yellow)
                            
                            // Text
                            Text("Strafe Auswählen")
                                .foregroundColor(settings.style == .default ? .textColor : Color.custom.yellow)
                                .font(.text(15))
                                .lineLimit(1)
                            
                        }.frame(width: 150, height: 35)
                            .onTapGesture {
                                templateSheetShowing = true
                            }
                            .sheet(isPresented: $templateSheetShowing) {
                                PersonFineTemplate { template in
                                    reason = template.reason
                                    amount = template.amount
                                    amountString = template.amount.stringValue
                                    importance = template.importance
                                    templateId = template.id
                                }
                            }
                        
                        Spacer()
                    }.alert(isPresented: $noConnectionAlertUpdate) {
                        Alert(title: Text("Kein Internet"), message: Text("Für diese Aktion benötigst du eine Internetverbindung."), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Erneut versuchen"), action: handleFineUpdate))
                    }
                    
                    Spacer()
                }
                
                // Delete / Confirm Button
                DeleteConfirmButton(connectionStateDelete: $connectionStateDelete, connectionStateConfirm: $connectionStateUpdate) {
                    showDeleteAlert = true
                } confirmButtonHandler: {
                    var fineReason: FineReason = FineReasonCustom(reason: reason, amount: amount, importance: importance)
                    if let templateId = templateId {
                        if let template = ListData.reason.list?.first(where: { $0.id == templateId }) {
                            if reason == template.reason && amount == template.amount && importance == template.importance {
                                fineReason = FineReasonTemplate(templateId: templateId)
                            }
                        }
                    }
                    let editedFine = Fine(personId: fine.personId, date: date.formattedDate, payed: fine.payed, number: number, id: fine.id, fineReason: fineReason)
                    if fine == editedFine {
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        showConfirmAlert = true
                    }
                }.padding(.bottom, 50)
                    .alert(isPresented: $showConfirmAlert) {
                        if reason.isEmpty {
                            return Alert(title: Text("Keinen Grund Angegeben"), message: Text("Bitte gebe einen Grund für diese Strafe ein."), dismissButton: .default(Text("Verstanden")))
                        } else if amount == .zero {
                            return Alert(title: Text("Betrag ist Null"), message: Text("Bitte gebe einen Bertag ein, der nicht gleich Null ist."), dismissButton: .default(Text("Verstanden")))
                        }
                        return Alert(title: Text("Strafe Ändern"), message: Text("Möchtest du diese Strafe wirklich ändern?"), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Bestätigen"), action: handleFineUpdate))
                    }
            }.frame(size: screenSize ?? geometry.size)
                .onAppear {
                    screenSize = geometry.size
                }
        }.onAppear {
            importance = fine.fineReason.importance
            amount = fine.fineReason.amount
            reason = fine.fineReason.reason
            amountString = amount.stringValue
            templateId = (fine.fineReason as? FineReasonTemplate)?.templateId
            date = fine.date.date
            number = fine.number
        }
    }
    
    /// Hadles fine delete
    func handleFineDelete() {
        connectionStateDelete = .loading
        let changeItem = ServerListChange(changeType: .delete, item: fine)
        Changer.shared.change(changeItem) {
            connectionStateDelete = .passed
            presentationMode.wrappedValue.dismiss()
        } failedHandler: {
            connectionStateDelete = .failed
            noConnectionAlertDelete = true
        }
    }
    
    /// Handle fine update
    func handleFineUpdate() {
        var fineReason: FineReason = FineReasonCustom(reason: reason, amount: amount, importance: importance)
        if let templateId = templateId {
            if let template = ListData.reason.list?.first(where: { $0.id == templateId }) {
                if reason == template.reason && amount == template.amount && importance == template.importance {
                    fineReason = FineReasonTemplate(templateId: templateId)
                }
            }
        }
        let editedFine = Fine(personId: fine.personId, date: date.formattedDate, payed: fine.payed, number: number, id: fine.id, fineReason: fineReason)
        connectionStateUpdate = .loading
        let changeItem = ServerListChange(changeType: .update, item: editedFine)
        Changer.shared.change(changeItem) {
            connectionStateUpdate = .passed
            completionHandler(editedFine)
            presentationMode.wrappedValue.dismiss()
        } failedHandler: {
            connectionStateUpdate = .failed
            noConnectionAlertUpdate = true
        }
    }
}
