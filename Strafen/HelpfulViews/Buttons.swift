//
//  Buttons.swift
//  Strafen
//
//  Created by Steven on 28.06.20.
//

import SwiftUI

/// Red only cancel button
struct CancelButton: View {
    
    /// Handler by button clicked
    let buttonHandler: () -> ()
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    init(_ buttonHandler: @escaping () -> ()) {
        self.buttonHandler = buttonHandler
    }
    
    var body: some View {
        ZStack {
            
            // Outline
            Outline()
                .fillColor(settings.style.fillColor(colorScheme, defaultStyle: Color.custom.red))
            
            // Text
            Text("Abbrechen")
                .foregroundColor(settings.style == .default ? Color.custom.gray : Color.custom.red)
                .font(.text(20))
                .lineLimit(1)
            
        }.frame(width: 258, height: 50)
            .onTapGesture(perform: buttonHandler)
    }
}

/// Green only confirm button
struct ConfirmButton: View {
    
    /// Handler by button clicked
    let buttonHandler: () -> ()
    
    /// Text shown on the button
    let text: String
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    init(_ text: String = "Bestätigen", _ buttonHandler: @escaping () -> ()) {
        self.text = text
        self.buttonHandler = buttonHandler
    }
    
    var body: some View {
        ZStack {
            
            // Outline
            Outline()
                .fillColor(settings.style.fillColor(colorScheme, defaultStyle: Color.custom.lightGreen))
            
            // Text
            Text(text)
                .foregroundColor(settings.style == .default ? Color.custom.gray : Color.custom.lightGreen)
                .font(.text(20))
                .lineLimit(1)
            
        }.frame(width: 258, height: 50)
            .onTapGesture(perform: buttonHandler)
    }
}

/// Red Cancel and confirm button
struct CancelConfirmButton: View {
    
    /// Handler by cancel button clicked
    let cancelButtonHandler: () -> ()
    
    /// Handler by cofirm button clicked
    let confirmButtonHandler: () -> ()
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    init(_ cancelButtonHandler: @escaping () -> (), confirmButtonHandler: @escaping () -> ()) {
        self.cancelButtonHandler = cancelButtonHandler
        self.confirmButtonHandler = confirmButtonHandler
    }
    
    var body: some View {
        HStack(spacing: 0) {
            
            // Cancel Button
            ZStack {
                
                // Outline
                Outline(.left)
                    .fillColor(settings.style.fillColor(colorScheme, defaultStyle: Color.custom.red))
                
                // Text
                Text("Abbrechen")
                    .foregroundColor(settings.style == .default ? Color.custom.gray : Color.custom.red)
                    .font(.text(20))
                    .lineLimit(1)
                
            }.frame(width: 172.5, height: 50)
                .onTapGesture(perform: cancelButtonHandler)
            
            // Confirm Button
            ZStack {
                
                // Outline
                Outline(.right)
                
                // Text
                Text("Bestätigen")
                    .foregroundColor(Color.textColor)
                    .font(.text(20))
                    .lineLimit(1)
                
            }.frame(width: 172.5, height: 50)
                .onTapGesture(perform: confirmButtonHandler)
            
        }
    }
}

/// Red Delete and confirm button
struct DeleteConfirmButton: View {
    
    /// Handler by delete button clicked
    let deleteButtonHandler: () -> ()
    
    /// Handler by cofirm button clicked
    let confirmButtonHandler: () -> ()
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    init(_ deleteButtonHandler: @escaping () -> (), confirmButtonHandler: @escaping () -> ()) {
        self.deleteButtonHandler = deleteButtonHandler
        self.confirmButtonHandler = confirmButtonHandler
    }
    
    var body: some View {
        HStack(spacing: 0) {
            
            // Cancel Button
            ZStack {
                
                // Outline
                Outline(.left)
                    .fillColor(settings.style.fillColor(colorScheme, defaultStyle: Color.custom.red))
                
                // Text
                Text("Löschen")
                    .foregroundColor(settings.style == .default ? Color.custom.gray : Color.custom.red)
                    .font(.text(20))
                    .lineLimit(1)
                
            }.frame(width: 172.5, height: 50)
                .onTapGesture(perform: deleteButtonHandler)
            
            // Confirm Button
            ZStack {
                
                // Outline
                Outline(.right)
                
                // Text
                Text("Bestätigen")
                    .foregroundColor(Color.textColor)
                    .font(.text(20))
                    .lineLimit(1)
                
            }.frame(width: 172.5, height: 50)
                .onTapGesture(perform: confirmButtonHandler)
            
        }
    }
}
