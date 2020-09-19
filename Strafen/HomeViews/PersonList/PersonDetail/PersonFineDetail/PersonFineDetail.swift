//
//  PersonFineDetail.swift
//  Strafen
//
//  Created by Steven on 15.07.20.
//

import SwiftUI

/// Detail of a person fine
struct PersonFineDetail: View {
    
    /// Name of associated person
    let personName: PersonName
    
    /// Contains details of the fine
    @State var fine: Fine
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    ///Dismiss handler
    @Binding var dismissHandler: (() -> ())?
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Indicates if to payed is pressed
    @State var showAlertToPayed = false
    
    /// Indicates if to unpayed is pressed
    @State var showAlertToUnpayed = false
    
    /// State of data task connection
    @State var connectionStateToPayed: ConnectionState = .passed
    
    /// Indicates if no connection alert is shown
    @State var noConnectionAlertToPayed = false
    
    /// State of data task connection
    @State var connectionStateToUnpayed: ConnectionState = .passed
    
    /// Indicates if no connection alert is shown
    @State var noConnectionAlertToUnpayed = false
    
    var body: some View {
        ZStack {
            
            // Background color
            colorScheme.backgroundColor
            
            // Back and edit button
            BackAndEditButton {
                PersonFineEditor(fine: fine) { newFine in
                    fine = newFine
                }
            }
            
            // Fine Detail
            VStack(spacing: 0) {
                
                VStack(spacing: 0) {
                    
                    // Title
                    HStack(spacing: 0) {
                        Text("Strafe von:")
                            .foregroundColor(.textColor)
                            .font(.text(20))
                            .padding(.leading, 10)
                            .padding(.top, 40)
                        Spacer()
                    }
                    
                    // Person Name
                    Text(personName.formatted)
                        .foregroundColor(.textColor)
                        .font(.text(35))
                        .padding(.horizontal, 25)
                        .lineLimit(1)
                    
                    // Top Underline
                    HStack {
                        Rectangle()
                            .frame(width: 300, height: 2)
                            .border(settings.style == .default ? Color.custom.darkGreen : (colorScheme == .dark ? Color.plain.lightGray : Color.plain.darkGray), width: 1)
                        Spacer()
                    }.padding(.top, 10)
                    
                    // Bottom Underline
                    HStack {
                        Rectangle()
                            .frame(width: 275, height: 2)
                            .border(settings.style == .default ? Color.custom.darkGreen : (colorScheme == .dark ? Color.plain.lightGray : Color.plain.darkGray), width: 1)
                        Spacer()
                    }.padding(.top, 5)
                }.padding(.top, 40)
                
                Spacer()
                
                // Reason
                Text(fine.fineReason.reason)
                    .foregroundColor(.textColor)
                    .font(.text(25))
                    .padding(.horizontal, 25)
                    .lineLimit(1)
                
                Spacer()
                
                // Amount
                VStack(spacing: 0) {
                    
                    // Original Amount
                    HStack(spacing: 0) {
                        if fine.number != 1 {
                            Text("\(fine.number) *")
                                .foregroundColor(.textColor)
                                .font(.text(50))
                                .padding(.leading, 25)
                                .padding(.top, 20)
                                .lineLimit(1)
                        }
                        
                        Text(String(describing: fine.fineReason.amount))
                            .foregroundColor(.textColor)
                            .font(.text(50))
                            .padding(.horizontal, 25)
                            .padding(.top, 20)
                            .lineLimit(1)
                    }
                    
                    // Late payment interest
                    if let latePaymentInterest = fine.latePaymentInterest, latePaymentInterest != .zero {
                        Text("+ \(String(describing: latePaymentInterest)) Verzugszinsen")
                            .font(.text(25))
                            .foregroundColor(.textColor)
                            .lineLimit(1)
                            .padding(.top, 5)
                    }
                    
                }
                
                Spacer()
                
                // Date
                Text(fine.date.formatted)
                    .foregroundColor(.textColor)
                    .font(.text(25))
                    .padding(.horizontal, 25)
                    .lineLimit(1)
                
                Spacer()
                
                // Payed Display
                ZStack {
                    
                    HStack(spacing: 0) {
                        Spacer()
                            .alert(isPresented: $noConnectionAlertToPayed) {
                                Alert(title: Text("Kein Internet"), message: Text("Für diese Aktion benötigst du eine Internetverbindung."), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Erneut versuchen"), action: handleSaveToPayed))
                            }
                        
                        // Left of the divider
                        Outline(.left)
                            .fillColor(fine.fineReason.importance.color, onlyDefault: false)
                            .frame(width: 100, height: 50)
                            .onTapGesture {
                                if settings.person!.isCashier && fine.payed.boolValue {
                                    showAlertToUnpayed = true
                                }
                            }
                            .alert(isPresented: $showAlertToUnpayed) {
                                Alert(title: Text("Strafe Ändern"), message: Text("Möchtest du diese Strafe wirklich als unbezahlt markieren?"), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Bestätigen"), action: handleSaveToUnpayed))
                            }
                        
                        // Right of the divider
                        Outline(.right)
                            .fillColor(Color.custom.lightGreen, onlyDefault: false)
                            .frame(width: 100, height: 50)
                            .onTapGesture {
                                if settings.person!.isCashier && fine.payed == .unpayed {
                                    showAlertToPayed = true
                                }
                            }
                            .alert(isPresented: $showAlertToPayed) {
                                Alert(title: Text("Strafe Ändern"), message: Text("Möchtest du diese Strafe wircklich als bezahlt markieren?"), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Bestätigen"), action: handleSaveToPayed))
                            }
                        
                        Spacer()
                            .alert(isPresented: $noConnectionAlertToUnpayed) {
                                Alert(title: Text("Kein Internet"), message: Text("Für diese Aktion benötigst du eine Internetverbindung."), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Erneut versuchen"), action: handleSaveToUnpayed))
                            }
                    }
                    
                    // Indicator
                    RoundedCorners()
                        .strokeColor(settings.style == .default ? Color.custom.gray : Color.plain.strokeColor(colorScheme))
                        .lineWidth(2.5)
                        .radius(2.5)
                        .frame(width: 33, height: 2.5)
                        .offset(x: fine.payed.boolValue ? 50 : -50)
                    
                    // Progress View of to unpayed
                    if connectionStateToUnpayed == .loading {
                        ProgressView()
                            .offset(x: -50)
                    }
                    
                    // Progress View of to payed
                    if connectionStateToPayed == .loading {
                        ProgressView()
                            .offset(x: 50)
                    }
                    
                }
                
                Spacer()
            }
            
        }.edgesIgnoringSafeArea(.all)
            .navigationTitle("Title")
            .navigationBarHidden(true)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                dismissHandler = {
                    presentationMode.wrappedValue.dismiss()
                }
            }
    }
    
    /// Handles save to payed
    func handleSaveToPayed() {
        connectionStateToPayed = .loading
        var editedFine = fine
        let date = Date()
        editedFine.payed = .payed(date: date)
        let changeItem = ServerListChange(changeType: .update, item: editedFine)
        Changer.shared.change(changeItem) {
            connectionStateToPayed = .passed
            withAnimation {
                fine.payed = .payed(date: date)
            }
        } failedHandler: {
            connectionStateToPayed = .failed
            noConnectionAlertToPayed = true
        }
    }
    
    /// Handles save to unpayed
    func handleSaveToUnpayed() {
        connectionStateToUnpayed = .loading
        var editedFine = fine
        editedFine.payed = .unpayed
        let changeItem = ServerListChange(changeType: .update, item: editedFine)
        Changer.shared.change(changeItem) {
            connectionStateToUnpayed = .passed
            withAnimation {
                fine.payed = .unpayed
            }
        } failedHandler: {
            connectionStateToUnpayed = .failed
            noConnectionAlertToUnpayed = true
        }
    }
}
