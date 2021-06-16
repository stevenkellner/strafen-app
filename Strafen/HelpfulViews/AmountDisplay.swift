//
//  AmountDisplay.swift
//  Strafen
//
//  Created by Steven on 16.06.21.
//

import SwiftUI

/// Total / Payed / Unpayed Amount Display
struct AmountDisplay: View {

    /// Id of the person
    let personId: FirebasePerson.ID

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
            case .total: return "\(String(localized: "amount-sum-total-text", comment: "Text of an amount display for amount sum of all fines.")):"
            case .payed: return "\(String(localized: "amount-sum-payed-text", comment: "Text of an amount display for amount sum of all payed fines.")):"
            case .high: return "\(String(localized: "amount-sum-high-importance-text", comment: "Text of an amount display for amount sum of all unpayed fines with high importance.")):"
            case .medium: return "\(String(localized: "amount-sum-medium-importance-text", comment: "Text of an amount display for amount sum of all unpayed fines with medium importance.")):"
            case .low: return "\(String(localized: "amount-sum-low-importance-text", comment: "Text of an amount display for amount sum of all unpayed fines with low importance.")):"
            }
        }

        /// Importance / Payed color
        var color: Color {
            switch self {
            case .total: return .customBlue
            case .payed: return .customGreen
            case .high: return .customRed
            case .medium: return .customOrange
            case .low: return .customYellow
            }
        }

        /// Next state
        var next: AmountDisplayState {
            switch self {
            case .total: return .payed
            case .payed: return .low
            case .low: return .medium
            case .medium: return .high
            case .high: return .total
            }
        }

        /// Previous state
        var previous: AmountDisplayState {
            switch self {
            case .total: return .high
            case .payed: return .total
            case .low: return .payed
            case .medium: return .low
            case .high: return .medium
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
        /// - Parameter other: other state to calculate offset
        /// - Returns: offset of the two states
        private func offset(to other: AmountDisplayState) -> Int {
            var result = other.rawValue - rawValue
            if abs(result) >= 3 {
                result -= result.signum() * 5
            }
            return result
        }

        /// Number of x offset to given state
        /// - Parameter other: other state to calculate offset
        /// - Returns: x offset of the two states
        func xOffset(to other: AmountDisplayState) -> Int {
            offset(to: other)
        }

        /// Number of y offset to given state
        /// - Parameter other: other state to calculate offset
        /// - Returns: y offset of the two states
        func yOffset(to other: AmountDisplayState) -> Int {
            abs(offset(to: other)) >= 2 ? 1 : 0
        }

        /// Amount sum of the state
        /// - Parameters:
        ///   - personId: id of person of the fines
        ///   - fineList: list of all fines
        ///   - reasonList: list of all reason templates
        /// - Returns: sum of complete amount
        func amount(of personId: FirebasePerson.ID, _ fineList: [FirebaseFine], with reasonList: [FirebaseReasonTemplate]) -> Amount {
            switch self {
            case .total: return fineList.total(of: personId, with: reasonList)
            case .payed: return fineList.payed(of: personId, with: reasonList)
            case .high: return fineList.high(of: personId, with: reasonList)
            case .medium: return fineList.medium(of: personId, with: reasonList)
            case .low: return fineList.unpayed(of: personId, with: reasonList)
            }
        }
    }

    /// Current shown display state
    @State private var currentDisplay: AmountDisplayState = .total

    /// Time stamp of last dragging
    @State private var dragTimeStamp = Date().timeIntervalSinceReferenceDate

    var body: some View {
        ZStack {
            AmountDisplayField(state: .total, personId: personId, currentDisplay: $currentDisplay)
            AmountDisplayField(state: .payed, personId: personId, currentDisplay: $currentDisplay)
            AmountDisplayField(state: .low, personId: personId, currentDisplay: $currentDisplay)
            AmountDisplayField(state: .medium, personId: personId, currentDisplay: $currentDisplay)
            AmountDisplayField(state: .high, personId: personId, currentDisplay: $currentDisplay)
        }.frame(height: 75)
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
                if value.translation.width >= 25 {
                    currentDisplay.toPreviousState()
                } else if value.translation.width <= -25 {
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
        let personId: FirebasePerson.ID

        /// Current shown display state
        @Binding var currentDisplay: AmountDisplayState

        /// Environment of the fine list
        @EnvironmentObject var fineListEnvironment: ListEnvironment<FirebaseFine>

        /// Environment of the reason list
        @EnvironmentObject var reasonListEnvironment: ListEnvironment<FirebaseReasonTemplate>

        var body: some View {
            SplittedOutlinedContent {

                // Left content
                HStack(spacing: 0) {
                    Text(state.text)
                        .foregroundColor(.textColor)
                        .font(.system(size: 20, weight: .thin))
                        .lineLimit(1)
                        .padding(.horizontal, 20)
                    Spacer()
                }

            } rightContent: {

                // Right content
                Text(describing: state.amount(of: personId, fineListEnvironment.list, with: reasonListEnvironment.list))
                    .foregroundColor(state.color)
                    .font(.system(size: 20, weight: .thin))
                    .lineLimit(1)

            }.leftWidthPercentage(0.675)
                .frame(width: UIScreen.main.bounds.width * 0.75, height: 50)
                .offset(x: -UIScreen.main.bounds.width * 0.80 * CGFloat(state.xOffset(to: currentDisplay)), y: -100 * CGFloat(state.yOffset(to: currentDisplay)))
        }
    }
}
