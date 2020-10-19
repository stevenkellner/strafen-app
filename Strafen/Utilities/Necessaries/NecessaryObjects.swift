//
//  NecessaryObjects.swift
//  Strafen
//
//  Created by Steven on 10/15/20.
//

import SwiftUI

/// Typealias for a handler to dimiss from a subview to the previous view.
///
/// Optional closure with no parameters and no return value.
typealias DismissHandler = (() -> Void)?

/// Empty Navigation Link
struct EmptyNavigationLink<Destination>: View where Destination: View {
    
    /// Destination of navigation link
    var destination: Destination
    
    /// Indicates wheater navigation link is active
    @Binding var isActive: Bool
    
    init(isActive: Binding<Bool>, @ViewBuilder destination: () -> Destination) {
        self.destination = destination()
        self._isActive = isActive
    }
    
    init(isActive: Binding<Bool>, destination: Destination) {
        self.destination = destination
        self._isActive = isActive
    }
    
    var body: some View {
        NavigationLink(destination: destination, isActive: $isActive) { EmptyView() }.frame(size: .zero)
    }
}

/// Empty Sheet Link
struct EmptySheetLink<Content, Item>: View where Content: View, Item: Identifiable {
    
    /// Sheet types
    private enum SheetType {
        
        /// with bool and content
        case withBool(isPresented: Binding<Bool>, content: () -> Content)
        
        /// with item and content
        case withItem(item: Binding<Item?>, content: (Item) -> Content)
        
    }
    
    /// Sheet type
    private let sheetType: SheetType
    
    /// Init with item and content
    init(item: Binding<Item?>, @ViewBuilder content: @escaping (Item) -> Content) {
        sheetType = .withItem(item: item, content: content)
    }
    
    var body: some View {
        switch sheetType {
        case .withBool(isPresented: let isPresented, content: let content):
            EmptyView()
                .frame(size: .zero)
                .sheet(isPresented: isPresented, content: content)
        case .withItem(item: let item, content: let content):
            EmptyView()
                .frame(size: .zero)
                .sheet(item: item, content: content)
        }
    }
}

// Extention of EmptySheetLink to init with bool and content
extension EmptySheetLink where Item == Bool {
    
    /// Init with bool and content
    init(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        sheetType = .withBool(isPresented: isPresented, content: content)
    }
}
