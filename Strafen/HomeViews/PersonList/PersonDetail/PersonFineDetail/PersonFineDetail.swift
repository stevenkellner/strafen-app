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
    
    var body: some View {
        ZStack {
            
            // Background color
            colorScheme.backgroundColor
            
            // Back and edit button
            BackAndEditButton {
                PersonFineEditor(fine: fine)
            }
            
            // Fine Detail
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
                
                // Reason
                Text(fine.fineReason.reason)
                    .foregroundColor(.textColor)
                    .font(.text(25))
                    .padding(.horizontal, 25)
                    .padding(.top, 40)
                    .lineLimit(1)
                
                // Amount
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
                
                // Date
                Text(fine.date.formatted)
                    .foregroundColor(.textColor)
                    .font(.text(25))
                    .padding(.horizontal, 25)
                    .padding(.top, 50)
                    .lineLimit(1)
                
                // Payed Display
                ZStack {
                    
                    HStack(spacing: 0) {
                        
                        // Left of the divider
                        Outline(.left)
                            .fillColor(fine.fineReason.importance.color, onlyDefault: false)
                            .frame(width: 100, height: 50)
                            .onTapGesture {
                                if settings.person!.isCashier && fine.payed == .payed {
                                    showAlertToUnpayed = true
                                }
                            }
                            .alert(isPresented: $showAlertToUnpayed) {
                                Alert(title: Text("Strafe Ändern"), message: Text("Möchtest du diese Strafe wircklich als unbezahlt markieren?"), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Bestätigen"), action: {
                                    withAnimation {
                                        fine.payed = .unpayed
                                    }
                                    // TODO save payed change
                                }))
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
                                Alert(title: Text("Strafe Ändern"), message: Text("Möchtest du diese Strafe wircklich als bezahlt markieren?"), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Bestätigen"), action: {
                                    withAnimation {
                                        fine.payed = .payed
                                    }
                                    // TODO save unpayed change
                                }))
                            }
                        
                    }
                    
                    // Indicator
                    RoundedCorners()
                        .strokeColor(settings.style == .default ? Color.custom.gray : Color.plain.strokeColor(colorScheme))
                        .lineWidth(2.5)
                        .radius(2.5)
                        .frame(width: 33, height: 2.5)
                        .offset(x: fine.payed == .payed ? 50 : -50)
                    
                }.padding(.top, 58)
                
                Spacer()
            }.padding(.top, 60)
            
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
}
