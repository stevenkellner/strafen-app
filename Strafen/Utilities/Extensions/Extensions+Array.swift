//
//  Extensions+Array.swift
//  Strafen
//
//  Created by Steven on 05.05.21.
//

import Foundation

extension Array {

    /// Map this array containing the results of mapping the given closure over the sequence’s elements.
    /// - Parameter transform: A mapping closure.
    ///   Transform accepts an element of this sequence as its parameter.
    /// - Throws: Rethrows transform error.
    mutating func mapped(_ transform: (Element) throws -> Element) rethrows {
        self = try map(transform)
    }

    /// Map this array containing the non-nil results of mapping the given closure over the sequence’s elements.
    /// - Parameter transform: A mapping closure.
    ///   Transform accepts an element of this sequence as its parameter.
    /// - Throws: Rethrows transform error.
    mutating func compactMapped(_ transform: (Element) throws -> Element?) rethrows {
        self = try compactMap(transform)
    }

    /// Map this array containing the results of mapping the given closure over the sequence’s elements.
    /// - Parameter transform: A mapping closure. 
    /// - Throws: Rethrows transform error.
    mutating func mapped(_ transform: (inout Element) throws -> Void) rethrows {
        self = try map {
            var element = $0
            try transform(&element)
            return element
        }
    }

    /// Filter this array given result of closure over the sequence's elements.
    /// - Parameter isIncluded: A isIncluded closure.
    ///     It takes an element if this sequence and returns true if element should retain in this sequence.
    /// - Throws: Rethrows isincluded error.
    mutating func filtered(_ isIncluded: (Element) throws -> Bool) rethrows {
        self = try filter(isIncluded)
    }

    /// Order of sorted array
    enum Order {

        /// Ascending
        case ascending

        /// Descanding
        case descanding
    }

    /// Sorts the elements by value returned by closure for a element in the given order
    /// - Parameters:
    ///   - order: order to sort
    ///   - sortValue: returns value to sort for a element
    /// - Throws: rethrows error
    /// - Returns: sorted array
    func sorted<T>(order: Order = .ascending, byValue sortValue: (Element) throws -> T) rethrows -> [Element] where T: Comparable {
        try sorted { firstElement, secondElement in
            switch order {
            case .ascending:
                return try sortValue(firstElement) < sortValue(secondElement)
            case .descanding:
                return try sortValue(firstElement) > sortValue(secondElement)
            }
        }
    }

    /// Sorts the element by value of the keypath for a element in the given order
    /// - Parameters:
    ///   - order: order to sort
    ///   - keyPath: used to get the value of the keypath for a element
    /// - Returns: sorted array
    func sorted<T>(order: Order = .ascending, by keyPath: KeyPath<Element, T>) -> [Element] where T: Comparable {
        sorted(order: order) { $0[keyPath: keyPath] }
    }
}

extension Array where Element: Comparable {

    /// Sorts the arra by value of the keypath for a element in the given order
    /// - Parameters:
    ///   - order: order to sort
    ///   - sortValue: returns value to sort for a element
    /// - Throws: rethrows error
    mutating func sort(order: Order = .ascending, byValue sortValue: (Element) throws -> Element) rethrows {
        self = try sorted(order: order, byValue: sortValue)
    }

    /// Sorts the array by value of the keypath for a element in the given order
    /// - Parameters:
    ///   - order: order to sort
    ///   - keyPath: used to get the value of the keypath for a element
    mutating func sort(order: Order = .ascending, by keyPath: KeyPath<Element, Element>) {
        self = sorted(order: order, by: keyPath)
    }
}

extension Array {

    /// Returns array with new element appended
    /// - Parameter newElement: element to append
    func appending(_ newElement: Element) -> [Element] {
        var list = self
        list.append(newElement)
        return list
    }
}

extension Array where Element: Hashable {

    /// Contains only unique elements
    var unique: [Element] {
        Array(Set(self))
    }
}

extension Array where Element == FirebaseFine {

    /// Sum of complete amount of all payed fines from person with given id
    /// - Parameters:
    ///   - personId: id of person of the fines
    ///   - reasonList: list of all reason templates
    /// - Returns: sum of complete amount
    func payed(of personId: FirebasePerson.ID, with reasonList: [FirebaseReasonTemplate]) -> Amount {
        filter {
            $0.assoiatedPersonId == personId && $0.isPayed
        }.reduce(into: .zero) { result, fine in
            result += fine.completeAmount(with: reasonList)
        }
    }

    /// Sum of complete amount of all unpayed fines from person with given id
    /// - Parameters:
    ///   - personId: id of person of the fines
    ///   - reasonList: list of all reason templates
    /// - Returns: sum of complete amount
    func unpayed(of personId: FirebasePerson.ID, with reasonList: [FirebaseReasonTemplate]) -> Amount {
        filter {
            $0.assoiatedPersonId == personId && !$0.isPayed
        }.reduce(into: .zero) { result, fine in
            result += fine.completeAmount(with: reasonList)
        }
    }

    /// Sum of complete amount of all unpayed fines with `.high` or `.medium` importances from person with given id
    /// - Parameters:
    ///   - personId: id of person of the fines
    ///   - reasonList: list of all reason templates
    /// - Returns: sum of complete amount
    func medium(of personId: FirebasePerson.ID, with reasonList: [FirebaseReasonTemplate]) -> Amount {
        filter {
            $0.assoiatedPersonId == personId && !$0.isPayed && ($0.fineReason.importance(with: reasonList) == .high || $0.fineReason.importance(with: reasonList) == .medium)
        }.reduce(into: .zero) { result, fine in
            result += fine.completeAmount(with: reasonList)
        }
    }

    /// Sum of complete amount of all unpayed fines with `.high` importances from person with given id
    /// - Parameters:
    ///   - personId: id of person of the fines
    ///   - reasonList: list of all reason templates
    /// - Returns: sum of complete amount
    func high(of personId: FirebasePerson.ID, with reasonList: [FirebaseReasonTemplate]) -> Amount {
        filter {
            $0.assoiatedPersonId == personId && !$0.isPayed && $0.fineReason.importance(with: reasonList) == .high
        }.reduce(into: .zero) { result, fine in
            result += fine.completeAmount(with: reasonList)
        }
    }

    /// Sum of complete amount of all fines from person with given id
    /// - Parameters:
    ///   - personId: id of person of the fines
    ///   - reasonList: list of all reason templates
    /// - Returns: sum of complete amount
    func total(of personId: FirebasePerson.ID, with reasonList: [FirebaseReasonTemplate]) -> Amount {
        filter {
            $0.assoiatedPersonId == personId
        }.reduce(into: .zero) { result, fine in
            result += fine.completeAmount(with: reasonList)
        }
    }
}

extension Array where Element: Equatable {

    /// Toggle if an element is in the list
    mutating func toggle(_ element: Element) {
        if let index = firstIndex(of: element) {
            remove(at: index)
        } else {
            append(element)
        }
    }
}

extension Array where Element: Identifiable {

    /// Append given element to list if list doesn't contain an element with same id as given element
    /// - Parameter newElement: new element to append
    mutating func appendIfNew(_ newElement: Element) {
        guard !contains(where: { $0.id == newElement.id }) else { return }
        append(newElement)
    }

    /// Append given elements to list if list doesn't contain an element with same id
    /// - Parameter newElements: new elements to append
    mutating func appendIfNew(contentOf newElements: [Element]) {
        for element in newElements {
            guard !contains(where: { $0.id == element.id }) else { return }
            append(element)
        }
    }

    /// Updates all elements with same element id in the list to given element
    /// - Parameter element: updated element
    mutating func update(_ element: Element) {
        mapped { $0.id == element.id ? element : $0 }
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
    mutating func update(with id: Element.ID, change changeHandler: (inout Element?) -> Void) {

        // Indicates whether an element with same id already exists in the list
        // or the element is new and should be appended to the list
        var isNewElement = true

        // Updates all elements with same id as specified id
        compactMapped { (item: Element) -> Element? in

            // Don't change elements with different id as specified id
            guard item.id == id else { return item }

            // Element isn't new since an element with same id as specifed id exists in the list
            isNewElement = false

            // Return updated element or nil if element should be removed from the list
            var updatedItem: Element? = item
            changeHandler(&updatedItem)
            return updatedItem
        }

        // Append element if the isn't an element with same id as specified id to the list
        if isNewElement {
            var newElement: Element?
            changeHandler(&newElement)
            guard let newElement = newElement else { return }
            append(newElement)
        }
    }

    /// Removes all elements with given element id
    /// - Parameter id: id of element to remove
    mutating func removeAll(with id: Element.ID) {
        removeAll { $0.id == id }
    }
}
