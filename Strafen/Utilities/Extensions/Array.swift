//
//  Array.swift
//  Strafen
//
//  Created by Steven on 12.07.20.
//

import Foundation

// Extension of Fine Array for amount sums of given person
extension Array where Element == Fine {
    
    /// Sum of amount of a fine list
    struct AmountSum {
        
        static var zero = AmountSum(of: Person.ID(rawValue: UUID()), fineList: [], reasonList: [])
        
        /// Fine list
        private let fineList: [Fine]
        
        /// Reason list
        private let reasonList: [ReasonTemplate]?
        
        /// Person id
        private let personId: Person.ID
        
        init(of personId: Person.ID, fineList: [Fine], reasonList: [ReasonTemplate]?) {
            self.personId = personId
            self.fineList = fineList
            self.reasonList = reasonList
        }
        
        /// Payed amount sum of the person
        var payed: Amount {
            fineList.filter {
                $0.assoiatedPersonId == personId && $0.isPayed
            }.reduce(into: .zero) { result, fine in
                result += fine.completeAmount(with: reasonList)
            }
        }
        
        /// Unpayed amount sum of the person
        var unpayed: Amount {
            fineList.filter {
                $0.assoiatedPersonId == personId && !$0.isPayed
            }.reduce(into: .zero) { result, fine in
                result += fine.completeAmount(with: reasonList)
            }
        }
        
        /// Medium amount sum of the person
        var medium: Amount {
            fineList.filter {
                $0.assoiatedPersonId == personId && !$0.isPayed && ($0.fineReason.importance(with: reasonList) == .high || $0.fineReason.importance(with: reasonList) == .medium)
            }.reduce(into: .zero) { result, fine in
                result += fine.completeAmount(with: reasonList)
            }
        }
        
        /// High amount sum of the person
        var high: Amount {
            fineList.filter {
                $0.assoiatedPersonId == personId && !$0.isPayed && $0.fineReason.importance(with: reasonList) == .high
            }.reduce(into: .zero) { result, fine in
                result += fine.completeAmount(with: reasonList)
            }
        }
        
        /// Total amount sum of the person
        var total: Amount {
            fineList.filter {
                $0.assoiatedPersonId == personId
            }.reduce(into: .zero) { result, fine in
                result += fine.completeAmount(with: reasonList)
            }
        }
    }
    
    /// Sum of amount of a fine list
    func amountSum(of personId: Person.ID, with reasonList: [ReasonTemplate]?) -> AmountSum {
        AmountSum(of: personId, fineList: self, reasonList: reasonList)
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
    
    func sorted<T>(byValue sortValue: (Element) throws -> T, order: Order = .ascending) rethrows -> [Element] where T: Comparable {
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

#if TARGET_MAIN_APP
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
#endif

// Extension of Array to get a new array with unique elemets
extension Array where Element: Hashable {
    
    /// Array with unique elemets
    var unique: [Element] {
        Array(Set(self))
    }
}

extension Array {
    func isEmpty(_ isIncluded: (Element) throws -> Bool) rethrows -> Bool {
        try filter(isIncluded).isEmpty
    }
}

extension Array {
    
    /// Adds an element to the end of the collection.
    func appending(_ newElement: Element) -> [Element] {
        var list = self
        list.append(newElement)
        return list
    }
    
    /// Adds the elements of a sequence or collection to the end of this collection.
    func appending(contentsOf newElements: [Element]) -> [Element] {
        var list = self
        list.append(contentsOf: newElements)
        return list
    }
}

// Extension of Array to toggle if an element is in the list
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
