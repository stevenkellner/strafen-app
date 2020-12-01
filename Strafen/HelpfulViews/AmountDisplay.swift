//
//  AmountDisplay.swift
//  Strafen
//
//  Created by Steven on 14.07.20.
//

import SwiftUI

/// Total / Payed / Unpayed Amount Display
struct AmountDisplay: View {
    
    /// Id of the person
    let personId: UUID
    
    /// State of amount display
    enum AmountDisplayState: Int {
        
        /// total amount sum
        case total = 0
        
        /// payed amount sum
        case payed = 1
        
        /// high amount sum
        case high = 4
        
        /// medium amount sum
        case medium = 3
        
        /// low amount sum
        case low = 2
        
        /// Text on the left side
        var text: String {
            switch self {
            case .total:
                return "Gesamt:"
            case .payed:
                return "Bezahlt:"
            case .high:
                return "Wichtigstes:"
            case .medium:
                return "Mittleres:"
            case .low:
                return "Ausstehend:"
            }
        }
        
        /// Importance / Payed color
        var color: Color {
            switch self {
            case .total:
                return Color.custom.blue
            case .payed:
                return Color.custom.lightGreen
            case .high:
                return Color.custom.red
            case .medium:
                return Color.custom.orange
            case .low:
                return Color.custom.yellow
            }
        }
        
        /// Next state
        var next: Self {
            switch self {
            case .total:
                return .payed
            case .payed:
                return .low
            case .low:
                return .medium
            case .medium:
                return .high
            case .high:
                return .total
            }
        }
        
        /// Previous state
        var previous: Self {
            switch self {
            case .total:
                return .high
            case .payed:
                return .total
            case .low:
                return .payed
            case .medium:
                return .low
            case .high:
                return .medium
            }
        }
        
        /// Gets to the next state
        mutating func toNextState() {
            self = next
        }
        
        /// Gets to the previous state
        mutating func toPreviousState() {
            self = previous
        }
        
        /// Number of offset to given state
        func offset(to other: Self) -> Int {
            var result = other.rawValue - rawValue
            if abs(result) >= 3 {
                result = result - result.signum() * 5
            }
            return result
        }
        
        /// Number of offset size to given state
        func offsetSize(to other: Self) -> CGSize {
            CGSize(width: offset(to: other), height: abs(offset(to: other)) >= 2 ? 1 : 0)
        }
        
        /// Amount sum of the state
        func amount(of personId: UUID, _ fineList: [NewFine]?, with reasonList: [ReasonTemplate]?) -> Amount {
            guard let amountSum = fineList?.amountSum(of: personId, with: reasonList) else { return .zero }
            switch self {
            case .total:
                return amountSum.total
            case .payed:
                return amountSum.payed
            case .high:
                return amountSum.high
            case .medium:
                return amountSum.medium
            case .low:
                return amountSum.unpayed
            }
        }
    }
    
    /// Current shown display state
    @State var currentDisplay: AmountDisplayState = .total
    
    /// Time stamp of last dragging
    @State var dragTimeStamp = Date().timeIntervalSinceReferenceDate
    
    var body: some View {
        ZStack {
            AmountDisplayField(state: .total, personId: personId, currentDisplay: $currentDisplay)
            AmountDisplayField(state: .payed, personId: personId, currentDisplay: $currentDisplay)
            AmountDisplayField(state: .low, personId: personId, currentDisplay: $currentDisplay)
            AmountDisplayField(state: .medium, personId: personId, currentDisplay: $currentDisplay)
            AmountDisplayField(state: .high, personId: personId, currentDisplay: $currentDisplay)
        }.frame(height: 52)
            .frame(maxWidth: .infinity)
            .clipped()
            .onTapGesture(perform: tapToNextDisplay)
            .gesture(DragGesture().onChanged(dragToAdjacentDisplay))
    }
    
    /// Go to next display
    func tapToNextDisplay() {
        withAnimation {
            if Date().timeIntervalSinceReferenceDate - dragTimeStamp >= 0.25 {
                dragTimeStamp = Date().timeIntervalSinceReferenceDate
                currentDisplay.toNextState()
            }
        }
    }
    
    /// Go to next or previous diplay depending on value
    func dragToAdjacentDisplay(value: DragGesture.Value) {
        withAnimation {
            if Date().timeIntervalSinceReferenceDate - dragTimeStamp >= 0.25 {
                dragTimeStamp = Date().timeIntervalSinceReferenceDate
                if value.translation.width >= 50 {
                    currentDisplay.toPreviousState()
                } else if value.translation.width <= -50 {
                    currentDisplay.toNextState()
                }
            }
        }
    }
    
    /// Amount display field
    struct AmountDisplayField: View {
        
        /// Display state of this field
        let state: AmountDisplayState
        
        /// Id of the person
        let personId: UUID
        
        /// Current shown display state
        @Binding var currentDisplay: AmountDisplayState
        
        /// Fine List Data
        @ObservedObject var fineListData = NewListData.fine
        
        /// Reason List Data
        @ObservedObject var reasonListData = NewListData.reason
        
        var body: some View {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Spacer()
                
                    // Left of the divider
                    ZStack {
                        
                        // Outline
                        Outline(.left)
                        
                        // Inside
                        HStack(spacing: 0) {
                            Text(state.text)
                                .configurate(size: 20)
                                .lineLimit(1)
                                .padding(.horizontal, 25)
                            Spacer()
                        }
                        
                    }.frame(width: UIScreen.main.bounds.width * 0.675)
                
                    // Right of the divider
                    ZStack {
                        
                        // Outline
                        Outline(.right)
                            .fillColor(state.color)
                        
                        // Inside
                        Text(describing: state.amount(of: personId, fineListData.list, with: reasonListData.list))
                            .foregroundColor(plain: state.color)
                            .font(.text(20))
                            .lineLimit(1)
                        
                    }.frame(width: UIScreen.main.bounds.width * 0.275)
                
                    Spacer()
                }.frame(height: 50)
                    .padding(.vertical, 1)
                    .offset(-geometry.size.width * state.offsetSize(to: currentDisplay))
            }
        }
        
    }
}
