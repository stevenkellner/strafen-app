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
    @State var amountString = ""
    
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
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Bar to wipe sheet down
            SheetBar()
            
            // Title
            Header("Strafe Ändern")
            
            // Importance changer
            ImportanceChanger(importance: $importance)
                .frame(width: 258, height: 25)
                .padding(.top, 50)
            
            // Reason
            CustomTextField("Grund", text: $reason)
                .frame(width: 345, height: 50)
                .padding(.top, 30)
            
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
                    .padding(.leading, 5)
                
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
                
            }.padding(.top, 30)
            
            // Date
            Text("am \(FormattedDate(date: date).formattedDate)")
                .font(.text(25))
                .foregroundColor(.textColor)
                .lineLimit(1)
                .padding(.top, 30)
            
            // Advanced and template button
            HStack(spacing: 15) {
                
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
                
            }.padding(.top, 30)
            
            Spacer()
                .alert(isPresented: $showDeleteAlert) {
                    Alert(title: Text("Strafe Löschen"), message: Text("Möchtest du diese Strafe wirklich löscehn?"), primaryButton: .cancel(Text("Abbrechen")), secondaryButton: .destructive(Text("Löschen"), action: {
                        // TODO delete fine
                        presentationMode.wrappedValue.dismiss()
                    }))
                }
            
            // Delete / Confirm Button
            DeleteConfirmButton {
                showDeleteAlert = true
            } confirmButtonHandler: {
                print(date, number)
                var editedFine = Fine(personId: fine.personId, date: FormattedDate(date: date), reason: reason, amount: amount, payed: fine.payed, number: number, importance: importance, id: fine.id, templateId: nil)
                if let templateId = templateId {
                    if let template = ListData.reason.list?.first(where: { $0.id == templateId }) {
                        if reason == template.reason && amount == template.amount && importance == template.importance {
                            editedFine.amount = nil
                            editedFine.reason = nil
                            editedFine.importance = nil
                            editedFine.templateId = templateId
                        }
                    }
                }
                if fine != editedFine {
                    showConfirmAlert = true
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }.padding(.bottom, 50)
                .alert(isPresented: $showConfirmAlert) {
                    if reason.isEmpty {
                        return Alert(title: Text("Keinen Grund Angegeben"), message: Text("Bitte gebe einen Grund für diese Strafe ein."), dismissButton: .default(Text("Verstanden")))
                    } else if amount == .zero {
                        return Alert(title: Text("Betrag ist Null"), message: Text("Bitte gebe einen Bertag ein, der nicht gleich Null ist."), dismissButton: .default(Text("Verstanden")))
                    }
                    return Alert(title: Text(""), message: Text(""), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Bestätigen"), action: {
                        var editedFine = Fine(personId: fine.personId, date: FormattedDate(date: date), reason: reason, amount: amount, payed: fine.payed, number: number, importance: importance, id: fine.id, templateId: nil)
                        if let templateId = templateId {
                            if let template = ListData.reason.list?.first(where: { $0.id == templateId }) {
                                if reason == template.reason && amount == template.amount && importance == template.importance {
                                    editedFine.amount = nil
                                    editedFine.reason = nil
                                    editedFine.importance = nil
                                    editedFine.templateId = templateId
                                }
                            }
                        }
                        // TODO save fine
                        presentationMode.wrappedValue.dismiss()
                    }))
                }
            
        }.onAppear {
            importance = fine.wrappedImportance
            amount = fine.wrappedAmount
            reason = fine.wrappedReason
            amountString = amount.stringValue
            date = fine.date.date
            number = fine.number
        }
    }
}
