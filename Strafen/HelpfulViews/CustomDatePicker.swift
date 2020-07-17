//
//  CustomDatePicker.swift
//  Strafen
//
//  Created by Steven on 17.07.20.
//

import SwiftUI

/// Date Picker with max date, local and only date (no time)
struct CustomDatePicker: UIViewRepresentable {
    
    /// Selected date
    @Binding var date: Date
    
    /// Date picker
    private let datePicker = UIDatePicker()
    
    /// CustomDatePicker Coordinator
    class Coordinator: NSObject {
        
        /// Selected date
        private let date: Binding<Date>
        
        init(date: Binding<Date>) {
            self.date = date
        }
        
        @objc func changed(_ sender: UIDatePicker) {
            date.wrappedValue = sender.date
        }
    }
    
    /// Make Coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(date: $date)
    }
    
    /// Make View
    func makeUIView(context: Context) -> UIDatePicker {
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        datePicker.locale = Locale(identifier: "de")
        datePicker.addTarget(context.coordinator, action: #selector(Coordinator.changed), for: .valueChanged)
        datePicker.preferredDatePickerStyle = .inline
        datePicker.sizeToFit()
        return datePicker
    }
    
    /// Update View
    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        datePicker.date = date
    }
}
