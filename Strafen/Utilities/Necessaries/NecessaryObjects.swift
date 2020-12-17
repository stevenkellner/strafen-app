//
//  NecessaryObjects.swift
//  Strafen
//
//  Created by Steven on 10/15/20.
//

import SwiftUI
import OSLog

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

/// Used to clamp a comparable value between lower and upper bound
@propertyWrapper struct Clamping<Value> where Value: Comparable {
    
    /// Value
    private var value: Value
    
    /// Range to be clamped
    private let range: ClosedRange<Value>

    init(wrappedValue value: Value, _ range: ClosedRange<Value>) {
        self.value = range.clamp(value)
        self.range = range
    }

    var wrappedValue: Value {
        get { value }
        set { value = range.clamp(newValue) }
    }
}

// Extension of ClosedRange to clamp a value between lower and upper bound
extension ClosedRange {
    
    /// Clamps value between lower and upper bound
    func clamp(_ value: Bound) -> Bound {
        Swift.min(Swift.max(value, lowerBound), upperBound)
    }
}

/// Used to make a comparable number always non negative
@propertyWrapper struct NonNegative<Value> where Value: Comparable & AdditiveArithmetic {
    
    /// Value
    private var value: Value
    
    init(wrappedValue value: Value) {
        self.value = Swift.max(.zero, value)
    }
    
    var wrappedValue: Value {
        get { value }
        set { value = Swift.max(.zero, newValue)}
    }
}

/// Used to log messages
struct Logging {
    
    /// Shared instance for singelton
    static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    let logLevelHigherEqual: OSLogType = .default
    
    /// Logges a message with given logging level
    func log(with level: OSLogType, _ messages: String..., file: String = #fileID, function: String = #function, line: Int = #line) {
        guard level.rawValue >= logLevelHigherEqual.rawValue else { return }
        let logger = Logger(subsystem: "Strafen-App", category: "File: \(file), in Function: \(function), at Line: \(line)")
        let message = messages.joined(separator: "\n\t")
        logger.log(level: level, "\(level.levelName.uppercased(), privacy: .public) | \(message, privacy: .public)")
    }
}

extension OSLogType {
    var levelName: String {
        switch self {
        case .default:
            return "(Default)"
        case .info:
            return "(Info)   "
        case .debug:
            return "(Debug)  "
        case .error:
            return "(Error)  "
        case .fault:
            return "(Fault)  "
        default:
            return "(Unknown)"
        }
    }
}

/// State of data task
enum TaskState {
    
    /// Data task passed
    case passed
    
    /// Data task failed
    case failed
}

/// State of internet connection
enum ConnectionState {
    
    /// Still loading
    case loading
    
    /// No connection
    case failed
    
    /// All loaded
    case passed
}

/// Type of the change
enum ChangeType: String {
    
    /// Adds item
    case add
    
    /// Updates item
    case update
    
    /// Deletes item
    case delete
}

// Extension of Change Type to confirm to ParameterableObject
extension ChangeType: ParameterableObject {
    
    // Object call with Firebase function as Parameter
    var parameterableObject: _ParameterableObject {
        rawValue
    }
}
