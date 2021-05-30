//
//  ContentView.swift
//  Strafen
//
//  Created by Steven on 04.05.21.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {

    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared

    /// Active home tab
    @EnvironmentObject var homeTab: HomeTab

    /// Used to setup app with firebase
    @ObservedObject var appSetup = FirebaseAppSetup.shared

    /// Person list
    @State var personList: [FirebasePerson]?

    /// Fine list
    @State var fineList: [FirebaseFine]?

    /// Reason list
    @State var reasonList: [FirebaseReasonTemplate]?

    var body: some View {
        ZStack {
            if appSetup.forceSignedOut {

                // Force Sign Out View
                // ForceSignedOutView() // TODO

            } else if appSetup.emailNotVerificated {

                // Email not verificated view
                // EmailNotVerificatedView() // TODO

            } else if let person = settings.person, Auth.auth().currentUser != nil {

                VStack(spacing: 0) {

                    VStack {
                        if homeTab.active == .settings {
                            Text("SettingsView") // SettingsView() TODO
                        } else if appSetup.connectionState == .loading || appSetup.connectionState == .notStarted {
                            ZStack {
                                Color.backgroundGray
                                ProgressView(NSLocalizedString("loading-text", table: .otherTexts, comment: "Text for loading"))
                            }
                        } else if appSetup.connectionState == .failed {
                            ZStack {
                                Color.backgroundGray
                                VStack(spacing: 30) {
                                    Spacer()
                                    Text("no-connection-message", table: .otherTexts, comment: "No connection message")
                                        .foregroundColor(.textColor)
                                        .font(.system(size: 25, weight: .thin))
                                        .lineLimit(2)
                                        .padding(.horizontal, 15)
                                    Text("try-again-message", table: .otherTexts, comment: "Try again message")
                                        .foregroundColor(.customRed)
                                        .font(.system(size: 25, weight: .light))
                                        .lineLimit(2)
                                        .padding(.horizontal, 15)
                                        .onTapGesture {
                                            appSetup.setup { personList, fineList, reasonList in
                                                self.personList = personList
                                                self.fineList = fineList
                                                self.reasonList = reasonList
                                            }
                                        }
                                    Spacer()
                                }
                            }
                        } else if let personList = personList, let fineList = fineList, let reasonList = reasonList {
                            ZStack {
                                switch homeTab.active {
                                case .profileDetail: ProfileDetail()
                                case .personList: Text("PersonList") // PersonList() TODO
                                case .reasonList: Text("ReasonList") // ReasonList() TODO
                                case .addNewFine: Text("AddNewFine") // TODO
//                                    ZStack {
//                                        Color.backgroundGray
//                                        AddNewFine()
//                                            .padding(.top, 50)
//                                    }
                                case .settings: EmptyView()
                                }
                            }.environmentObject(ListEnvironment(personList, clubId: person.club.id))
                                .environmentObject(ListEnvironment(fineList, clubId: person.club.id))
                                .environmentObject(ListEnvironment(reasonList, clubId: person.club.id))
                        } else {
                            ZStack {
                                Color.backgroundGray
                                Text("no-available-view", table: .otherTexts, comment: "No available view")
                                    .foregroundColor(.textColor).font(.system(size: 25, weight: .thin)).lineLimit(2).multilineTextAlignment(.center).padding(.horizontal, 15)
                            }
                        }
                    }.edgesIgnoringSafeArea(.all)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Tab bar
                    TabBar()
                        .edgesIgnoringSafeArea([.horizontal, .top])

                }.environmentObject(person)
                    .environmentObject(DismissHandler())
                    .onAppear {
                        appSetup.setup { personList, fineList, reasonList in
                            self.personList = personList
                            self.fineList = fineList
                            self.reasonList = reasonList
                        }
                    }

            } else {

                // Login view
                LoginView()

            }

        }.onAppear {
            UIApplication.shared.windows.first!.overrideUserInterfaceStyle = .dark
        }
    }
}
