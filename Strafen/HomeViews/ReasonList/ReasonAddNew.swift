//
//  ReasonAddNew.swift
//  Strafen
//
//  Created by Steven on 17.07.20.
//

import SwiftUI

/// View to add a new reason
struct ReasonAddNew: View {
    
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
    
    /// Indicated if amount keyboard is on screen
    @State var isAmountKeyboardOnScreen = false
    
    /// Indicates if confirm button is pressed and shows the confirm alert
    @State var showConfirmAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Bar to wipe sheet down
            SheetBar()
            
            // Title
            Header("Vorlage Hinzufügen")
            
            // Importance changer
            ImportanceChanger(importance: $importance)
                .frame(width: 258, height: 25)
                .padding(.top, 75)
            
            // Reason
            CustomTextField("Grund", text: $reason)
                .frame(width: 345, height: 50)
                .padding(.top, 50)
            
            // Amount
            HStack(spacing: 0) {
                
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
            
            Spacer()
            
            // Cancel / Confirm button
            CancelConfirmButton {
                presentationMode.wrappedValue.dismiss()
            } confirmButtonHandler: {
                showConfirmAlert = true
            }.padding(.bottom, 50)
                .alert(isPresented: $showConfirmAlert) {
                    if reason.isEmpty {
                        return Alert(title: Text("Keinen Grund Angegeben"), message: Text("Bitte gebe einen Grund für diese Vorlage ein."), dismissButton: .default(Text("Verstanden")))
                    } else if amount == .zero {
                        return Alert(title: Text("Betrag ist Null"), message: Text("Bitte gebe einen Bertag ein, der nicht gleich Null ist."), dismissButton: .default(Text("Verstanden")))
                    }
                    return Alert(title: Text("Vorlage Hinzufügen"), message: Text("Möchtest du diese Vorlage wirklich hinzufügen?"), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Bestätigen"), action: {
                        let _ = Reason(reason: reason, id: UUID(), amount: amount, importance: importance)
                        // TODO save reason
                        presentationMode.wrappedValue.dismiss()
                    }))
                }
            
        }
    }
}
