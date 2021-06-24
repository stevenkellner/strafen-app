//
//  SearchBar.swift
//  Strafen
//
//  Created by Steven on 31.05.21.
//

import SwiftUI

/// Search Bar with Finsh Button
struct SearchBar: View {

    /// Text searched in search bar
    @Binding var searchText: String

    /// True if keyboard is shown
    @State var isSearchKeyboardShown = false

    var body: some View {
        HStack(spacing: 0) {

            // Search Bar
            SearchBarView(text: $searchText, isSearchKeyboardShown: $isSearchKeyboardShown)

            // Finish Button
            if isSearchKeyboardShown {
                Text("cancel-button-text", comment: "Text of cancel button.")
                    .foregroundColor(.textColor)
                    .font(.system(size: 20, weight: .thin))
                    .lineLimit(1)
                    .padding(.trailing, 5)
                    .unredacted()
                    .onTapGesture {
                        searchText = ""
                        UIApplication.shared.dismissKeyboard()
                    }
            }
        }
    }
}

/// Search Bar View
struct SearchBarView: UIViewRepresentable {

    /// Text searched in search bar
    @Binding var text: String

    /// True if keyboard is shown
    @Binding var isSearchKeyboardShown: Bool

    /// Coordinator
    class Coordinator: NSObject, UISearchBarDelegate {

        /// Text searched in search bar
        @Binding var text: String

        /// True if keyboard is shown
        @Binding var isSearchKeyboardShown: Bool

        init(text: Binding<String>, isSearchKeyboardShown: Binding<Bool>) {
            _text = text
            _isSearchKeyboardShown = isSearchKeyboardShown
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            withAnimation { text = searchText }
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }

        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            withAnimation { isSearchKeyboardShown = true }
        }

        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            withAnimation { isSearchKeyboardShown = false }
        }
    }

    /// make coordiator
    func makeCoordinator() -> SearchBarView.Coordinator {
        return Coordinator(text: $text, isSearchKeyboardShown: $isSearchKeyboardShown)
    }

    /// make view
    func makeUIView(context: UIViewRepresentableContext<SearchBarView>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.autocapitalizationType = .none
        searchBar.backgroundImage = UIImage()
        searchBar.placeholder = String(localized: "search-bar-text", comment: "Placeholder text of a search text field.")
        return searchBar
    }

    /// update view
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBarView>) {
        withAnimation { uiView.text = text }
    }
}