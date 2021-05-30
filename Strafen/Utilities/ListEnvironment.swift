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
    init(_ list: [ListType]) {
        self.list = list
    }

    /// Init with list of a firebase list type and observes the list
    /// - Parameters:
    ///   - list: list of a firebase list type
    ///   - clubId: id of club
    init(_ list: [ListType], clubId: Club.ID) {
        self.list = list
        observeList(clubId: clubId)
    }

    /// Observes list on database
    /// - Parameter clubId: id of club
    func observeList(clubId: Club.ID) {
        FirebaseObserver.shared.observeList(ListType.self, clubId: clubId) { changeList in
            changeList(&self.list)
        }
    }
}
extension ListEnvironment {

    /// Changes item with given id to new value
    /// - Parameters:
    ///   - id: id of item to change
    ///   - newValue: new value of the item
    func changeListItem(_ id: ListType.ID, to newValue: ListType) { // swiftlint:disable:this identifier_name
        list.mapped { $0.id == id ? newValue : $0 }
    }

    /// Changes item with given id with change handler
    /// - Parameters:
    ///   - id: id of item to change
    ///   - changeHandler: handles item change
    func changeListItem(_ id: ListType.ID, change changeHandler: (ListType) -> ListType) { // swiftlint:disable:this identifier_name
        list.mapped { $0.id == id ? changeHandler($0) : $0 }
    }

    /// Changes item with given id with change handler
    /// - Parameters:
    ///   - id: id of item to change
    ///   - changeHandler: handles item change
    func changeListItemInout(_ id: ListType.ID, change changeHandler: (inout ListType) -> Void) { // swiftlint:disable:this identifier_name
        changeListItem(id) {
            var item = $0
            changeHandler(&item)
            return item
        }
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
