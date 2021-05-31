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
