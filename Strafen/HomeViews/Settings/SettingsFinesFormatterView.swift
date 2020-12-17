//
//  SettingsFinesFormatterView.swift
//  Strafen
//
//  Created by Steven on 9/1/20.
//

import SwiftUI

/// Fines Formatter View
struct FinesFormatterView: View {
    
    ///Dismiss handler
    @Binding var dismissHandler: DismissHandler
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Person List Data
    @ObservedObject var personListData = ListData.person
    
    /// Fine List Data
    @ObservedObject var fineListData = ListData.fine
    
    /// Reason List Data
    @ObservedObject var reasonListData = ListData.reason
    
    /// Preview text
    @State var previewText = ""
    
    /// Indicates if shared text has a header text
    @State var showHeaderText = true
    
    /// Indicates if shared text is expanded
    @State var showExpandedText = true
    
    var body: some View {
        ZStack {
            
            // Background Color
            colorScheme.backgroundColor
            
            // Back Button
            BackButton()
            
            // Content
            VStack(spacing: 0) {
                
                // Header
                Header("Strafen Teilen")
                    .padding(.top, 75)
                
                    
                ScrollView {
                    VStack(spacing: 10) {
                        
                        // Header Text Changer
                        VStack(spacing: 0) {
                        
                            SettingsView.Title("Zusatz Text")
                            
                            BooleanChanger(boolToChange: $showHeaderText)
                                .frame(width: UIScreen.main.bounds.width * 0.7, height: 25)
                                .onChange(of: showHeaderText) { _ in
                                    withAnimation { previewText = shareText }
                                }
                        }
                        
                        // Expanded Text Changer
                        VStack(spacing: 0) {
                            
                            SettingsView.Title("Erweiterte Informationen")
                            
                            BooleanChanger(boolToChange: $showExpandedText)
                                .frame(width: UIScreen.main.bounds.width * 0.7, height: 25)
                                .onChange(of: showExpandedText) { _ in
                                    withAnimation { previewText = shareText }
                                }
                        }
                        
                        // Preview Text
                        VStack(spacing: 0) {
                            
                            SettingsView.Title("Vorschau")
                            
                            HStack {
                                Text(previewText)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.textColor)
                                    .font(.text(20))
                                    .lineLimit(nil)
                                    .padding(.horizontal, 20)
                                Spacer()
                            }
                        }
                        
                    }
                    
                }.padding(.vertical, 10)
                
                Spacer()
                
                // Share and copy button
                ShareCopyButton {
                    ActivityView.shared.shareText(shareText)
                } copyButtonHandler: {
                    UIPasteboard.general.string = shareText
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }.padding(.bottom, 30)
            }
            
        }.edgesIgnoringSafeArea(.all)
            .hideNavigationBarTitle()
            .onAppear {
                dismissHandler = { presentationMode.wrappedValue.dismiss() }
                previewText = shareText
            }
    }
    
    /// Share text
    var shareText: String {
        var shareText = ""
        if showHeaderText {
            shareText.append(headerText)
            if !showExpandedText {
                shareText.append(" " + additionalHeaderText)
            }
            shareText.append("\n\n")
        }
        shareText.append(personListText)
        return shareText
    }
    
    /// Header text
    let headerText = "Das sind noch die offene Strafen, bitte bis nächste Woche alles zahlen."
    
    /// Additional header text
    let additionalHeaderText = "Wer wissen möchte für was er die Strafe bekommen hat, soll mir direkt schreiben."
    
    /// Person list text
    var personListText: String {
        personListData.list?.sorted(by: \.name.formatted).compactMap { person in
            personText(of: person)
        }.joined(separator: showExpandedText ? "\n\n" : "\n") ?? ""
    }
    
    /// Person text of given person
    func personText(of person: Person) -> String? {
        guard let unpayedFineList = fineListData.list?.filter({
            $0.assoiatedPersonId == person.id && !$0.isPayed
        }) else { return nil }
        guard !unpayedFineList.isEmpty else { return nil }
        let unpayedAmountSum = unpayedFineList.reduce(into: .zero) { result, fine in
            result += fine.completeAmount(with: reasonListData.list)
        }
        let personText = "\(person.name.formatted):\t \(unpayedAmountSum.description)"
        if showExpandedText {
            return "\(personText)\n\(fineText(of: unpayedFineList))"
        }
        return personText
    }
    
    /// Fine text of given fine list
    func fineText(of fineList: [Fine]) -> String {
        fineList.map { fine in
            "\t- \(fine.fineReason.reason(with: reasonListData.list)),\n\t  \(fine.date.formattedLong):\t \(fine.completeAmount(with: reasonListData.list))"
        }.joined(separator: "\n")
    }
    
    /// Share and copy button
    struct ShareCopyButton: View {
        
        /// Handler by cancel button clicked
        let shareButtonHandler: () -> Void
        
        /// Handler by cofirm button clicked
        let copyButtonHandler: () -> Void
        
        init(_ shareButtonHandler: @escaping () -> Void, copyButtonHandler: @escaping () -> Void) {
            self.shareButtonHandler = shareButtonHandler
            self.copyButtonHandler = copyButtonHandler
        }
        
        var body: some View {
            HStack(spacing: 0) {
                
                // Share Button
                ZStack {
                    
                    // Outline
                    Outline(.left)
                        .fillColor(Color.custom.lightGreen)
                    
                    // Text
                    Text("Teilen")
                        .foregroundColor(plain: Color.custom.lightGreen)
                        .font(.text(20))
                        .lineLimit(1)
                    
                }.frame(width: UIScreen.main.bounds.width * 0.475 , height: 50)
                    .onTapGesture(perform: shareButtonHandler)
                
                // Copy Button
                ZStack {
                    
                    // Outline
                    Outline(.right)
                    
                    // Text
                    Text("Kopieren")
                        .configurate(size: 20)
                        .lineLimit(1)
                    
                }.frame(width: UIScreen.main.bounds.width * 0.475, height: 50)
                    .onTapGesture(perform: copyButtonHandler)
                
            }
        }
    }
}
