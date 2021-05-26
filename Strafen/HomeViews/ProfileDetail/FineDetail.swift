//
//  FineDetail.swift
//  Strafen
//
//  Created by Steven on 11/26/20.
//

import SwiftUI

/// Detail of a fine
struct FineDetail: View {
    
    /// Fine
    @State var fine: Fine
    
    ///Dismiss handler
    @Binding var dismissHandler: DismissHandler
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Fine List Data
    @ObservedObject var fineListData = ListData.fine
    
    /// Person List Data
    @ObservedObject var personListData = ListData.person
    
    /// Reason List Data
    @ObservedObject var reasonListData = ListData.reason
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            
            // Background color
            colorScheme.backgroundColor
            
            // Back and edit button
            BackAndEditButton {
                FineEditor(fine: fine)
            }
            // Fine Detail
            VStack(spacing: 0) {
                
                // Title
                VStack(spacing: 10) {
                    
                    HStack(spacing: 0) {
                        Text("Strafe von:")
                            .configurate(size: 20)
                            .padding(.leading, 10)
                            .lineLimit(1)
                        Spacer()
                    }
                    
                    // Person Name
                    HStack(spacing: 0) {
                        Text(associatedPersonName)
                            .configurate(size: 35)
                            .padding(.horizontal, 25)
                            .lineLimit(1)
                        Spacer()
                    }
                    
                    // Underlines
                    Underlines()
                        
                }.padding(.top, 80)
                
                Spacer()
                
                // Reason
                Text(fine.fineReason.reason(with: reasonListData.list))
                    .configurate(size: 25)
                    .padding(.horizontal, 25)
                    .lineLimit(1)
                
                Spacer()
                
                // Amount
                AmountText(fine: $fine)
                
                Spacer()
                
                // Date
                Text(fine.date.formattedLong)
                    .configurate(size: 25)
                    .padding(.horizontal, 25)
                    .lineLimit(1)
                
                Spacer()
                
                // Payed display
                VStack(spacing: 5) {
                    PayedDisplay(fine: $fine)
                    
                    if fine.isSettled {
                        Text("Zahlung wird bearbeitet")
                            .configurate(size: 25)
                            .padding(.horizontal, 25)
                            .lineLimit(1)
                    } else if fine.payed.payedInApp {
                        Text("InApp bezahlt")
                            .configurate(size: 25)
                            .padding(.horizontal, 25)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
            }
            
        }.maxFrame.setDismissHandler($dismissHandler)
            .onReceive(fineListData.$list) { fineList in
                if let newFine = fineList?.first(where: { $0.id == fine.id }) {
                    fine = newFine
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }
    }
    
    /// Name of associated person
    var associatedPersonName: String {
        personListData.list?.first(where: { $0.id == fine.assoiatedPersonId })?.name.formatted ?? "Unknown"
    }
    
    /// Amount text
    struct AmountText: View {
        
        /// Fine
        @Binding var fine: Fine
        
        /// Reason List Data
        @ObservedObject var reasonListData = ListData.reason
        
        var body: some View {
            VStack(spacing: 5) {
                
                // Original Amount
                HStack(spacing: 25) {
                    if fine.number != 1 {
                        Text("\(fine.number) *")
                            .configurate(size: 50)
                            .lineLimit(1)
                    }
                    
                    Text(describing: fine.fineReason.amount(with: reasonListData.list))
                        .configurate(size: 50)
                        .lineLimit(1)
                    
                }.padding(.horizontal, 25)
                
                // Late payment interest
                if let latePaymentInterest = fine.latePaymentInterestAmount(with: reasonListData.list), latePaymentInterest != .zero {
                    Text("+ \(String(describing: latePaymentInterest)) Verzugszinsen")
                        .configurate(size: 25)
                        .padding(.horizontal, 25)
                        .lineLimit(1)
                }
                
            }
        }
    }
    
    /// Payed display
    struct PayedDisplay: View {
        
        /// Fine
        @Binding var fine: Fine
        
        /// Reason List Data
        @ObservedObject var reasonListData = ListData.reason
        
        /// Observed Object that contains all settings of the app of this device
        @ObservedObject var settings = Settings.shared
        
        /// State of data task connection
        @State var connectionStateToPayed: ConnectionState = .passed
        
        /// State of data task connection
        @State var connectionStateToUnpayed: ConnectionState = .passed
        
        /// Error messages
        @State var errorMessages: ErrorMessages? = nil
        
        var body: some View {
            VStack(spacing: 5) {
                ZStack {
                    
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            
                            // Left of the divider
                            ZStack {
                                
                                // Outline
                                Outline(.left)
                                    .fillColor(fine.fineReason.importance(with: reasonListData.list).color, onlyDefault: false)
                                    .onTapGesture(perform: handleSaveToUnpayed)
                             
                                // Progress view
                                if connectionStateToUnpayed == .loading {
                                    ProgressView()
                                }
                                
                            }.frame(width: geometry.size.width * 0.5)
                            
                            // Right of the divider
                            ZStack {
                                
                                // Outline
                                Outline(.right)
                                    .fillColor(Color.custom.lightGreen, onlyDefault: false)
                                    .onTapGesture(perform: handleSaveToPayed)
                                
                                // Progress view
                                if connectionStateToPayed == .loading {
                                    ProgressView()
                                }
                                
                            }.frame(width: geometry.size.width * 0.5)
                            
                        }
                    }.frame(width: 200, height: 50)
                    
                    // Indicator
                    Indicator(width: 33)
                        .offset(x: fine.isPayed ? 50 : -50)
                    
                }
                
                // Error message
                ErrorMessageView(errorMessages: $errorMessages)
                
            }
        }
        
        /// Handles save to unpayed
        func handleSaveToUnpayed() {
            guard connectionStateToUnpayed != .loading,
                let signedInPerson = settings.person,
                  signedInPerson.isCashier,
                  fine.isPayed,
                  !fine.isSettled,
                  !fine.payed.payedInApp else { return }
            connectionStateToUnpayed = .loading
            errorMessages = nil
            
            let payed: Payed = .unpayed
            let callItem = ChangeFinePayedCall(clubId: signedInPerson.clubProperties.id, fineId: fine.id, payed: payed)
            FunctionCaller.shared.call(callItem) { _ in
                connectionStateToUnpayed = .passed
                fine.payed = payed
            } failedHandler: { _ in
                connectionStateToUnpayed = .failed
                errorMessages = .internalErrorSave(code: 1)
            }
        }
        
        /// Handles save to payed
        func handleSaveToPayed() {
            guard connectionStateToPayed != .loading,
                let signedInPerson = settings.person,
                  signedInPerson.isCashier,
                  !fine.isPayed,
                  !fine.isSettled,
                  !fine.payed.payedInApp else { return }
            connectionStateToPayed = .loading
            errorMessages = nil
            
            let payed: Payed = .payed(date: Date(), inApp: false)
            let callItem = ChangeFinePayedCall(clubId: signedInPerson.clubProperties.id, fineId: fine.id, payed: payed)
            FunctionCaller.shared.call(callItem) { _ in
                connectionStateToPayed = .passed
                fine.payed = payed
            } failedHandler: { _ in
                connectionStateToPayed = .failed
                errorMessages = .internalErrorSave(code: 2)
            }
        }
    }
}
