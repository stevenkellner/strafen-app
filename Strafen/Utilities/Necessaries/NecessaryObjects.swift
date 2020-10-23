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

struct CustomNavigationLink<Label, Destination, V>: View where Label: View, Destination: View, V: Hashable {
    
    private struct SelectionTag {
        let tag: V
        let selection: Binding<V?>
    }
    
    private let swipeBack: Bool
    private let destination: Destination
    private let label: Label
    
    private let isActive: Binding<Bool>?
    private let selectionTag: SelectionTag?

    /// Creates an instance that presents `destination` when `selection` is set to `tag`.
    public init(swipeBack: Bool = true, destination: Destination, tag: V, selection: Binding<V?>, @ViewBuilder label: () -> Label) {
        self.swipeBack = swipeBack
        self.destination = destination
        self.label = label()
        self.isActive = nil
        self.selectionTag = SelectionTag(tag: tag, selection: selection)
    }

    
    var body: some View {
        if let isActive = isActive {
            NavigationLink(destination:
                            destination
                                .navigationTitle("Title")
                                .navigationBarHidden(true)
                                .onAppear {
                                    UINavigationController.swipeBack = swipeBack
                                },
                           isActive: isActive) {
                                label
                            }
        } else if let selectionTag = selectionTag {
            NavigationLink(destination:
                            destination
                                .navigationTitle("Title")
                                .navigationBarHidden(true)
                                .onAppear {
                                    UINavigationController.swipeBack = swipeBack
                                },
                           tag: selectionTag.tag, selection: selectionTag.selection) {
                                label
                            }
        } else {
            NavigationLink(destination:
                            destination
                                .navigationTitle("Title")
                                .navigationBarHidden(true)
                                .onAppear {
                                    UINavigationController.swipeBack = swipeBack
                                }) {
                                label
                            }
        }
    }
}

extension CustomNavigationLink where V == Bool {
    init(swipeBack: Bool = true, destination: Destination, @ViewBuilder label: () -> Label) {
        self.swipeBack = swipeBack
        self.destination = destination
        self.label = label()
        self.isActive = nil
        self.selectionTag = nil
    }
    
    /// Creates an instance that presents `destination` when active.
    init(swipeBack: Bool = true, destination: Destination, isActive: Binding<Bool>, @ViewBuilder label: () -> Label) {
        self.swipeBack = swipeBack
        self.destination = destination
        self.label = label()
        self.isActive = isActive
        self.selectionTag = nil
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomNavigationLink where Label == Text {
    
    /// Creates an instance that presents `destination` when `selection` is set to `tag`, with a `Text` label generated from a title string.
    init(swipeBack: Bool = true, _ titleKey: LocalizedStringKey, destination: Destination, tag: V, selection: Binding<V?>) {
        self.init(swipeBack: swipeBack, destination: destination, tag: tag, selection: selection) { Text(titleKey) }
    }

    /// Creates an instance that presents `destination` when `selection` is set to `tag`, with a `Text` label generated from a title string.
    init<S>(swipeBack: Bool = true, _ title: S, destination: Destination, tag: V, selection: Binding<V?>) where S: StringProtocol {
        self.init(swipeBack: swipeBack, destination: destination, tag: tag, selection: selection) { Text(title) }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomNavigationLink where Label == Text, V == Bool {

    /// Creates an instance that presents `destination`, with a `Text` label generated from a title string.
    init(swipeBack: Bool = true, _ titleKey: LocalizedStringKey, destination: Destination) {
        self.init(swipeBack: swipeBack, destination: destination) { Text(titleKey) }
    }

    /// Creates an instance that presents `destination`, with a `Text` label generated from a title string.
    init<S>(swipeBack: Bool = true, _ title: S, destination: Destination) where S : StringProtocol {
        self.init(swipeBack: swipeBack, destination: destination) { Text(title) }
    }

    /// Creates an instance that presents `destination` when active, with a `Text` label generated from a title string.
    init(swipeBack: Bool = true, _ titleKey: LocalizedStringKey, destination: Destination, isActive: Binding<Bool>) {
        self.init(swipeBack: swipeBack, destination: destination, isActive: isActive) { Text(titleKey) }
    }

    /// Creates an instance that presents `destination` when active, with a `Text` label generated from a title string.
    init<S>(swipeBack: Bool = true, _ title: S, destination: Destination, isActive: Binding<Bool>) where S: StringProtocol {
        self.init(swipeBack: swipeBack, destination: destination, isActive: isActive) { Text(title) }
    }
}


/// Empty Navigation Link
struct EmptyNavigationLink<Destination>: View where Destination: View {
    
    /// Destination of navigation link
    var destination: Destination
    
    /// Indicates wheater navigation link is active
    @Binding var isActive: Bool
    
    /// Possibility to swipe back
    let swipeBack: Bool
    
    init(swipeBack: Bool = true, isActive: Binding<Bool>, @ViewBuilder destination: () -> Destination) {
        self.destination = destination()
        self._isActive = isActive
        self.swipeBack = swipeBack
    }
    
    init(swipeBack: Bool = true, isActive: Binding<Bool>, destination: Destination) {
        self.destination = destination
        self._isActive = isActive
        self.swipeBack = swipeBack
    }
    
    var body: some View {
        CustomNavigationLink(swipeBack: swipeBack, destination: destination, isActive: $isActive) { EmptyView() }.frame(size: .zero)
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
    
    /// On dismiss handler
    private let onDismissHandler: (() -> Void)?
    
    /// Init with item and content
    init(item: Binding<Item?>, @ViewBuilder content: @escaping (Item) -> Content, onDismiss onDismissHandler: (() -> Void)? = nil) {
        self.sheetType = .withItem(item: item, content: content)
        self.onDismissHandler = onDismissHandler
    }
    
    var body: some View {
        switch sheetType {
        case .withBool(isPresented: let isPresented, content: let content):
            EmptyView()
                .frame(size: .zero)
                .sheet(isPresented: isPresented, onDismiss: onDismissHandler, content: content)
        case .withItem(item: let item, content: let content):
            EmptyView()
                .frame(size: .zero)
                .sheet(item: item, onDismiss: onDismissHandler, content: content)
        }
    }
}

// Extention of EmptySheetLink to init with bool and content
extension EmptySheetLink where Item == Bool {
    
    /// Init with bool and content
    init(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content, onDismiss onDismissHandler: (() -> Void)? = nil) {
        self.sheetType = .withBool(isPresented: isPresented, content: content)
        self.onDismissHandler = onDismissHandler
    }
}
