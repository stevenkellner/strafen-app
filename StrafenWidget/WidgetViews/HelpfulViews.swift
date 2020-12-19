//
//  HelpfulViews.swift
//  StrafenWidgetExtension
//
//  Created by Steven on 12/19/20.
//

import SwiftUI

/// Display payed, unpayed or total amount sum of a person
struct AmountDisplay: View {
    
    /// Type of a display
    enum DisplayType {
        
        /// Payed
        case payed
        
        /// Unpayed
        case unpayed
        
        /// Total
        case total
        
        /// Color
        var color: Color {
            switch self {
            case .payed:
                return Color.custom.lightGreen
            case .unpayed:
                return Color.custom.red
            case .total:
                return Color.custom.blue
            }
        }
        
        /// Title
        var title: String {
            switch self {
            case .payed:
                return "Bezahlt"
            case .unpayed:
                return "Ausstehend"
            case .total:
                return "Gesamt"
            }
        }
        
        /// Path to amount
        var amountPath: KeyPath<Array<Fine>.AmountSum, Amount> {
            switch self {
            case .payed:
                return \.payed
            case .unpayed:
                return \.unpayed
            case .total:
                return \.total
            }
        }
    }
    
    /// Person id
    let personId: Person.ID
    
    /// Display type
    let displayType: DisplayType
    
    init(of personId: Person.ID, type displayType: DisplayType) {
        self.personId = personId
        self.displayType = displayType
    }
    
    /// Fine List Data
    @ObservedObject var fineListData = ListData.fine
    
    /// Reason List Data
    @ObservedObject var reasonListData = ListData.reason
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                Spacer()
                
                // Left of Divider
                ZStack {
                    
                    // Outline
                    Outline(.left)
                    
                    // Text
                    Text("\(displayType.title):")
                        .configurate(size: 12)
                        .padding(.horizontal, 2.5)
                        .lineLimit(1)
                        .unredacted()
                    
                }.frame(width: geometry.size.width * 0.50)
                
                // Right of Divider
                ZStack {
                    
                    // Outline
                    Outline(.right)
                        .fillColor(displayType.color)
                    
                    // Amount
                    Text(describing: amountSum[keyPath: displayType.amountPath])
                        .foregroundColor(plain: displayType.color)
                        .font(.text(15))
                        .padding(.horizontal, 2.5)
                        .lineLimit(1)
                    
                }.frame(width: geometry.size.width * 0.35)
                
                Spacer()
            }
        }.frame(height: 35)
    }
    
    /// Amount sum
    var amountSum: Array<Fine>.AmountSum {
        fineListData.list?.amountSum(of: personId, with: reasonListData.list) ?? .zero
    }
}

/// Row of fine list
struct FineListRow: View {
    
    /// Fine
    let fine: Fine
    
    /// Reason List Data
    @ObservedObject var reasonListData = ListData.reason
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                Spacer()
                
                // Left of Divider
                ZStack {
                    
                    // Outline
                    Outline(.left)
                    
                    // Text
                    Text(completeFineReason.reason)
                        .configurate(size: 12)
                        .padding(.horizontal, 2.5)
                        .lineLimit(1)
                    
                }.frame(width: geometry.size.width * 0.50)
                
                // Right of the Divider
                ZStack {
                    
                    // Outline
                    Outline(.right)
                        .fillColor(color)
                    
                    // Amount
                    Text(describing: fine.completeAmount(with: reasonListData.list))
                        .foregroundColor(plain: color)
                        .font(.text(15))
                        .padding(.horizontal, 2.5)
                        .lineLimit(1)
                    
                }.frame(width: geometry.size.width * 0.35)
                
                Spacer()
            }
        }.frame(height: 35)
    }
    
    /// Complete fine reason
    var completeFineReason: FineReasonCustom {
        fine.fineReason.complete(with: reasonListData.list)
    }
    
    /// Color
    var color: Color {
        fine.isPayed ? Color.custom.lightGreen : completeFineReason.importance.color
    }
}
