//
//  BackButton.swift
//  Strafen
//
//  Created by Steven on 10.05.21.
//

import SwiftUI

/// Back  button
struct BackButton: View {

    /// Presentation mode
    @Environment(\.presentationMode) private var presentationMode

    public var body: some View {
        HStack(spacing: 0) {

            // Back Button
            Text("back-button-text", tableName: "OtherTexts", comment: "Text of back button")
                .font(.system(size: 24, weight: .light))
                .foregroundColor(.textColor)
                .lineLimit(1)
                .padding(.leading, 10)
                .onTapGesture { presentationMode.wrappedValue.dismiss() }

            Spacer()
        }
    }
}

/// Back and edit button
struct BackAndEditButton<EditSheetContent>: View where EditSheetContent: View {

    /// Presentation mode
    @Environment(\.presentationMode) private var presentationMode

    /// Currently logged in person
    @EnvironmentObject var person: Settings.Person

    /// Content of edit sheet
    private let editSheetContent: EditSheetContent

    public init(@ViewBuilder editSheetContent: () -> EditSheetContent) {
        self.editSheetContent = editSheetContent()
    }

    /// Indicates if edit sheet is shown
    @State private var isEditSheetPresented = false

    public var body: some View {
        HStack(spacing: 0) {

            // Back Button
            Text("back-button-text", tableName: "OtherTexts", comment: "Text of back button")
                .font(.system(size: 24, weight: .light))
                .foregroundColor(.textColor)
                .lineLimit(1)
                .padding(.leading, 10)
                .onTapGesture { presentationMode.wrappedValue.dismiss() }

            Spacer()

            // EditButton
            if person.isCashier {
                Text("edit-button-text", tableName: "OtherTexts", comment: "Text of edit button")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.textColor)
                    .lineLimit(1)
                    .padding(.trailing, 10)
                    .toggleOnTapGesture($isEditSheetPresented)
                    .sheet(isPresented: $isEditSheetPresented) { editSheetContent }
            }
        }
    }
}
