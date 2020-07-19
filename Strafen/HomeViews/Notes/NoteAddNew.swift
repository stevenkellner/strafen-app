//
//  NoteAddNew.swift
//  Strafen
//
//  Created by Steven on 18.07.20.
//

import SwiftUI

/// View to add a new note
struct NoteAddNew: View {
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Input subject
    @State var subject = ""
    
    /// Input message
    @State var message = ""
    
    /// True if keybord of massage field is shown
    @State var isMessageKeyboardShown = false
    
    /// Indicates if cofirm button is pressed and the alert is shown
    @State var confirmAlertShown = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Bar to wipe sheet down
            SheetBar()
            
            // Title
            Header("Notiz Hinzufügen")
            
            VStack(spacing: 0) {
                
                // Subject
                VStack(spacing: 0) {
                    
                    // Title
                    HStack(spacing: 0) {
                        Text("Befreff:")
                            .foregroundColor(.textColor)
                            .font(.text(20))
                            .padding(.leading, 10)
                        Spacer()
                    }
                    
                    // Text Field
                    CustomTextField("Betreff", text: $subject) {
                        withAnimation {
                            isMessageKeyboardShown = false
                        }
                    }.onChange(of: subject) { _ in
                        withAnimation {
                            isMessageKeyboardShown = false
                        }
                    }.frame(width: 345, height: 50)
                        .padding(.top, 5)
                    
                }.padding(.top, 30)
                
                // Message
                VStack(spacing: 0) {
                    
                    // Title
                    HStack(alignment: .bottom, spacing: 0) {
                        Text("Nachricht:")
                            .foregroundColor(.textColor)
                            .font(.text(20))
                            .padding(.leading, 10)
                        Spacer()
                        
                        // Done button
                        if isMessageKeyboardShown {
                            Text("Fertig")
                                .foregroundColor(Color.custom.darkGreen)
                                .font(.text(25))
                                .lineLimit(1)
                                .padding(.trailing, 15)
                                .onTapGesture {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                        }
                        
                    }
                    
                    // Text Field
                    ZStack {
                        
                        // Text Field
                        TextEditor(text: $message)
                            .onChange(of: message)  { _ in
                                if !message.isEmpty {
                                    withAnimation {
                                        isMessageKeyboardShown = true
                                    }
                                }
                            }
                            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
                                withAnimation {
                                    isMessageKeyboardShown = false
                                }
                            }
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.textColor)
                            .font(.text(20))
                            .lineLimit(1)
                            .multilineTextAlignment(.center)
                        
                        // Outline
                        RoundedCorners.path(width: 345, height: 200, cornerRadius: RoundedCorners.CornerRadius(settings.style.radius, corner: .all))
                            .stroke(settings.style.strokeColor(colorScheme), lineWidth: settings.style.lineWidth)
                        
                    }.frame(width: 345, height: 200)
                        .padding(.top, 5)
                    
                }.padding(.top, 30)
                    .padding(.bottom, 1)
                
            }.offset(y: isMessageKeyboardShown ? -100 : 0)
                .clipped()
                .padding(.top, 20)
            
            Spacer()
            
            // Cancel / Confirm Button
            CancelConfirmButton {
                presentationMode.wrappedValue.dismiss()
            } confirmButtonHandler: {
                confirmAlertShown = true
            }.padding(.bottom, 50)
                .alert(isPresented: $confirmAlertShown) {
                    if subject.isEmpty {
                        return Alert(title: Text("Keinen Betreff Angegeben"), message: Text("Bitte gebe einen Betreff für diese Notiz ein."), dismissButton: .default(Text("Verstanden")))
                    } else if message.isEmpty {
                        return Alert(title: Text("Keine Nachricht Angegeben"), message: Text("Bitte gebe eine Nachricht für diese Notiz ein."), dismissButton: .default(Text("Verstanden")))
                    }
                    return Alert(title: Text("Notiz Hinzufügen"), message: Text("Möchtest du diese Notiz wirklich hinzufügen?"), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Bestätigen"), action: {
                        let note = Note(id: UUID(), subject: subject, date: Date().formattedDate, message: message)
                        LocalListChanger.shared.change(.add, item: note)
                        presentationMode.wrappedValue.dismiss()
                    }))
                }

        }.background(colorScheme.backgroundColor)
    }
}

#if DEBUG
struct NoteAddNew_Previews: PreviewProvider {
    static var previews: some View {
        NoteAddNew()
            .previewDevice("iPhone 11")
    }
}
#endif
