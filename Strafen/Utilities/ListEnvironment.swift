//
//  ListEnvironment.swift
//  Strafen
//
//  Created by Steven on 06.05.21.
//

import SwiftUI

/// Environment object for firebase list type
@dynamicMemberLookup class ListEnvironment<ListType>: ObservableObject where ListType: FirebaseListType {

    /// List of a firebase list type
    @Published var list: [ListType]

    /// Init with list of a firebase list type
    /// - Parameter list: list of a firebase list type
    init(list: [ListType]) {
        self.list = list
    }
}

extension ListEnvironment {
    subscript<T>(dynamicMember keyPath: WritableKeyPath<[ListType], T>) -> T {
        get { list[keyPath: keyPath] }
        set { list[keyPath: keyPath] = newValue }
    }
}

extension ListEnvironment: RandomAccessCollection {
    public typealias Element = ListType
    public typealias Index = Array<ListType>.Index

    public func index(after i: Index) -> Index { // swiftlint:disable:this identifier_name
        list.index(after: i)
    }

    public subscript(position: Index) -> Element {
        list[position]
    }

    public var startIndex: Index {
        list.startIndex
    }

    public var endIndex: Index {
        list.endIndex
    }

    public __consuming func makeIterator() -> Array<ListType>.Iterator {
        list.makeIterator()
    }
}

extension ListEnvironment: Equatable where ListType: Equatable {
    static func == (lhs: ListEnvironment<ListType>, rhs: ListEnvironment<ListType>) -> Bool {
        lhs.list == rhs.list
    }
}
