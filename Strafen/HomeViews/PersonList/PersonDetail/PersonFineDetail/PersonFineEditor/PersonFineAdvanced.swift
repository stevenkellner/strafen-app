//
//  PersonFineAdvanced.swift
//  Strafen
//
//  Created by Steven on 17.07.20.
//

import SwiftUI

/// View of PersonFineEditor to select advancment
struct PersonFineAdvanced: View {
    
    /// Input date
    @Binding var date: Date
    
    /// Input number
    @Binding var number: Int
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Bar to wipe sheet down
            SheetBar()
            
            // Title
            Header("Erweitert")
            
            ScrollView(showsIndicators: false) {
                
                // Number Stepper
                HStack(spacing: 0) {
                    Text("Anzahl: \(number)")
                        .font(.text(25))
                        .foregroundColor(.textColor)
                        .lineLimit(1)
                        .padding(.trailing, 25)
                    Stepper("Title", value: $number, in: 1...99)
                        .labelsHidden()
                }.padding(.top, 30)
                
                // Date picker
                CustomDatePicker(date: $date)
                    .style(.inline)
                    .frame(width: 345, height: 345)
                    .padding(.top, 15)
                
                Spacer()
            }.padding(.top, 15)
            
            // Confirm Button
            ConfirmButton {
                presentationMode.wrappedValue.dismiss()
            }.padding(.bottom, 30)
                .padding(.top, 20)
            
        }
    }
}
