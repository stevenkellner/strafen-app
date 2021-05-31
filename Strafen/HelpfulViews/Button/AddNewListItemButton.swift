//
//  AddNewListItemButton.swift
//  Strafen
//
//  Created by Steven on 31.05.21.
//

import SwiftUI

/// Add New List Item Button
struct AddNewListItemButton<Content>: View where Content: View {

    /// Currently logged in person
    @EnvironmentObject var person: Settings.Person

    /// Indicates whether list is empty
    let isListEmpty: Bool

    /// Content of add new sheet
    let content: Content

    init(isListEmpty: Bool, @ViewBuilder content: () -> Content) {
        self.isListEmpty = isListEmpty
        self.content = content()
    }

    /// Indicates if addNewNote sheet is shown
    @State var isAddNewNoteSheetShown = false

    var body: some View {
        VStack(spacing: 0) {
            if person.isCashier {
                Spacer()
                HStack(spacing: 0) {
                    Spacer()

                    // Arrow
                    if isListEmpty {
                        Image(systemName: "arrowshape.zigzag.right")
                            .rotationEffect(.radians(.pi))
                            .rotation3DEffect(.radians(.pi), axis: (x: 0, y: 1, z: 0))
                            .padding(.trailing, 25)
                            .font(.system(size: 50, weight: .thin))
                            .foregroundColor(.customRed)
                    }

                    // Add New Button
                    SingleOutlinedContent {
                        Image(systemName: "text.badge.plus")
                            .foregroundColor(.textColor)
                            .font(.system(size: 25, weight: .light))
                    }.frame(width: 45, height: 45)
                        .onTapGesture {
                            isAddNewNoteSheetShown = true
                            UIApplication.shared.dismissKeyboard()
                        }
                        .sheet(isPresented: $isAddNewNoteSheetShown) { content }

                }.padding([.trailing, .bottom], 30)
            }
        }.maxFrame
    }
}
