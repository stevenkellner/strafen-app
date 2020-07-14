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
        func amount(of personId: UUID, _ fineList: [Fine]) -> Euro {
            switch self {
            case .total:
                return fineList.totalAmountSum(of: personId)
            case .payed:
                return fineList.payedAmountSum(of: personId)
            case .high:
                return fineList.highAmountSum(of: personId)
            case .medium:
                return fineList.mediumAmountSum(of: personId)
            case .low:
                return fineList.unpayedAmountSum(of: personId)
            }
        }
    }
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Current shown display state
    @State var currentDisplay: AmountDisplayState = .total
    
    /// Time stamp of last dragging
    @State var dragTimeStamp = Date().timeIntervalSince1970
    
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
            .onTapGesture {
                withAnimation {
                    if Date().timeIntervalSince1970 - dragTimeStamp >= 0.25 {
                        dragTimeStamp = Date().timeIntervalSince1970
                        currentDisplay.toNextState()
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        withAnimation {
                            if Date().timeIntervalSince1970 - dragTimeStamp >= 0.25 {
                                dragTimeStamp = Date().timeIntervalSince1970
                                if value.translation.width >= 50 {
                                    currentDisplay.toPreviousState()
                                } else if value.translation.width <= -50 {
                                    currentDisplay.toNextState()
                                }
                            }
                        }
                    }
            )
    }
    
    /// Amount display field
    struct AmountDisplayField: View {
        
        /// Display state of this field
        let state: AmountDisplayState
        
        /// Id of the person
        let personId: UUID
        
        /// Current shown display state
        @Binding var currentDisplay: AmountDisplayState
        
        /// Observed Object that contains all settings of the app of this device
        @ObservedObject var settings = Settings.shared
        
        /// Fine List Data
        @ObservedObject var fineListData = ListData.fine
        
        var body: some View {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Spacer()
                
                    // Left of the divider
                    ZStack {
                        
                        // Outline
                        Outline(.left)
                        
                        // Inside
                        Text(state.text)
                            .foregroundColor(.textColor)
                            .font(.text(20))
                            .lineLimit(1)
                            .padding(.horizontal, 5)
                        
                    }.frame(width: 245)
                
                    // Right of the divider
                    ZStack {
                        
                        // Outline
                        Outline(.right)
                            .fillColor(state.color)
                        
                        // Inside
                        Text(String(describing: state.amount(of: personId, fineListData.list!)))
                            .foregroundColor(settings.style == .default ? .textColor : state.color)
                            .font(.text(20))
                            .lineLimit(1)
                        
                    }.frame(width: 100)
                
                    Spacer()
                }.frame(height: 50)
                    .padding(.vertical, 1)
                    .offset(-geometry.size.width * state.offsetSize(to: currentDisplay))
            }
        }
        
    }
}

#if DEBUG
struct AmountDisplay_Previews: PreviewProvider {
    static var previews: some View {
        AmountDisplay(personId: UUID(uuidString: "ADB004F2-ACD2-42E2-8FB5-3591A43C6F9C")!)
            .previewDevice("iPhone 11")
    }
}
#endif
