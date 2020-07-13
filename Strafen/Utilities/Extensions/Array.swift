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
            $0.personId == personId && $0.payed == .payed
        }.reduce(Euro.zero) { result, fine in
            result + fine.wrappedAmount * fine.number
        }
    }
    
    /// Unpayed amount sum of given person
    func unpayedAmountSum(of personId: UUID) -> Euro {
        filter {
            $0.personId == personId && $0.payed == .unpayed
        }.reduce(Euro.zero) { result, fine in
            result + fine.wrappedAmount * fine.number
        }
    }
    
    /// Total amount sum of given person
    func totalAmountSum(of personId: UUID) -> Euro {
        filter {
            $0.personId == personId
        }.reduce(Euro.zero) { result, fine in
            result + fine.wrappedAmount * fine.number
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
}
