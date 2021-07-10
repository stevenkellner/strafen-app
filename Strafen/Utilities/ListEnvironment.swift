//
//  ListEnvironment.swift
//  Strafen
//
//  Created by Steven on 06.05.21.
//

import SwiftUI

/// Environment object for firebase list type
class ListEnvironment<ListType>: ObservableObject where ListType: FirebaseListType {

    /// List of a firebase list type
    @Published private(set) var list: [ListType]

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

    /// Updates all elements with same id as specified id in the list.
    ///
    /// If there isn't an element with same id as specified id in the list,
    /// the change handler generates an element from `nil` and
    /// this generated element will be appended to the list.
    ///
    /// If the change handler generates `nil`, all elements with same id
    /// as specified id will be removed from the list.
    ///
    /// Otherwise the element with same id as specified id will be updated
    /// with the generated element from the change handler.
    ///
    /// If there isn't an element with same id as specified id in the list and
    /// the change handler generates `nil`, nothing happens to the list.
    ///
    /// - Parameters:
    ///   - id: Id of elements to update.
    ///   - changeHandler: Generates the updated element from
    ///   the element with same id as specified id.
    func update(with id: ListType.ID, change changeHandler: (inout ListType?) -> Void) {
        list.update(with: id, change: changeHandler)
    }
}
