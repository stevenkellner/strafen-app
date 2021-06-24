//
//  SingleAmountDisplay.swift
//  Strafen
//
//  Created by Steven on 29.05.21.
//

import SwiftUI

/// Displays amount of a type
struct SingleAmountDisplay: View {

    /// Types of this display
    enum DisplayType {

        /// Payed
        case payed

        /// Unpayed
        case unpayed

        /// Total
        case total

        /// Text
        var text: String {
            switch self {
            case .payed:
                return String(localized: "amount-sum-payed-text", comment: "Text of an amount display for amount sum of all payed fines.")
            case .unpayed:
                return String(localized: "amount-sum-low-importance-text", comment: "Text of an amount display for amount sum of all unpayed fines with low importance.")
            case .total:
                return String(localized: "amount-sum-total-text", comment: "Text of an amount display for amount sum of all fines.")
            }
        }

        /// Color
        var color: Color {
            switch self {
            case .payed:
                return .customGreen
            case .unpayed:
                return .customRed
            case .total:
                return .customBlue
            }
        }

        /// Complte amount sum
        /// - Parameters:
        ///   - personId: id of person of the fines
        ///   - fineList: list of all fines
        ///   - reasonList: list of all reason templates
        /// - Returns: sum of complete amount
        func amountSum(of personId: FirebasePerson.ID, with fineList: [FirebaseFine], reasonList: [FirebaseReasonTemplate]) -> Amount {
            switch self {
            case .payed:
                return fineList.payed(of: personId, with: reasonList)
            case .unpayed:
                return fineList.unpayed(of: personId, with: reasonList)
            case .total:
                return fineList.total(of: personId, with: reasonList)
            }
        }
    }

    /// Type of this display
    let displayType: DisplayType

    /// Init with display type
    init(_ displayType: DisplayType) {
        self.displayType = displayType
    }

    /// Currently logged in person
    @EnvironmentObject var person: Settings.Person

    /// Environment of the fine list
    @EnvironmentObject var fineListEnvironment: ListEnvironment<FirebaseFine>

    /// Environment of the reason list
    @EnvironmentObject var reasonListEnvironment: ListEnvironment<FirebaseReasonTemplate>

    var body: some View {
        SplittedOutlinedContent {
            Text(verbatim: "\(displayType.text):")
                .foregroundColor(.textColor)
                .font(.system(size: 16, weight: .thin))
                .lineLimit(1)
                .padding(.horizontal, 2)
                .unredacted()
        } rightContent: {
            Text(describing: displayType.amountSum(of: person.id, with: fineListEnvironment.list, reasonList: reasonListEnvironment.list))
                .foregroundColor(displayType.color)
                .font(.system(size: 16, weight: .thin))
                .lineLimit(1)
                .padding(.horizontal, 2)
        }.leftWidthPercentage(100 / 175)
            .frame(width: 175, height: 35)
    }
}
