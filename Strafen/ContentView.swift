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

    /// Random lists
    let randomLists = FirebaseAppSetup.shared.randomLists

    /// Contains person, fine and reason template lists
    @State var allLists: FirebaseAppSetup.AllLists?

    var body: some View {
        ZStack {
            if appSetup.forceSignedOut {

                // Force Sign Out View
                ForceSignedOutView()

            } else if let person = settings.person, Auth.auth().currentUser != nil {

                VStack(spacing: 0) {

                    VStack {
                        if appSetup.connectionState == .loading || appSetup.connectionState == .notStarted {
                            ZStack {
                                switch homeTab.active {
                                case .profileDetail: ProfileDetail(placeholder: true)
                                case .personList: PersonList(placeholder: true)
                                case .reasonList: ReasonList(placeholder: true)
                                case .addNewFine:
                                    Color.backgroundGray
                                    ProgressView(String(localized: "loading-text", comment: "Text of a loading view."))
                                case .settings: SettingsView(hasLists: false)
                                }
                            }.environmentObject(ListEnvironment(randomLists.personList))
                                .environmentObject(ListEnvironment(randomLists.fineList))
                                .environmentObject(ListEnvironment(randomLists.reasonList))
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
                                case .reasonList: ReasonList()
                                case .addNewFine: AddNewFine(isSheet: false)
                                case .settings: SettingsView(hasLists: true)
                                }
                            }.environmentObject(ListEnvironment(allLists.personList, clubId: person.club.id))
                                .environmentObject(ListEnvironment(allLists.fineList, clubId: person.club.id))
                                .environmentObject(ListEnvironment(allLists.reasonList, clubId: person.club.id))
                        } else { Color.backgroundGray }
                    }.edgesIgnoringSafeArea(.all)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Tab bar
                    TabBar()
                        .edgesIgnoringSafeArea([.horizontal, .top])

                }.environmentObject(person)
                    .environmentObject(DismissHandler())
                    .ignoresSafeArea(.keyboard)
                    .task {
                        do {
                            let list: [FirebaseStatistic] = try await FirebaseFetcher.shared.fetchList(clubId: Settings.shared.person!.club.id)
                            print(list.map { $0.timestamp })
                        } catch {
                            print(error)
                        }

                        guard let allLists = try? await appSetup.setup() else { return }
                        self.allLists = allLists
                    }

            } else {

                // Login view
                LoginView()

            }

            // Overlay views
            OverlayViews()

        }.onAppear {
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
        }
    }
}
