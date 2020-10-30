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
    private var buttonHandler: (() -> Void)? = nil
    
    /// Deprecated init with button handler
    @available(*, deprecated, message: "replaced by init() and view modifiers")
    public init(_ buttonHandler: @escaping () -> ()) {
        self.buttonHandler = buttonHandler
    }
    
    /// Init with default values
    public init() {}
    
    public var body: some View {
        ZStack {
            
            // Outline
            Outline()
                .fillColor(Color.custom.red)
            
            // Text
            Text("Abbrechen")
                .foregroundColor(plain: Color.custom.red)
                .font(.text(20))
                .lineLimit(1)
            
        }.frame(width: UIScreen.main.bounds.width * 0.7, height: 50)
            .onTapGesture(perform: buttonHandler ?? {})
    }
    
    /// Set button handler
    public func onButtonPress(_ buttonHandler: @escaping () -> Void) -> CancelButton {
        var cancelButton = self
        cancelButton.buttonHandler = buttonHandler
        return cancelButton
    }
}

/// Green only confirm button
struct ConfirmButton: View {
    
    /// Handler by button clicked
    private var buttonHandler: (() -> Void)? = nil
    
    /// Text shown on the button
    private var text: String = "Bestätigen"
    
    /// Shows a loading circle if state is loading
    private var connectionState: Binding<ConnectionState>? = nil
    
    /// Error messages type
    private var errorMessages: Binding<ErrorMessages?>? = nil
    
    /// Deprecated init with text, connection state and button handler
    @available(*, deprecated, message: "replaced by init() and view modifiers")
    init(_ text: String = "Bestätigen", connectionState: Binding<ConnectionState>? = nil, buttonHandler: @escaping () -> Void) {
        self.text = text
        self.connectionState = connectionState ?? .constant(.passed)
        self.buttonHandler = buttonHandler
    }
    
    /// Init with error messages
    public init() {}
    
    public var body: some View {
        ZStack {
            
            // Outline
            Outline()
                .fillColor(Color.custom.lightGreen)
                .strokeColor(errorMessages?.wrappedValue.map { _ in Color.custom.red})
                .lineWidth(errorMessages?.wrappedValue.map { _ in CGFloat(2)})
            
            // Inside
            HStack(spacing: 0) {
                
                // Text
                Text(text)
                    .foregroundColor(plain: Color.custom.lightGreen)
                    .font(.text(20))
                    .lineLimit(1)
                
                // Loading circle
                if connectionState?.wrappedValue == .loading {
                    ProgressView()
                        .padding(.leading, 15)
                }
                
            }
            
        }.frame(width: UIScreen.main.bounds.width * 0.7, height: 50)
            .onTapGesture(perform: buttonHandler ?? {})
    }
    
    /// Set connection state
    public func connectionState(_ connectionState: Binding<ConnectionState>) -> ConfirmButton {
        var confirmButton = self
        confirmButton.connectionState = connectionState
        return confirmButton
    }
    
    /// Set title
    public func title(_ title: String) -> ConfirmButton {
        var confirmButton = self
        confirmButton.text = title
        return confirmButton
    }
    
    /// Set button handler
    public func onButtonPress(_ buttonHandler: @escaping () -> Void) -> ConfirmButton {
        var confirmButton = self
        confirmButton.buttonHandler = buttonHandler
        return confirmButton
    }
    
    /// Set error messages
    public func errorMessages(_ errorMessages: Binding<ErrorMessages?>) -> ConfirmButton {
        var confirmButton = self
        confirmButton.errorMessages = errorMessages
        return confirmButton
    }
}
    
/// Red Cancel and confirm button
struct CancelConfirmButton: View {
    
    /// Handler by cancel button clicked
    private var cancelButtonHandler: (() -> Void)? = nil
    
    /// Handler by cofirm button clicked
    private var confirmButtonHandler: (() -> Void)? = nil
    
    /// Shows a loading circle if state is loading
    private var connectionState: Binding<ConnectionState>? = nil
    
    /// Deprecated init with connection state, cancel and confirm button handler'
    @available(*, deprecated, message: "replaced by init() and view modifiers")
    public init(connectionState: Binding<ConnectionState>? = nil,_ cancelButtonHandler: @escaping () -> (), confirmButtonHandler: @escaping () -> ()) {
        self.connectionState = connectionState ?? .constant(.passed)
        self.cancelButtonHandler = cancelButtonHandler
        self.confirmButtonHandler = confirmButtonHandler
    }
    
    /// Init with default values
    public init() {}
    
    public var body: some View {
        HStack(spacing: 0) {
            
            // Cancel Button
            ZStack {
                
                // Outline
                Outline(.left)
                    .fillColor(Color.custom.red)
                
                // Text
                Text("Abbrechen")
                    .foregroundColor(plain: Color.custom.red)
                    .font(.text(20))
                    .lineLimit(1)
                
            }.frame(width: UIScreen.main.bounds.width * 0.475 , height: 50)
                .onTapGesture(perform: cancelButtonHandler ?? {})
            
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
                    if connectionState?.wrappedValue == .loading {
                        ProgressView()
                            .padding(.leading, 15)
                    }
                    
                }
                
            }.frame(width: UIScreen.main.bounds.width * 0.475, height: 50)
                .onTapGesture(perform: confirmButtonHandler ?? {})
            
        }
    }
    
    /// Set connection state
    public func connectionState(_ connectionState: Binding<ConnectionState>) -> CancelConfirmButton {
        var cancelConfirmButton = self
        cancelConfirmButton.connectionState = connectionState
        return cancelConfirmButton
    }
    
    /// Set cancel button handler
    public func onCancelPress(_ cancelButtonHandler: @escaping () -> Void) -> CancelConfirmButton {
        var cancelConfirmButton = self
        cancelConfirmButton.cancelButtonHandler = cancelButtonHandler
        return cancelConfirmButton
    }
    
    /// Set confirm button handler
    public func onConfirmPress(_ confirmButtonHandler: @escaping () -> Void) -> CancelConfirmButton {
        var cancelConfirmButton = self
        cancelConfirmButton.confirmButtonHandler = confirmButtonHandler
        return cancelConfirmButton
    }
}

/// Red Delete and confirm button
struct DeleteConfirmButton: View {
    
    /// Handler by delete button clicked
    private var deleteButtonHandler: (() -> Void)? = nil
    
    /// Handler by cofirm button clicked
    private var confirmButtonHandler: (() -> Void)? = nil
    
    /// Shows a loading circle if state is loading
    private var deleteConnectionState: Binding<ConnectionState>? = nil
    
    /// Shows a loading circle if state is loading
    private var confirmConnectionState: Binding<ConnectionState>? = nil
    
    /// Deprecated init with delete / confirm connection state and delete / confirm button handler
    @available(*, deprecated, message: "replaced by init() and view modifiers")
    init(connectionStateDelete: Binding<ConnectionState>? = nil, connectionStateConfirm: Binding<ConnectionState>? = nil, _ deleteButtonHandler: @escaping () -> (), confirmButtonHandler: @escaping () -> ()) {
        self.deleteConnectionState = connectionStateDelete ?? .constant(.passed)
        self.confirmConnectionState = connectionStateConfirm ?? .constant(.passed)
        self.deleteButtonHandler = deleteButtonHandler
        self.confirmButtonHandler = confirmButtonHandler
    }
    
    /// Init with default values
    public init() {}
    
    public var body: some View {
        HStack(spacing: 0) {
            
            // Cancel Button
            ZStack {
                
                // Outline
                Outline(.left)
                    .fillColor(Color.custom.red)
                
                // Inside
                HStack(spacing: 0) {
                    
                    // Text
                    Text("Löschen")
                        .foregroundColor(Color.custom.red)
                        .font(.text(20))
                        .lineLimit(1)
                    
                    // Loading circle
                    if deleteConnectionState?.wrappedValue == .loading {
                        ProgressView()
                            .padding(.leading, 15)
                    }
                    
                }
                
            }.frame(width: UIScreen.main.bounds.width * 0.475, height: 50)
                .onTapGesture(perform: deleteButtonHandler ?? {})
            
            // Confirm Button
            ZStack {
                
                // Outline
                Outline(.right)
                
                // Inside
                HStack(spacing: 0) {
                    
                    // Text
                    Text("Bestätigen")
                        .foregroundColor(.textColor)
                        .font(.text(20))
                        .lineLimit(1)
                    
                    // Loading circle
                    if confirmConnectionState?.wrappedValue == .loading {
                        ProgressView()
                            .padding(.leading, 15)
                    }
                    
                }
                
            }.frame(width: UIScreen.main.bounds.width * 0.475, height: 50)
                .onTapGesture(perform: confirmButtonHandler ?? {})
            
        }
    }
    
    /// Set delete connection state
    public func deleteConnectionState(_ connectionState: Binding<ConnectionState>) -> DeleteConfirmButton {
        var deleteConfirmButton = self
        deleteConfirmButton.deleteConnectionState = connectionState
        return deleteConfirmButton
    }
    
    /// Set confirm connection state
    public func confirmConnectionState(_ connectionState: Binding<ConnectionState>) -> DeleteConfirmButton {
        var deleteConfirmButton = self
        deleteConfirmButton.confirmConnectionState = connectionState
        return deleteConfirmButton
    }
    
    /// Set delete button handler
    public func onDeletePress(_ deleteButtonHandler: @escaping () -> Void) -> DeleteConfirmButton {
        var deleteConfirmButton = self
        deleteConfirmButton.deleteButtonHandler = deleteButtonHandler
        return deleteConfirmButton
    }
    
    /// Set confirm button handler
    public func onConfirmPress(_ confirmButtonHandler: @escaping () -> Void) -> DeleteConfirmButton {
        var deleteConfirmButton = self
        deleteConfirmButton.confirmButtonHandler = confirmButtonHandler
        return deleteConfirmButton
    }
}

/// Back and edit button
struct BackAndEditButton<EditSheetContent>: View where EditSheetContent: View {
    
    /// Content of edit sheet
    private let editSheetContent: EditSheetContent
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject private var settings = Settings.shared
    
    /// Presentation mode
    @Environment(\.presentationMode) private var presentationMode
    
    /// Indicates if edit sheet is shown
    @State private var isEditSheetPresented = false
    
    public init(@ViewBuilder editSheetContent: () -> EditSheetContent) {
        self.editSheetContent = editSheetContent()
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                
                // Back Button
                Text("Zurück")
                    .configurate(size: 25)
                    .padding(.leading, 10)
                    .padding(.top, 35)
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
                Spacer()
                
                // EditButton
                if settings.person!.isCashier {
                    Text("Bearbeiten")
                        .configurate(size: 25)
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

/// Back  button
struct BackButton: View {
    
    /// Presentation mode
    @Environment(\.presentationMode) private var presentationMode

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                
                // Back Button
                Text("Zurück")
                    .configurate(size: 25)
                    .padding(.leading, 10)
                    .padding(.top, 35)
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
                Spacer()
            }
            Spacer()
        }
    }
}

// Add New List Item Button
struct AddNewListItemButton<ListType, AddNewSheetContent>: View where AddNewSheetContent: View {
    
    /// Indicates if list is empty
    @Binding private var list: [ListType]?
    
    /// Filter of the list
    private let listFilter: (ListType) -> Bool
    
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
