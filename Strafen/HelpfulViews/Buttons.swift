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
            
        }.frame(width: UIScreen.main.bounds.width * 0.7, height: 50)
            .onTapGesture(perform: buttonHandler)
    }
}

/// Green only confirm button
struct ConfirmButton: View {
    
    /// Handler by button clicked
    let buttonHandler: () -> ()
    
    /// Text shown on the button
    let text: String
    
    /// Shows a loading circle if state is loading
    @Binding var connectionState: ConnectionState
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    init(_ text: String = "Bestätigen", connectionState: Binding<ConnectionState>? = nil, _ buttonHandler: @escaping () -> ()) {
        self.text = text
        _connectionState = connectionState ?? .constant(.passed)
        self.buttonHandler = buttonHandler
    }
    
    var body: some View {
        ZStack {
            
            // Outline
            Outline()
                .fillColor(settings.style.fillColor(colorScheme, defaultStyle: Color.custom.lightGreen))
            
            // Inside
            HStack(spacing: 0) {
                
                // Text
                Text(text)
                    .foregroundColor(settings.style == .default ? Color.custom.gray : Color.custom.lightGreen)
                    .font(.text(20))
                    .lineLimit(1)
                
                // Loading circle
                if connectionState == .loading {
                    ProgressView()
                        .padding(.leading, 15)
                }
                
            }
            
        }.frame(width: UIScreen.main.bounds.width * 0.7, height: 50)
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
                
            }.frame(width: UIScreen.main.bounds.width * 0.475 , height: 50)
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
                
            }.frame(width: UIScreen.main.bounds.width * 0.475, height: 50)
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
    
    /// Shows a loading circle if state is loading
    @Binding var connectionStateDelete: ConnectionState
    
    /// Shows a loading circle if state is loading
    @Binding var connectionStateConfirm: ConnectionState
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    init(connectionStateDelete: Binding<ConnectionState>? = nil, connectionStateConfirm: Binding<ConnectionState>? = nil, _ deleteButtonHandler: @escaping () -> (), confirmButtonHandler: @escaping () -> ()) {
        _connectionStateDelete = connectionStateDelete ?? .constant(.passed)
        _connectionStateConfirm = connectionStateConfirm ?? .constant(.passed)
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
                
                // Inside
                HStack(spacing: 0) {
                    
                    // Text
                    Text("Löschen")
                        .foregroundColor(settings.style == .default ? Color.custom.gray : Color.custom.red)
                        .font(.text(20))
                        .lineLimit(1)
                    
                    // Loading circle
                    if connectionStateDelete == .loading {
                        ProgressView()
                            .padding(.leading, 15)
                    }
                    
                }
                
            }.frame(width: UIScreen.main.bounds.width * 0.475, height: 50)
                .onTapGesture(perform: deleteButtonHandler)
            
            // Confirm Button
            ZStack {
                
                // Outline
                Outline(.right)
                
                // Inside
                HStack(spacing: 0) {
                    
                    // Text
                    Text("Bestätigen")
                        .foregroundColor(Color.textColor)
                        .font(.text(20))
                        .lineLimit(1)
                    
                    // Loading circle
                    if connectionStateConfirm == .loading {
                        ProgressView()
                            .padding(.leading, 15)
                    }
                    
                }
                
            }.frame(width: UIScreen.main.bounds.width * 0.475, height: 50)
                .onTapGesture(perform: confirmButtonHandler)
            
        }
    }
}

/// Back and edit button
struct BackAndEditButton<EditSheetContent>: View where EditSheetContent: View {
    
    /// Content of edit sheet
    let editSheetContent: EditSheetContent
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Indicates if edit sheet is shown
    @State var isEditSheetPresented = false
    
    init(@ViewBuilder editSheetContent: () -> EditSheetContent) {
        self.editSheetContent = editSheetContent()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                
                // Back Button
                Text("Zurück")
                    .foregroundColor(.textColor)
                    .font(.text(25))
                    .padding(.leading, 10)
                    .padding(.top, 35)
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
                Spacer()
                
                // EditButton
                if settings.person!.isCashier {
                    Text("Bearbeiten")
                        .foregroundColor(.textColor)
                        .font(.text(25))
                        .padding(.trailing, 10)
                        .padding(.top, 35)
                        .onTapGesture {
                            isEditSheetPresented = true
                        }
                        .sheet(isPresented: $isEditSheetPresented) {
                            editSheetContent
                        }
                }
            }
            Spacer()
        }
    }
}


// Add New List Item Button
struct AddNewListItemButton<ListType, AddNewSheetContent>: View where AddNewSheetContent: View {
    
    /// Indicates if list is empty
    @Binding var list: [ListType]?
    
    /// Filter of the list
    let listFilter: (ListType) -> Bool
    
    /// Content of add new sheet
    let addNewSheetContent: AddNewSheetContent
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Indicates if addNewNote sheet is shown
    @State var isAddNewNoteSheetShown = false
    
    init(list: Binding<[ListType]?>, listFilter: ((ListType) -> Bool)? = nil, @ViewBuilder addNewSheetContent: () -> AddNewSheetContent) {
        _list = list
        self.listFilter = listFilter ?? { _ in true }
        self.addNewSheetContent = addNewSheetContent()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if settings.person!.isCashier {
                Spacer()
                HStack(spacing: 0) {
                    Spacer()
                    
                    // Arrow
                    if list?.filter(listFilter).isEmpty ?? false {
                        Image(systemName: "arrowshape.zigzag.right")
                            .rotationEffect(.radians(.pi))
                            .rotation3DEffect(.radians(.pi), axis: (x: 0, y: 1, z: 0))
                            .padding(.trailing, 25)
                            .font(.system(size: 50, weight: .thin))
                            .foregroundColor(Color.custom.red)
                            .offset(y: -10)
                    }
                    
                    // Add New Button
                    RoundedCorners()
                        .strokeColor(settings.style.strokeColor(colorScheme))
                        .fillColor(settings.style.fillColor(colorScheme, defaultStyle: Color.custom.lightGreen))
                        .lineWidth(settings.style == .default ? 1.5 : 0.5)
                        .radius(settings.style.radius)
                        .frame(width: 45, height: 45)
                        .overlay(
                            Image(systemName: "text.badge.plus")
                                .font(.system(size: 25, weight: .light))
                                .foregroundColor(.textColor)
                        )
                        .padding([.trailing, .bottom], 20)
                        .onTapGesture {
                            isAddNewNoteSheetShown = true
                        }
                        .sheet(isPresented: $isAddNewNoteSheetShown) {
                            addNewSheetContent
                        }
                    
                }
            }
        }
    }
}
