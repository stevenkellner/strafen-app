//
//  PaymentFineSelector.swift
//  Strafen
//
//  Created by Steven on 3/7/21.
//

import SwiftUI

/// Button with PayPal and Credit Card
struct PaymentButton: View {
    
    /// Person id
    let personId: Person.ID
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Fine List Data
    @ObservedObject var fineListData = ListData.fine
    
    /// Reason List Data
    @ObservedObject var reasonListData = ListData.reason
    
    /// Indicates whether fine selector sheet is shown
    @State var showFineSelectorSheet = false
    
    var body: some View {
        if let person = settings.person, person.clubProperties.isInAppPaymentActive, let fineList = fineListData.list, fineList.hasUnpayedFines(personId, with: reasonListData.list) {
            ZStack {
                Outline().fillColor(Color.init(red: 0.937, green: 0.741, blue: 0.255), onlyDefault: false)
                HStack(spacing: 5) {
                    Image("paypal_logo").resizable().scaledToFit().frame(height: 20)
                    Text("oder Kreditkarte").configurate(size: 20).lineLimit(1)
                    Image(systemName: "creditcard").font(.system(size: 25, weight: .thin)).foregroundColor(.textColor)
                }
            }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                .toggleOnTapGesture($showFineSelectorSheet)
                .sheet(isPresented: $showFineSelectorSheet) {
                    PaymentFineSelector(personId: personId)
                }
        }
    }
}

/// Used to select fines for payment
struct PaymentFineSelector: View {
    
    /// Person id
    let personId: Person.ID
    
    /// Fine List Data
    @ObservedObject var fineListData = ListData.fine
    
    /// Reason List Data
    @ObservedObject var reasonListData = ListData.reason
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Selected Fines
    @State var selectedFineIds: [Fine.ID] = []
    
    /// Error messages
    @State var errorMessages: ErrorMessages? = nil
    
    @State var showPaymentMethodSheet = false
    
    @State var showCreditCardSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Bar to wipe sheet down
            SheetBar()
            
            // Header
            Header("Strafen Bezahlen")
            
            if let unpayedFineList = fineListData.list?.unpayedFines(personId), !unpayedFineList.isEmpty {
                VStack(spacing: 5) {
                    
                    // Select all button
                    HStack(spacing: 0) {
                        ZStack {
                            Outline().fillColor(Color.custom.lightGreen)
                            Text(selectedFineIds.count == unpayedFineList.count ? "Alle Abwählen" : "Alle Auswählen").configurate(size: 15).lineLimit(1)
                        }.frame(width: 150, height: 35).padding(.leading, 20)
                            .onTapGesture { handleSelectAll(fineList: unpayedFineList) }
                        Spacer()
                    }
                    
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(unpayedFineList.sortedForList(of: personId, with: reasonListData.list)) { fine in
                                FineRow(fine: fine, selectedFineIds: $selectedFineIds)
                            }
                        }.padding(.bottom, 10)
                            .padding(.top, 5)
                    }.padding(.top, 5)
                    
                }.padding(.top, 10)
                
                Spacer()
                
                let selectedAmountSum = selectedAmountSum(fineList: unpayedFineList)
                HStack(spacing: 5) {
                    Text(describing: selectedAmountSum)
                        .foregroundColor(selectedAmountSum.isZero ? Color.custom.red : Color.custom.lightGreen)
                        .font(.text(25))
                        .lineLimit(1)
                    Text("Ausgewählt").configurate(size: 15).lineLimit(1).offset(y: 5)
                }.padding(.bottom, 10)
                
                VStack(spacing: 5) {
                    
                    // Confirm button
                    ConfirmButton()
                        .title("Jetzt Bezahlen")
                        .onButtonPress(handleConfirm)
                    
                    // Error messages
                    ErrorMessageView(errorMessages: $errorMessages)
                    
                }.padding(.bottom, errorMessages == nil ? 50 : 25).animation(.default)
                
            }
        }.setScreenSize.overlay(Color.black.opacity(showPaymentMethodSheet ? 0.25 : 0))
            .halfModal(isPresented: $showPaymentMethodSheet, header: "Zahlmethode Wählen") {
                VStack(spacing: 5) {
                    ZStack {
                        Outline()
                        HStack(spacing: 5) {
                            Text("Kreditkarte").configurate(size: 20).lineLimit(1)
                            Image(systemName: "creditcard").font(.system(size: 25, weight: .thin)).foregroundColor(.textColor)
                        }
                    }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                        .toggleOnTapGesture($showCreditCardSheet)
                        .sheet(isPresented: $showCreditCardSheet) {
                            PaymentCreditCard(fineIds: selectedFineIds) {
                                showCreditCardSheet = false
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    PaymentPayPalButton(fineIds: selectedFineIds) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
    }
    
    func handleSelectAll(fineList: [Fine]) {
        selectedFineIds = selectedFineIds.count == fineList.count ? [] : fineList.map(\.id)
    }
    
    func selectedAmountSum(fineList: [Fine]) -> Amount {
        fineList.filter {
            selectedFineIds.contains($0.id)
        }.reduce(into: .zero) { result, fine in
            result += fine.completeAmount(with: reasonListData.list)
        }
    }
    
    func handleConfirm() {
        errorMessages = nil
        guard !selectedFineIds.isEmpty else { return errorMessages = .noFinesSelected }
        showPaymentMethodSheet = true
    }
    
    struct FineRow: View {
        
        /// Fine
        let fine: Fine
        
        /// Selected Fines
        @Binding var selectedFineIds: [Fine.ID]
        
        /// Reason List Data
        @ObservedObject var reasonListData = ListData.reason
        
        var body: some View {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    
                    // Left of the divider
                    ZStack {
                        
                        // Outline
                        Outline(.left)
                            .fillColor(fine.amountTextColor(with: reasonListData.list))
                        
                        // Inside
                        Text(describing: fine.completeAmount(with: reasonListData.list))
                            .foregroundColor(plain: fine.amountTextColor(with: reasonListData.list))
                            .font(.text(20))
                            .lineLimit(1)
                        
                    }.frame(width: geometry.size.width * 0.3)
                    
                    // Right of the divider
                    ZStack {
                        
                        // Outline
                        Outline(.right)
                            .fillColor(selectedFineIds.contains(fine.id) ? Color.custom.lightGreen : nil)
                        
                        // Inside
                        HStack(spacing: 0) {
                            
                            // Text
                            Text(fine.fineReason.reason(with: reasonListData.list))
                                .foregroundColor(plain: selectedFineIds.contains(fine.id) ? Color.custom.lightGreen : nil)
                                .font(.text(20))
                                .padding(.leading, 10)
                                .lineLimit(1)
                            
                            Spacer()
                        }
                        
                    }.frame(width: geometry.size.width * 0.7)
                    
                }
            }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                .onTapGesture(perform: toggleThisFine)
        }
        
        func toggleThisFine() {
            if selectedFineIds.contains(fine.id) {
                selectedFineIds.filtered { $0 != fine.id }
            } else {
                selectedFineIds.append(fine.id)
            }
        }
    }
}

extension Array where Element == Fine {
    fileprivate func unpayedFines(_ personId: Person.ID) -> [Element] {
        filter { $0.assoiatedPersonId == personId && $0.payed == .unpayed }
    }
    
    fileprivate func sortedForList(of personId: Person.ID, with reasonList: [ReasonTemplate]?) -> [Element] {
        sorted(byValue: { fine in
            fine.fineReason.reason(with: reasonList).localizedUppercase
        })
    }
    
    fileprivate func hasUnpayedFines(_ personId: Person.ID, with reasonList: [ReasonTemplate]?) -> Bool {
        !unpayedFines(personId).reduce(into: .zero) { result, fine in
            result += fine.completeAmount(with: reasonList)
        }.isZero
    }
}
