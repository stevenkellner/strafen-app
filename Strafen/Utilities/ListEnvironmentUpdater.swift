//
//  ListEnvironmentUpdater.swift
//  Strafen
//
//  Created by Steven on 10.07.21.
//

import SwiftUI

/// Updates person, fine and reason list when an item is updated.
class ListEnvironmentUpdater: ObservableObject {

    /// Updates list when an item is updated.
    struct Updater<ListType> where ListType: FirebaseListType {

        typealias Observer = (_ id: ListType.ID, _ changeHandler: (inout ListType?) -> Void) -> Void

        /// Observers executed when an item is updated.
        private var observers = [Observer]()

        /// Appends a new list observer  executed when an item is updated.
        /// - Parameter observer: Observer to append.
        mutating func appendObserver(_ observer: @escaping Observer) {
            self.observers.append(observer)
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
            for observer in self.observers {
                observer(id, changeHandler)
            }
        }
    }

    /// Updates list when an item is updated.
    private var personUpdater = Updater<FirebasePerson>()

    /// Updates list when an item is updated.
    private var fineUpdater = Updater<FirebaseFine>()

    /// Updates list when an item is updated.
    private var reasonUpdater = Updater<FirebaseReasonTemplate>()

    /// Appends a new list observer executed when an item is updated.
    /// - Parameter observer: Observer to append.
    func appendPersonObserver(_ observer: @escaping Updater<FirebasePerson>.Observer) {
        personUpdater.appendObserver(observer)
    }

    /// Appends a new list observer executed when an item is updated.
    /// - Parameter observer: Observer to append.
    func appendFineObserver(_ observer: @escaping Updater<FirebaseFine>.Observer) {
        fineUpdater.appendObserver(observer)
    }

    /// Appends a new list observer executed when an item is updated.
    /// - Parameter observer: Observer to append.
    func appendReasonObserver(_ observer: @escaping Updater<FirebaseReasonTemplate>.Observer) {
        reasonUpdater.appendObserver(observer)
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
    func updatePerson(with id: FirebasePerson.ID, change changeHandler: (inout FirebasePerson?) -> Void) {
        personUpdater.update(with: id, change: changeHandler)
    }

    /// Updates all elements with same id as specified item in the list.
    ///
    /// If there isn't an element with same id as specified item in the list,
    /// the updated item will be appended to the list.
    ///
    /// Otherwise the element with same id as specified item will be
    /// updated with specified item.
    ///
    /// - Parameter updatedPerson: Updated element.
    func updatePerson(_ updatedPerson: FirebasePerson) {
        updatePerson(with: updatedPerson.id) { $0 = updatedPerson }
    }

    /// Removes all elements with same id as specified id from the list.
    /// - Parameter id: Id of elements to remove.
    func removePerson(with id: FirebasePerson.ID) {
        updatePerson(with: id) { $0 = nil }
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
    func updateFine(with id: FirebaseFine.ID, change changeHandler: (inout FirebaseFine?) -> Void) {
        fineUpdater.update(with: id, change: changeHandler)
    }

    /// Updates all elements with same id as specified item in the list.
    ///
    /// If there isn't an element with same id as specified item in the list,
    /// the updated item will be appended to the list.
    ///
    /// Otherwise the element with same id as specified item will be
    /// updated with specified item.
    ///
    /// - Parameter updatedPerson: Updated element.
    func updateFine(_ updatedFine: FirebaseFine) {
        updateFine(with: updatedFine.id) { $0 = updatedFine }
    }

    /// Removes all elements with same id as specified id from the list.
    /// - Parameter id: Id of elements to remove.
    func removeFine(with id: FirebaseFine.ID) {
        updateFine(with: id) { $0 = nil }
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
    func updateReason(with id: FirebaseReasonTemplate.ID, change changeHandler: (inout FirebaseReasonTemplate?) -> Void) {
        reasonUpdater.update(with: id, change: changeHandler)
    }

    /// Updates all elements with same id as specified item in the list.
    ///
    /// If there isn't an element with same id as specified item in the list,
    /// the updated item will be appended to the list.
    ///
    /// Otherwise the element with same id as specified item will be
    /// updated with specified item.
    ///
    /// - Parameter updatedPerson: Updated element.
    func updateReason(_ updatedReason: FirebaseReasonTemplate) {
        updateReason(with: updatedReason.id) { $0 = updatedReason }
    }

    /// Removes all elements with same id as specified id from the list.
    /// - Parameter id: Id of elements to remove.
    func removeReason(with id: FirebaseReasonTemplate.ID) {
        updateReason(with: id) { $0 = nil }
    }
}

struct ListUpdaterModifier: ViewModifier {

    /// Environment of the person list
    @EnvironmentObject var personListEnvironment: ListEnvironment<FirebasePerson>

    /// Environment of the fine list
    @EnvironmentObject var fineListEnvironment: ListEnvironment<FirebaseFine>

    /// Environment of the reason list
    @EnvironmentObject var reasonListEnvironment: ListEnvironment<FirebaseReasonTemplate>

    @EnvironmentObject var listEnvironmentUpdater: ListEnvironmentUpdater

    func body(content: Content) -> some View {
        content
            .onAppear {
                listEnvironmentUpdater.appendPersonObserver { id, changeHandler  in
                    personListEnvironment.update(with: id, change: changeHandler)
                }
                listEnvironmentUpdater.appendFineObserver { id, changeHandler  in
                    fineListEnvironment.update(with: id, change: changeHandler)
                }
                listEnvironmentUpdater.appendReasonObserver { id, changeHandler  in
                    reasonListEnvironment.update(with: id, change: changeHandler)
                }
            }
    }
}
