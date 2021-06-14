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

    /// Contains person, fine and reason template lists
    @State var allLists: FirebaseAppSetup.AllLists?

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
                            Text(verbatim: "SettingsView") // SettingsView() TODO
                        } else if appSetup.connectionState == .loading || appSetup.connectionState == .notStarted {
                            ZStack {
                                Color.backgroundGray
                                ProgressView(String(localized: "loading-text", comment: "Text of a loading view."))
                            }
                        } else if appSetup.connectionState == .failed {
                            ZStack {
                                Color.backgroundGray
                                VStack(spacing: 30) {
                                    Spacer()
                                    Text("no-connection-message", comment: "A text displayed, when there is no internet connection.")
                                        .foregroundColor(.textColor)
                                        .font(.system(size: 25, weight: .thin))
                                        .lineLimit(2)
                                        .padding(.horizontal, 15)
                                    Text("try-again-message", comment: "Text of button to try again loading this page.")
                                        .foregroundColor(.customRed)
                                        .font(.system(size: 25, weight: .light))
                                        .lineLimit(2)
                                        .padding(.horizontal, 15)
                                        .onTapGesture {
                                            async {
                                                guard let allLists = try? await appSetup.setup() else { return }
                                                self.allLists = allLists
                                            }
                                        }
                                    Spacer()
                                }
                            }
                        } else if let allLists = allLists {
                            ZStack {
                                switch homeTab.active {
                                case .profileDetail: ProfileDetail()
                                case .personList: PersonList()
                                case .reasonList: Text(verbatim: "ReasonList") // ReasonList() TODO
                                case .addNewFine: Text(verbatim: "AddNewFine") // TODO
//                                    ZStack {
//                                        Color.backgroundGray
//                                        AddNewFine()
//                                            .padding(.top, 50)
//                                    }
                                case .settings: EmptyView()
                                }
                            }.environmentObject(ListEnvironment(allLists.personList, clubId: person.club.id))
                                .environmentObject(ListEnvironment(allLists.fineList, clubId: person.club.id))
                                .environmentObject(ListEnvironment(allLists.reasonList, clubId: person.club.id))
                        } else {
                            ZStack {
                                Color.backgroundGray
                            }
                        }
                    }.edgesIgnoringSafeArea(.all)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Tab bar
                    TabBar()
                        .edgesIgnoringSafeArea([.horizontal, .top])

                }.environmentObject(person)
                    .environmentObject(DismissHandler())
                    .ignoresSafeArea(.keyboard)
                    .task {
                        guard let allLists = try? await appSetup.setup() else { return }
                        self.allLists = allLists
                    }

            } else {

                // Login view
                LoginView()

            }

        }.onAppear {
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
        }
    }
}
