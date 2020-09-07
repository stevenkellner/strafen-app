//
//  Extensions.swift
//  StrafenWidgetExtension
//
//  Created by Steven on 25.07.20.
//

import SwiftUI

// Extension of FileManager to get shared container Url
extension FileManager {
    
    /// Url of shared container
    var sharedContainerUrl: URL {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.stevenkellner.Strafen.settings")!
    }
}

// Extension of Fine Array for amount sums
extension Array where Element == WidgetFineNoTemplate {
    
    /// Payed amount sum
    func payedAmountSum(with latePaymentInterest: WidgetUrls.CodableSettings.LatePaymentInterest?) -> Euro {
        filter { fine in
            fine.payed.boolValue
        }.reduce(.zero) { result, fine in
            result + fine.fineReason.amount * fine.number + (fine.latePaymentInterest(with: latePaymentInterest) ?? .zero)
        }
    }
    
    /// Unpayed amount sum
    func unpayedAmountSum(with latePaymentInterest: WidgetUrls.CodableSettings.LatePaymentInterest?) -> Euro {
        filter { fine in
            !fine.payed.boolValue
        }.reduce(.zero) { result, fine in
            result + fine.fineReason.amount * fine.number + (fine.latePaymentInterest(with: latePaymentInterest) ?? .zero)
        }
    }
    
    /// Total amount sum
    func totalAmountSum(with latePaymentInterest: WidgetUrls.CodableSettings.LatePaymentInterest?) -> Euro {
        reduce(.zero) { result, fine in
            result + fine.fineReason.amount * fine.number + (fine.latePaymentInterest(with: latePaymentInterest) ?? .zero)
        }
    }
}

// Extension of Font for custom Text Font
extension Font {
    
    /// Custom text font of Futura-Medium
    static func text(_ size: CGFloat) -> Font {
        .custom("Futura-Medium", size: size)
    }
}

// Extension of ColorScheme to get the background color
extension ColorScheme {
    
    /// Background color of the app
    var backgroundColor: Color {
        self == .dark ? Color.custom.darkGray : .white
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
