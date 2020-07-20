//
//  AddNewFineReason.swift
//  Strafen
//
//  Created by Steven on 17.07.20.
//

import SwiftUI

/// View to select reason for new fine
struct AddNewFineReason: View {
    
    /// Previous selected Fine Reason
    let oldFineReason: FineReason?
    
    /// Handles reason selection
    let completionHandler: (FineReason) -> ()
    
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
    
    /// Id of selected template
    @State var templateId: UUID?
    
    /// Indicated if amount keyboard is on screen
    @State var isAmountKeyboardOnScreen = false
    
    /// Indicated if template sheet is shown
    @State var templateSheetShowing = false
    
    /// Indicates if confirm button is pressed and shows the confirm alert
    @State var showConfirmAlert = false
    
    init(fineReason: FineReason?, completionHandler: @escaping (FineReason) -> ()) {
        oldFineReason = fineReason
        self.completionHandler = completionHandler
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Bar to wipe sheet down
            SheetBar()
            
            // Title
            Header("Strafe Auswählen")
            
            VStack(spacing: 0) {
                Spacer()
                
                // Importance changer
                ImportanceChanger(importance: $importance)
                    .frame(width: UIScreen.main.bounds.width * 0.7, height: 25)
                
                Spacer()
                
                // Reason
                CustomTextField("Grund", text: $reason)
                    .frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                
                Spacer()
                
                // Amount
                HStack(spacing: 0) {
                    
                    // Text Field
                    CustomTextField("Betrag", text: $amountString, keyboardType: .decimalPad, keyboardOnScreen: $isAmountKeyboardOnScreen) {
                        amount = amountString.euroValue
                        amountString = amount.stringValue
                    }.frame(width: UIScreen.main.bounds.width * 0.45, height: 50)
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
                    
                }
                
                Spacer()
                
                // Template button
                HStack(spacing: 0) {
                    Spacer()
                    Spacer()
                    Spacer()
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
                }
                
                Spacer()
            }
            
            CancelConfirmButton {
                presentationMode.wrappedValue.dismiss()
            } confirmButtonHandler: {
                if reason.isEmpty || amount == .zero {
                    showConfirmAlert = true
                } else {
                    var fineReason: FineReason = FineReasonCustom(reason: reason, amount: amount, importance: importance)
                    if let templateId = templateId {
                        if let template = ListData.reason.list?.first(where: { $0.id == templateId }) {
                            if reason == template.reason && amount == template.amount && importance == template.importance {
                                fineReason = FineReasonTemplate(templateId: templateId)
                            }
                        }
                    }
                    completionHandler(fineReason)
                    presentationMode.wrappedValue.dismiss()
                }
            }.padding(.bottom, 50)
                .alert(isPresented: $showConfirmAlert) {
                    if reason.isEmpty {
                        return Alert(title: Text("Keinen Grund Angegeben"), message: Text("Bitte gebe einen Grund für diese Strafe ein."), dismissButton: .default(Text("Verstanden")))
                    }
                    return Alert(title: Text("Betrag ist Null"), message: Text("Bitte gebe einen Bertag ein, der nicht gleich Null ist."), dismissButton: .default(Text("Verstanden")))
                }

        }.onAppear {
            reason = oldFineReason?.reason ?? ""
            amount = oldFineReason?.amount ?? .zero
            amountString = amount.stringValue
            importance = oldFineReason?.importance ?? .high
        }
    }
}
