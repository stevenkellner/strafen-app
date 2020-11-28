//
//  FineListRow.swift
//  Strafen
//
//  Created by Steven on 11/24/20.
//

import SwiftUI

/// Row of fine list of profile / person detail
struct FineListRow: View {
    
    /// Fine
    let fine: NewFine
    
    /// Id of selected row for large design
    @Binding var selectedForLargeDesign: UUID?
    
    /// With open url
    let withOpenUrl: Bool
    
    ///Dismiss handler
    @Binding var dismissHandler: DismissHandler
    
    init(of fine: NewFine, selectedForLargeDesign: Binding<UUID?>, withOpenUrl: Bool = false, dismissHandler: Binding<DismissHandler>) {
        self.fine = fine
        self._selectedForLargeDesign = selectedForLargeDesign
        self.withOpenUrl = withOpenUrl
        self._dismissHandler = dismissHandler
    }
    
    /// Namespace for matched geometry effect
    @Namespace var namespace
    
    /// Indicates if navigation link is active
    @State var isNavigationLinkActive = false
    
    var body: some View {
        ZStack {
            
            // Navigation Link
            EmptyNavigationLink(isActive: $isNavigationLinkActive) {
                FineDetail(fine: fine, dismissHandler: $dismissHandler)
            }
            
            if selectedForLargeDesign == fine.id {
                
                // Large row
                LargeRow(fine: fine, namespace: namespace, isNavigationLinkActive: $isNavigationLinkActive)
                    .setOnTapGesture($selectedForLargeDesign, to: nil, animation: .default)
                
            } else {
                
                // Small row
                SmallRow(fine: fine, namespace: namespace, isNavigationLinkActive: $isNavigationLinkActive)
                    .setOnTapGesture($selectedForLargeDesign, to: fine.id, animation: .default)
                
            }
            
        }.onOpenURL { url in
            if withOpenUrl {
                isNavigationLinkActive = url.lastPathComponent == fine.id.uuidString
            }
        }
    }
    
    /// Small row
    struct SmallRow: View {
        
        /// Fine
        let fine: NewFine
        
        /// Reason List Data
        @ObservedObject var reasonListData = NewListData.reason
        
        /// Namespace for matched geometry effect
        let namespace: Namespace.ID
        
        /// Indicates if navigation link is active
        @Binding var isNavigationLinkActive: Bool
        
        var body: some View {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    
                    // Left of the divider
                    ZStack {
                        
                        // Outline
                        Outline(.left)
                            .fillColor(fine.amountTextColor(with: reasonListData.list))
                        
                        // Inside
                        Text(describing: fine.completeAmount(with: reasonListData.list))
                            .foregroundColor(plain: fine.amountTextColor(with: reasonListData.list))
                            .font(.text(20))
                            .lineLimit(1)
                            .matchedGeometryEffect(id: "firstOutline", in: namespace)
                        
                    }.frame(width: geometry.size.width * 0.3)
                    
                    // Right of the divider
                    ZStack {
                        
                        // Outline
                        Outline(.right)
                        
                        // Inside
                        HStack(spacing: 0) {
                            
                            // Text
                            Text(fine.fineReason.reason(with: reasonListData.list))
                                .configurate(size: 20)
                                .padding(.leading, 10)
                                .lineLimit(1)
                                .matchedGeometryEffect(id: "reason", in: namespace)
                            
                            Spacer()
                            
                            // Arrow
                            HStack(spacing: 0) {
                                Image(systemName: "control")
                                    .rotationEffect(.radians(.pi / 2))
                                    .font(.system(size: 20, weight: .light))
                                    .foregroundColor(.textColor)
                                Spacer()
                            }.frame(width: geometry.size.width * 0.1, height: geometry.size.height)
                                .matchedGeometryEffect(id: "secondOutline", in: namespace)
                                .toggleOnTapGesture($isNavigationLinkActive)
                        }
                        
                    }.frame(width: geometry.size.width * 0.7)
                    
                }
            }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
        }
    }
    
    /// Large row
    struct LargeRow: View {
        
        /// Fine
        let fine: NewFine
        
        /// Reason List Data
        @ObservedObject var reasonListData = NewListData.reason
        
        /// Namespace for matched geometry effect
        let namespace: Namespace.ID
        
        /// Indicates if navigation link is active
        @Binding var isNavigationLinkActive: Bool
        
        var body: some View {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    
                    // Top row
                    HStack(spacing: 0) {
                        
                        // Left of the divider
                        ZStack {
                            
                            // Outline
                            Outline(.topLeft)
                                .fillColor(fine.amountTextColor(with: reasonListData.list))
                            
                            // Amount
                            Text(describing: fine.completeAmount(with: reasonListData.list))
                                .foregroundColor(plain: fine.amountTextColor(with: reasonListData.list))
                                .font(.text(20))
                                .lineLimit(1)
                                .matchedGeometryEffect(id: "firstOutline", in: namespace)
                            
                        }.frame(width: geometry.size.width * 0.382)
                        
                        // Right of the divider
                        ZStack {
                            
                            // Outline
                            Outline(.topRight)
                                
                            // Date
                            Text(describing: fine.date.formattedLong)
                                .configurate(size: 20)
                                .lineLimit(1)
                            
                        }.frame(width: geometry.size.width * 0.618)
                        
                    }.frame(height: geometry.size.height * 0.5)
                    
                    // Bottom row
                    ZStack {
                        
                        // Outline
                        Outline(.bottom)
                        
                        // Inside
                        HStack(spacing: 0) {
                            
                            // Text
                            Text(fine.fineReason.reason(with: reasonListData.list))
                                .configurate(size: 20)
                                .padding(.leading, 15)
                                .lineLimit(1)
                                .matchedGeometryEffect(id: "reason", in: namespace)
                            
                            Spacer()
                            
                            // Arrow
                            HStack(spacing: 0) {
                                Image(systemName: "control")
                                    .rotationEffect(.radians(.pi / 2))
                                    .font(.system(size: 20, weight: .light))
                                    .foregroundColor(.textColor)
                                Spacer()
                            }.frame(width: geometry.size.width * 0.1, height: geometry.size.height * 0.5)
                                .matchedGeometryEffect(id: "secondOutline", in: namespace)
                                .toggleOnTapGesture($isNavigationLinkActive)
                            
                        }
                        
                    }.frame(height: geometry.size.height * 0.5)
                }
            }.frame(width: UIScreen.main.bounds.width * 0.95, height: 100)
        }
    }
}
