//
//  SettingsStatistics.swift
//  Strafen
//
//  Created by Steven on 28.06.21.
//

import SwiftUI

/// Used to display all statistics
struct SettingsStatistics: View {

    /// Currently logged in person
    @EnvironmentObject var person: Settings.Person

    /// Number of statistics loading at once
    let loadingNumber: UInt = 25

    /// Connection state of load statistics
    @State var connectionState: ConnectionState = .notStarted

    /// Connection state of load more statistics
    @State var loadMoreConnectionState: ConnectionState = .notStarted

    /// List of statistics
    @State var statisticList: [FirebaseStatistic]?

    /// Inidicates whether more statistics can be loaded
    @State var canLoadMore: Bool = true

    var body: some View {
        ZStack {

            // Background Color
            Color.backgroundGray

            // Content
            VStack(spacing: 0) {

                // Back button
                BackButton()
                    .padding(.top, 50)

                // Header
                Header(String(localized: "settings-statistics-header", comment: "Header of settings statistics view."))
                    .padding(.top, 10)

                if connectionState == .notStarted || connectionState == .loading {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 15) {
                            ForEach(0..<15, id: \.self) { _ in
                                SingleOutlinedContent {
                                    Text(verbatim: "lorim ipsum dolor").foregroundColor(.textColor).font(.system(size: 20, weight: .thin)).lineLimit(1).redacted(reason: .placeholder)
                                }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                            }
                        }.padding(.vertical, 10)
                    }.padding(.top, 10)
                } else if connectionState == .passed, let statisticList = statisticList {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 15) {
                            ForEach(statisticList) { statistic in
                                StatisticRow(statisticList: $statisticList, statistic: statistic)
                                    .onAppear {
                                        guard statistic.id == statisticList.last?.id, canLoadMore else { return }
                                        async { await fetchMoreList() }
                                    }
                            }

                            if loadMoreConnectionState == .loading {
                                ProgressView()
                            } else if loadMoreConnectionState == .failed {
                                Text("settings-statistics-could-not-load-more", comment: "Text of could not load more statistics message in settings statistings view.")
                                    .foregroundColor(.customRed)
                                    .font(.system(size: 20, weight: .thin))
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 15)
                            }

                        }.padding(.vertical, 10)
                    }.padding(.top, 10)
                } else {
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
                                async { await fetchFirstList() }
                            }
                        Spacer()
                    }
                }

                Spacer(minLength: 0)
            }

        }.maxFrame.dismissHandler
            .task(fetchFirstList)
    }

    /// Fetches first statistics
    func fetchFirstList() async {
        guard connectionState.restart() == .passed else { return }
        do {
            statisticList = try await FirebaseFetcher.shared.fetchStatistics(clubId: person.club.id, before: nil, number: loadingNumber)
            canLoadMore = statisticList!.count == loadingNumber
            connectionState.passed()
        } catch {
            connectionState.failed()
        }
    }

    func fetchMoreList() async {
        guard connectionState == .passed, loadMoreConnectionState.restart() == .passed else { return }
        guard let lastStatistic = statisticList?.last else {
            return loadMoreConnectionState.failed()
        }
        do {
            let statisticList = try await FirebaseFetcher.shared.fetchStatistics(clubId: person.club.id, before: lastStatistic, number: loadingNumber)
            self.statisticList?.appendIfNew(contentOf: statisticList)
            canLoadMore = statisticList.count == loadingNumber
            loadMoreConnectionState.passed()
        } catch {
            loadMoreConnectionState.failed()
        }
    }

    /// Row of statistics list
    struct StatisticRow: View {

        /// List of statistics
        @Binding var statisticList: [FirebaseStatistic]?

        /// Statistic of this row
        let statistic: FirebaseStatistic

        var body: some View {
            Text("asdf").onAppear {
                print(statistic)
            }
        }
    }
}
