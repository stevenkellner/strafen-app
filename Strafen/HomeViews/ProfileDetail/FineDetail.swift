//
//  FineDetail.swift
//  Strafen
//
//  Created by Steven on 30.05.21.
//

import SwiftUI

/// Detail of a fine
struct FineDetail: View {

    /// Environment of the person list
    @EnvironmentObject var personListEnvironment: ListEnvironment<FirebasePerson>

    /// Environment of the reason list
    @EnvironmentObject var reasonListEnvironment: ListEnvironment<FirebaseReasonTemplate>

    /// Fine of this detail view
    let fine: FirebaseFine

    var body: some View {
        ZStack {

            // Background color
            Color.backgroundGray

            VStack(spacing: 0) {

                // Back / edit button and Header
                VStack(spacing: 10) {

                    // Back / edit button
                    BackAndEditButton {
                        FineEditor(fine: fine)
                    }

                    // Fine of text
                    HStack(spacing: 0) {
                        Text("fine-detail-fine-of-text", table: .profileDetail, comment: "Fine detail view fine of text")
                            .foregroundColor(.textColor)
                            .font(.system(size: 20, weight: .thin))
                            .lineLimit(1)
                            .padding(.leading, 10)
                        Spacer()
                    }

                    // Person Name
                    HStack(spacing: 0) {
                        Text(associatedPersonName)
                            .foregroundColor(.textColor)
                            .font(.system(size: 35, weight: .thin))
                            .lineLimit(1)
                            .padding(.horizontal, 25)
                        Spacer()
                    }

                    // Underlines
                    Header.Underlines()

                }.padding(.top, 50)

                Spacer()

                // Reason
                Text(fine.reason(with: reasonListEnvironment.list))
                    .foregroundColor(.textColor)
                    .font(.system(size: 35, weight: .thin))
                    .lineLimit(1)
                    .padding(.horizontal, 25)

                Spacer()

                // Amount
                AmountText(fine: fine)

                Spacer()

                // Date
                Text(fine.date.formattedLong)
                    .foregroundColor(.textColor)
                    .font(.system(size: 35, weight: .thin))
                    .lineLimit(1)
                    .padding(.horizontal, 25)

                Spacer()

                // Payed display
                VStack(spacing: 5) {
                    PayedDisplay(fine: fine)

                    if fine.isSettled {
                        Text("fine-detail-payment-in-process", table: .profileDetail, comment: "Fine detail payment in process")
                            .foregroundColor(.textColor)
                            .font(.system(size: 25, weight: .thin))
                            .padding(.horizontal, 25)
                            .lineLimit(1)
                    } else if fine.payed.payedInApp {
                        Text("fine-detail-payed-in-app", table: .profileDetail, comment: "Fine detail payed in app")
                            .foregroundColor(.textColor)
                            .font(.system(size: 25, weight: .thin))
                            .padding(.horizontal, 25)
                            .lineLimit(1)
                    }
              }

                Spacer()
            }

        }.maxFrame.dismissHandler
    }

    /// Name of associated person
    var associatedPersonName: String {
        personListEnvironment.list.first { $0.id == fine.assoiatedPersonId }?.name.formatted ?? NSLocalizedString("fine-detail-unknown-person-name", table: .profileDetail, comment: "Fine detail unknown person name")
    }

    /// Amount text
    struct AmountText: View {

        /// Environment of the reason list
        @EnvironmentObject var reasonListEnvironment: ListEnvironment<FirebaseReasonTemplate>

        /// Fine
        let fine: FirebaseFine

        var body: some View {
            VStack(spacing: 5) {

                // Original Amount
                HStack(spacing: 25) {
                    if fine.number != 1 {
                        Text("\(fine.number) *")
                            .foregroundColor(.textColor)
                            .font(.system(size: 50, weight: .thin))
                            .lineLimit(1)
                    }

                    Text(describing: fine.fineReason.amount(with: reasonListEnvironment.list))
                        .foregroundColor(.textColor)
                        .font(.system(size: 50, weight: .thin))
                        .lineLimit(1)

                }.padding(.horizontal, 25)

                // Late payment interest
                if let latePaymentInterest = fine.latePaymentInterestAmount(with: reasonListEnvironment.list), latePaymentInterest != .zero {
                    Text("+ \(String(describing: latePaymentInterest)) Verzugszinsen")
                        .foregroundColor(.textColor)
                        .font(.system(size: 25, weight: .thin))
                        .padding(.horizontal, 25)
                        .lineLimit(1)
                }

            }
        }
    }

    /// Payed display
    struct PayedDisplay: View {

        /// Environment of the reason list
        @EnvironmentObject var reasonListEnvironment: ListEnvironment<FirebaseReasonTemplate>

        /// Environment of the fine list
        @EnvironmentObject var fineListEnvironment: ListEnvironment<FirebaseFine>

        /// Currently logged in person
        @EnvironmentObject var person: Settings.Person

        /// Fine
        let fine: FirebaseFine

        /// State of data task connection
        @State var connectionStateToPayed: ConnectionState = .passed

        /// State of data task connection
        @State var connectionStateToUnpayed: ConnectionState = .passed

        /// Error messages
        @State var errorMessages: ErrorMessages?

        var body: some View {
            VStack(spacing: 5) {
                ZStack {

                    // Outlines
                    SplittedOutlinedContent {
                        if connectionStateToUnpayed == .loading { ProgressView() }
                    } rightContent: {
                        if connectionStateToPayed == .loading { ProgressView() }
                    }.leftFillColor(fine.importance(with: reasonListEnvironment.list).color)
                        .rightFillColor(.customGreen)
                        .onLeftTapGesture(handleSaveToUnpayed)
                        .onRightTapGesture(handleSaveToPayed)
                        .frame(width: 200, height: 50)

                    // Indicator
                    Indicator(width: 33)
                        .offset(x: fine.isPayed ? 50 : -50)

                }

                // Error message
                ErrorMessageView($errorMessages)

            }
        }

        /// Handles save to unpayed
        func handleSaveToUnpayed() {
            guard person.isCashier else { return }
            guard connectionStateToPayed != .loading,
                  connectionStateToUnpayed.restart() == .passed else { return }
            guard fine.isPayed && !fine.isSettled && !fine.payed.payedInApp else { return }
            errorMessages = nil

            let callItem = FFChangeFinePayed(clubId: person.club.id, fineId: fine.id, newState: .unpayed)
            FirebaseFunctionCaller.shared.call(callItem).then { _ in
                fineListEnvironment.changeListItemInout(fine.id) { $0.payed = .unpayed }
                connectionStateToUnpayed.passed()
            }.catch { _ in
                errorMessages = .internalErrorSave
                connectionStateToUnpayed.failed()
            }
        }

        /// Handles save to payed
        func handleSaveToPayed() {
            guard person.isCashier else { return }
            guard connectionStateToUnpayed != .loading,
                  connectionStateToPayed.restart() == .passed else { return }
            guard !fine.isPayed && !fine.isSettled && !fine.payed.payedInApp else { return }
            errorMessages = nil

            let payedState: Payed = .payed(date: Date(), inApp: false)
            let callItem = FFChangeFinePayed(clubId: person.club.id, fineId: fine.id, newState: payedState)
            FirebaseFunctionCaller.shared.call(callItem).then { _ in
                fineListEnvironment.changeListItemInout(fine.id) { $0.payed = payedState }
                connectionStateToPayed.passed()
            }.catch { _ in
                errorMessages = .internalErrorSave
                connectionStateToPayed.failed()
            }
        }
    }
}
