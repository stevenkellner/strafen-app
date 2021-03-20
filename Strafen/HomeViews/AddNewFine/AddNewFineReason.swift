//
//  AddNewFineReason.swift
//  Strafen
//
//  Created by Steven on 17.07.20.
//

import SwiftUI

/// View to select reason for new fine
struct AddNewFineReason: View {
    
    /// Handles reason selection
    let completionHandler: (FineReason) -> Void
    
    let oldFineReason: FineReason?
    
    init(with fineReason: FineReason?, completion completionHandler: @escaping (FineReason) -> Void) {
        self.completionHandler = completionHandler
        self.oldFineReason = fineReason
    }
    
    /// Fine reason
    @State var fineReason: FineReason? = nil
    
    /// Error messages
    @State var errorMessages: ErrorMessages? = nil
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Reason List Data
    @ObservedObject var reasonListData = ListData.reason
    
    /// Text searched in search bar
    @State var searchText = ""
    
    @State var showCustomFineReasonSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Bar to wipe sheet down
            SheetBar()
            
            // Header
            Header("Strafe Auswählen")
            
            if let reasonList = reasonListData.list {
                
                // Empty List Text
                if reasonList.isEmpty {
                    Text("Es sind keine Strafen verfügbar.")
                        .configurate(size: 25)
                        .lineLimit(2)
                        .padding(.horizontal, 15)
                        .padding(.top, 50)
                    Text("Lege erst eine Neue im Strafenkatalog an.")
                        .configurate(size: 25)
                        .lineLimit(2)
                        .padding(.horizontal, 15)
                        .padding(.top, 20)
                }
                
                // Search Bar and List of reasons
                ScrollView {
                    
                    // Search Bar
                    if !reasonList.isEmpty {
                        SearchBar(searchText: $searchText)
                            .frame(width: UIScreen.main.bounds.width * 0.95 + 15)
                    }
                    
                    LazyVStack(spacing: 15) {
                        TitledContent("Eigene erstellen") {
                            CustomReasonRow(selectedFineReason: $fineReason)
                                .toggleOnTapGesture($showCustomFineReasonSheet)
                                .sheet(isPresented: $showCustomFineReasonSheet) {
                                    AddNewFineCustomReason(with: fineReason) { newFineReason in
                                        fineReason = newFineReason
                                    }
                                }
                        }
                        
                        if !reasonList.sortedForList(with: searchText).isEmpty {
                            TitledContent("Strafenkatalog") {
                                ForEach(reasonList.sortedForList(with: searchText)) { reason in
                                    ReasonListRow(reason: reason, selectedFineReason: $fineReason)
                                        .onTapGesture {
                                            fineReason = reason.id == (fineReason as? FineReasonTemplate)?.templateId ? nil : FineReasonTemplate(templateId: reason.id)
                                        }
                                }
                            }
                        }
                    }.padding(.bottom, 10)
                    
                }.padding(.vertical, 10)
                
            } else {
                Text("No available view")
            }
            
            Spacer()
            
            // Cancel and Confirm button
            VStack(spacing: 5) {
                CancelConfirmButton()
                    .onCancelPress { presentationMode.wrappedValue.dismiss() }
                    .onConfirmPress {
                        errorMessages = nil
                        guard let fineReason = fineReason else { return errorMessages = .noReasonSelected }
                        completionHandler(fineReason)
                        presentationMode.wrappedValue.dismiss()
                    }
                ErrorMessageView(errorMessages: $errorMessages)
            }.padding(.bottom, errorMessages == nil ? 50 : 25).animation(.default)
            
        }.setScreenSize
            .onAppear {
                fineReason = oldFineReason
            }
    }
    
    /// Row for custom fine reason
    struct CustomReasonRow: View {
        
        /// Selected fine reason
        @Binding var selectedFineReason: FineReason?
        
        var body: some View {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                
                    // Left of the divider
                    ZStack {
                        
                        // Outline
                        Outline(.left)
                            .fillColor(default: (selectedFineReason as? FineReasonCustom).map {_ in Color.custom.lightGreen })
                        
                        // Text
                        HStack(spacing: 0) {
                            Text((selectedFineReason as? FineReasonCustom)?.reason ?? "Auswählen")
                                .foregroundColor(plain: (selectedFineReason as? FineReasonCustom).map {_ in Color.custom.lightGreen } ?? .textColor)
                                .opacity((selectedFineReason as? FineReasonCustom).map {_ in 1 } ?? 0.5)
                                .font(.text(20))
                                .lineLimit(1)
                                .padding(.horizontal, 15)
                            Spacer()
                        }
                        
                    }.frame(width: geometry.size.width * 0.7)
                    
                    // Right of the divider
                    ZStack {

                        // Outline
                        Outline(.right)
                            .fillColor(default: selectedFineReason.flatMap { ($0 as? FineReasonCustom)?.importance.color } ?? Color.custom.red)

                        // Text
                        Text(String(describing: (selectedFineReason as? FineReasonCustom)?.amount ?? .zero))
                            .foregroundColor(plain: (selectedFineReason as? FineReasonCustom)?.importance.color ?? Color.custom.red)
                            .font(.text(20))
                            .lineLimit(1)

                    }.frame(width: geometry.size.width * 0.3)
                    
                }
            }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
        }
    }
    
    /// Row of reason list
    struct ReasonListRow: View {
        
        /// Reason of this row
        let reason: ReasonTemplate
        
        @Binding var selectedFineReason: FineReason?
        
        var body: some View {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                
                    // Left of the divider
                    ZStack {
                        
                        // Outline
                        Outline(.left)
                            .fillColor(reason.id == (selectedFineReason as? FineReasonTemplate)?.templateId ? Color.custom.lightGreen : nil)
                        
                        // Text
                        HStack(spacing: 0) {
                            Text(reason.reason)
                                .foregroundColor(plain: reason.id == (selectedFineReason as? FineReasonTemplate)?.templateId ? Color.custom.lightGreen : .textColor)
                                .font(.text(20))
                                .lineLimit(1)
                                .padding(.horizontal, 15)
                            Spacer()
                        }
                        
                    }.frame(width: geometry.size.width * 0.7)
                    
                    // Right of the divider
                    ZStack {
                        
                        // Outline
                        Outline(.right)
                            .fillColor(reason.importance.color)
                        
                        // Text
                        Text(String(describing: reason.amount))
                            .foregroundColor(plain: reason.importance.color)
                            .font(.text(20))
                            .lineLimit(1)
                        
                    }.frame(width: geometry.size.width * 0.3)
                    
                }
            }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
        }
    }
}

// Extension of Array to filter and sort it for fine editor reason list
extension Array where Element == ReasonTemplate {
    
    /// Filtered and sorted for fine editor reason list
    fileprivate func sortedForList(with searchText: String) -> [Element] {
        filter(for: searchText, at: \.reason).sorted(by: \.reason.localizedUppercase)
    }
}
