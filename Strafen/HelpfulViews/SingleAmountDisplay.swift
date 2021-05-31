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
                return NSLocalizedString("amount-sum-payed-text", table: .otherTexts, comment: "Text of payed amount sum")
            case .unpayed:
                return NSLocalizedString("amount-sum-low-importance-text", table: .otherTexts, comment: "Text of amount sum with low importance")
            case .total:
                return NSLocalizedString("amount-sum-total-text", table: .otherTexts, comment: "Text of total amount sum")
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
            Text("\(displayType.text):")
                .foregroundColor(.textColor)
                .font(.system(size: 16, weight: .thin))
                .lineLimit(1)
                .padding(.horizontal, 2)
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
