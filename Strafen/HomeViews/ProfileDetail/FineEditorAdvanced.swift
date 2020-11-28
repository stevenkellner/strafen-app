//
//  FineEditorAdvanced.swift
//  Strafen
//
//  Created by Steven on 11/26/20.
//

import SwiftUI

/// View of Fine Editor to select advanced properties
struct FineEditorAdvanced: View {
    
    /// Properties of inputed fine
    @Binding var fineInputProperties: FineEditor.FineInputProperties
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Bar to wipe sheet down
            SheetBar()
            
            // Header
            Header("Erweitert")
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // Number Stepper
                    HStack(spacing: 25) {
                        
                        // Title
                        Text("Anzahl: \(fineInputProperties.number)")
                            .configurate(size: 25)
                            .lineLimit(1)
                        
                        // Stepper
                        Stepper("Title", value: $fineInputProperties.number, in: 1...99)
                            .labelsHidden()
                        
                    }
                    
                    // Date picker
                    CustomDatePicker(date: $fineInputProperties.date)
                        .style(.inline)
                        .frame(size: CGSize(square: UIScreen.main.bounds.width * 0.9))
                    
                    Spacer()
                }.padding(.vertical, 10)
            }.padding(.vertical, 10)
            
            // Confirm Button
            ConfirmButton()
                .onButtonPress { presentationMode.wrappedValue.dismiss() }
                .padding(.bottom, 50)
            
        }
    }
}
