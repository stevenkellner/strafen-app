//
//  Array.swift
//  Strafen
//
//  Created by Steven on 12.07.20.
//

import Foundation

// Extension of Fine Array for amount sums of given person
extension Array where Element == Fine {
    
    /// Payed amount sum of given person
    func payedAmountSum(of personId: UUID) -> Euro {
        filter {
            $0.personId == personId && $0.payed.boolValue
        }.reduce(Euro.zero) { result, fine in
            result + fine.fineReason.amount * fine.number + (fine.latePaymentInterest ?? .zero)
        }
    }
    
    /// Unpayed amount sum of given person
    func unpayedAmountSum(of personId: UUID) -> Euro {
        filter {
            $0.personId == personId && $0.payed == .unpayed
        }.reduce(Euro.zero) { result, fine in
            result + fine.fineReason.amount * fine.number + (fine.latePaymentInterest ?? .zero)
        }
    }
    
    /// Medium amount sum of given person
    func mediumAmountSum(of personId: UUID) -> Euro {
        filter {
            $0.personId == personId && $0.payed == .unpayed && ($0.fineReason.importance == .high || $0.fineReason.importance == .medium)
        }.reduce(Euro.zero) { result, fine in
            result + fine.fineReason.amount * fine.number + (fine.latePaymentInterest ?? .zero)
        }
    }
    
    /// High amount sum of given person
    func highAmountSum(of personId: UUID) -> Euro {
        filter {
            $0.personId == personId && $0.payed == .unpayed && $0.fineReason.importance == .high
        }.reduce(Euro.zero) { result, fine in
            result + fine.fineReason.amount * fine.number + (fine.latePaymentInterest ?? .zero)
        }
    }
    
    /// Total amount sum of given person
    func totalAmountSum(of personId: UUID) -> Euro {
        filter {
            $0.personId == personId
        }.reduce(Euro.zero) { result, fine in
            result + fine.fineReason.amount * fine.number + (fine.latePaymentInterest ?? .zero)
        }
    }
}

// Extension of Array for sorted with order
extension Array {
    
    /// Order of sorted array
    enum Order {
        
        /// Ascending
        case ascending
        
        /// Descanding
        case descanding
    }
    
    func sorted<T>(by keyPath: KeyPath<Element, T>, order: Order = .ascending) -> [Element] where T: Comparable {
        sorted { firstElement, secondElement in
            switch order {
            case .ascending:
                return firstElement[keyPath: keyPath] < secondElement[keyPath: keyPath]
            case .descanding:
                return firstElement[keyPath: keyPath] > secondElement[keyPath: keyPath]
            }
        }
    }
    
    func sorted<T>(by sortValue: (Element) throws -> T, order: Order = .ascending) rethrows -> [Element] where T: Comparable {
        try sorted { firstElement, secondElement in
            switch order {
            case .ascending:
                return try sortValue(firstElement) < sortValue(secondElement)
            case .descanding:
                return try sortValue(firstElement) > sortValue(secondElement)
            }
        }
    }
}

/// Extension of Array for mapped and filtered
extension Array {
    
    /// Mapped array
    mutating func mapped(_ transform: (Element) throws -> Element) rethrows {
        self = try map(transform)
    }
    
    /// Filtered Array
    mutating func filtered(_ isIncluded: (Element) throws -> Bool) rethrows {
        self = try filter(isIncluded)
    }
}

/// Extension of Array to filter for a search text
extension Array {
    
    /// Filter Array for a search text
    func filter(for searchText: String, at keyPath: KeyPath<Element, String>) -> [Element] {
        filter { element in
            element[keyPath: keyPath].searchFor(searchText)
        }
    }
    
    /// Filter and sort array for a search text
    func filterSorted(for searchText: String, at keyPath: KeyPath<Element, String>) -> [Element] {
        filter(for: searchText, at: keyPath).sorted(by: keyPath)
    }
}

/// Extension of Array to filter for a search text for String with deafult keyPath
extension Array where Element == String {
    
    /// Filter Array for a search text
    func filter(for searchText: String, at keyPath: KeyPath<Element, String> = \.self) -> [Element] {
        filter { element in
            element[keyPath: keyPath].searchFor(searchText)
        }
    }
    
    /// Filter and sort array for a search text
    func filterSorted(for searchText: String, at keyPath: KeyPath<Element, String> = \.self) -> [Element] {
        filter(for: searchText, at: keyPath).sorted(by: keyPath)
    }
}

/// Extension of Array to sort person list so that the logged in person is at start
extension Array where Element == Person {
    
    /// Sort Array so that the logged in person is at start
    func sorted(for loggedInPerson: Settings.Person) -> [Element] {
        sorted { firstPerson, secondPerson in
            if firstPerson.id == loggedInPerson.id {
                return true
            } else if secondPerson.id == loggedInPerson.id {
                return false
            }
            return firstPerson.personName.formatted < secondPerson.personName.formatted
        }
    }
}

// Extension of Array to get a new array with unique elemets
extension Array where Element: Hashable {
    
    /// Array with unique elemets
    var unique: [Element] {
        Array(Set(self))
    }
}
