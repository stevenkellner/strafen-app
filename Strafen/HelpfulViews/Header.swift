//
//  Header.swift
//  Strafen
//
//  Created by Steven on 28.06.20.
//

import SwiftUI

/// Page Header with underlines
struct Header: View {
    
    /// Page title
    let title: String
    
    /// Line limit
    private var lineLimit: Int? = 1
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        VStack(spacing: 0) {
                
            // Title
            HStack {
                Text(self.title)
                    .foregroundColor(Color.textColor)
                    .font(.text(35))
                    .padding(.horizontal, 22)
                    .lineLimit(lineLimit)
                Spacer()
            }
            
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
                
        }
    }
    
    /// Set line limit
    func lineLimit(_ lineLimit: Int?) -> Header {
        var header = self
        header.lineLimit = lineLimit
        return header
    }
}

/// Title of a textfield
struct Title: View {
    
    /// Title
    var title: String
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text("\(title):")
                .foregroundColor(.textColor)
                .font(.text(20))
                .padding(.leading, 10)
            Spacer()
        }
    }
}

/// Error messages under a textfield
struct ErrorMessages<ErrorType>: View where ErrorType: ErrorMessageType {
    
    /// Type of the error message
    @Binding var errorType: ErrorType?
    
    var body: some View {
        if let errorType = errorType {
            Text(errorType.message)
                .foregroundColor(Color.custom.red)
                .font(.text(20))
                .lineLimit(1)
                .padding(.horizontal, 15)
        }
    }
}

/// Error Type
protocol ErrorMessageType {
    
    /// Message of the error
    var message: String { get }
}
