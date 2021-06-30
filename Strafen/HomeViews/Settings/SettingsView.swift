//
//  SettingsView.swift
//  Strafen
//
//  Created by Steven on 21.06.21.
//

import SwiftUI
import SupportDocs
import FirebaseAuth

/// Setting View
struct SettingsView: View {

    /// Currently logged in person
    @EnvironmentObject var person: Settings.Person

    /// Inidcates whether this view has list environments
    let hasLists: Bool

    var body: some View {
        NavigationView {
            ZStack {

                // Background color
                Color.backgroundGray

                VStack(spacing: 10) {

                    // Header
                    Header(String(localized: "settings-header-text", comment: "Header of settings view."))
                        .padding(.top, 50)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {

                            // Club id
                            ClubIdRow()

                            // Support docs
                            if let dataSourceUrl = URL.supportCenterDataSource {
                                SupportDocsRow(dataSourceUrl: dataSourceUrl)
                            }

                            if person.isCashier {

                                // Late payment interest changer
                                LatePaymentInterestChangerRow()

                                // Statistics row
                                StatisticsRow()

                                if hasLists {

                                    // Fines Formatter
                                    FinesFormatterRow()

                                    // Force Sign out button
                                    ForceSignOutButton()
                                }
                            }

                            // Log out button
                            LogOutButton()

                        }.padding(.vertical, 10)
                    }.padding(.top, 10)
                    Spacer(minLength: 0)
                }

            }.maxFrame
        }
    }

    /// Club id row
    struct ClubIdRow: View {

        /// Currently logged in person
        @EnvironmentObject var person: Settings.Person

        var body: some View {
            TitledContent(String(localized: "settings-view-club-identifier-title", comment: "Title of club identifier in settings view.")) {
                SplittedOutlinedContent {
                    Text(person.club.identifier)
                        .foregroundColor(.textColor)
                        .font(.system(size: 20, weight: .thin))
                        .lineLimit(1)
                        .padding(.horizontal, 10)
                } rightContent: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 25, weight: .light))
                        .foregroundColor(.textColor)
                }.leftWidthPercentage(0.775)
                    .onRightTapGesture {
                        UIPasteboard.general.string = person.club.identifier
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
            }
        }
    }

    /// Support docs
    struct SupportDocsRow: View {

        /// Url of data source
        let dataSourceUrl: URL

        /// Indicates wheater support docs sheet is presented
        @State var isSheetPresented = false

        var body: some View {
            TitledContent(String(localized: "settings-view-support-center-title", comment: "Title of support center in settings view.")) {
                SingleOutlinedContent {
                    Text("settings-view-support-center-title", comment: "Title of support center in settings view.")
                        .foregroundColor(.textColor)
                        .font(.system(size: 20, weight: .thin))
                        .lineLimit(1)
                        .padding(.horizontal, 15)
                }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                    .toggleOnTapGesture($isSheetPresented)
                    .sheet(isPresented: $isSheetPresented) {
                        SupportDocsView(dataSourceURL: dataSourceUrl, options: .custom, isPresented: $isSheetPresented)
                    }
            }
        }
    }

    /// Late payment interest changer
    struct LatePaymentInterestChangerRow: View {

        /// Observed Object that contains all settings of the app of this device
        @ObservedObject var settings = Settings.shared

        var body: some View {
            TitledContent(String(localized: "settings-view-late-payment-interest-title", comment: "Title of late payment interest in settings view.")) {
                NavigationLink {
                    SettingsLatePaymentInterestChanger()
                } label: {
                    SplittedOutlinedContent {
                        Text(settings.latePaymentInterest?.description ?? String(localized: "settings-view-late-payment-interest-title", comment: "Title of late payment interest in settings view."))
                            .foregroundColor(.textColor)
                            .font(.system(size: 20, weight: .thin))
                            .lineLimit(1)
                            .padding(.leading, 10)
                    } rightContent: {}
                        .leftWidthPercentage(0.775)
                        .rightFillColor(settings.latePaymentInterest == nil ? .customRed : .customGreen)
                        .frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                }
            }
        }
    }

    /// Statisticts row
    struct StatisticsRow: View {
        var body: some View {
            TitledContent(String(localized: "settings-view-statistics-title", comment: "Title of statistics in settings view.")) {
                NavigationLink {
                    SettingsStatistics()
                } label: {
                    SplittedOutlinedContent {
                        Text("settings-view-statistics-title", comment: "Title of statistics in settings view.")
                            .foregroundColor(.textColor)
                            .font(.system(size: 20, weight: .thin))
                            .lineLimit(1)
                            .padding(.leading, 10)
                    } rightContent: {
                        Image(systemName: "chart.bar")
                            .font(.system(size: 25, weight: .light))
                            .foregroundColor(.textColor)
                            .padding(.leading, 15)
                            .padding(.trailing, 10)
                    }.leftWidthPercentage(0.775)
                        .frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                }
            }
        }
    }

    /// Fines Formatter
    struct FinesFormatterRow: View {
        var body: some View {
            TitledContent(String(localized: "settings-view-fines-formatter-title", comment: "Title of fines formatter in settings view.")) {
                NavigationLink {
                    FinesFormatter()
                } label: {
                    SplittedOutlinedContent {
                        Text("settings-view-fines-formatter-title", comment: "Title of fines formatter in settings view.")
                            .foregroundColor(.textColor)
                            .font(.system(size: 20, weight: .thin))
                            .lineLimit(1)
                            .padding(.leading, 10)
                    } rightContent: {
                        Image(systemName: "arrowshape.turn.up.left.2")
                            .rotation3DEffect(.radians(.pi), axis: (x: 0, y: 1, z: 0))
                            .font(.system(size: 25, weight: .light))
                            .foregroundColor(.textColor)
                            .padding(.leading, 15)
                            .padding(.trailing, 10)
                    }.leftWidthPercentage(0.775)
                        .frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                }
            }
        }
    }

    /// Force sign out button
    struct ForceSignOutButton: View {
        var body: some View {
            TitledContent(String(localized: "settings-view-force-sign-out-title", comment: "Title of force sign out in settings view.")) {
                NavigationLink {
                    SettingsForceSignOut()
                } label: {
                    ZStack {
                        Outline()
                        Text(String(localized: "settings-view-force-sign-out-title", comment: "Title of force sign out in settings view."))
                            .foregroundColor(.textColor)
                            .font(.system(size: 20, weight: .thin))
                            .lineLimit(1)
                            .padding(.horizontal, 10)
                    }
                }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
            }
        }
    }

    /// Log out button
    struct LogOutButton: View {

        /// Indicates if log out alert is shown
        @State var isLogOutAlertShown = false

        var body: some View {
            TitledContent(String(localized: "settings-view-log-out-button-text", comment: "Text of log out button in settings view.")) {
                SingleOutlinedContent {
                    Text("settings-view-log-out-button-text", comment: "Text of log out button in settings view.")
                        .foregroundColor(.textColor)
                        .font(.system(size: 20, weight: .thin))
                        .toggleOnTapGesture($isLogOutAlertShown)
                        .alert(isPresented: $isLogOutAlertShown) {
                            Alert(title: Text("settings-view-log-out-button-text", comment: "Text of log out button in settings view."),
                                  message: Text("settings-view-log-out-alert-text", comment: "Text of log out alert text in settings view."),
                                  primaryButton: .default(Text("cancel-button-text", comment: "Text of cancel button.")),
                                  secondaryButton: .destructive(Text("settings-view-log-out-button-text", comment: "Text of log out button in settings view."), action: {
                                FirebaseImageStorage.shared.clear()
                                try? Auth.auth().signOut()
                                Settings.shared.person = nil
                            }))
                        }
                }.fillColor(.customRed)
                    .frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
            }
        }
    }
}
