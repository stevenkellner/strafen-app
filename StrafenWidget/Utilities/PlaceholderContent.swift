//
//  PlaceholderContent.swift
//  StrafenWidgetExtension
//
//  Created by Steven on 26.07.20.
//

import Foundation

extension ListData {
    
    private static let personId = Person.ID(rawValue: UUID())
    
    private static let reasons = ["Training Unentschuldigtes Fehlen", "Training Zu Spät >5min", "Training Zu Spät <5min", "Training Schuhe Vergessen", "Training Ausrüstung Vergessen", "Eckla", "über Gesperrten Platz Laufen", "Spiel Unentschuldigtes Fehlen", "Spiel Zu Spät >10min", "Spiel Zu Spät 5-10min","Spiel Zu Spät <5min", "Spiel Schuhe Vergessen","Spiel Ausrüstung Vergessen", "Gelbe Karte Unsportlichkeit ", "Gelb-Rote Karte Unsportlichkeit", "Rote Karte Unsportlichkeit", "Verweis Vom Platz","Beleidigung Mitspieler", "Beleidigung Trainer", "Ausrüstung In Kabine Vergessen", "Mit Stutzen Auslaufen", "Trikot Verkehrt Im Korb", "Rauchen / Alkohol Im Trikot", "Handy In Sitzung", "Sitzung Unentschuldigtes Fehlen", "Sitzung Zu Spät (pro 1min)", "Einstand", "Jahresbeitrag"]
    
    private static let reasonList = {
         reasons.map { reason in
            ReasonTemplate(id: ReasonTemplate.ID(rawValue: UUID()), reason: reason, importance: .random, amount: .random(between: .lowRange))
        }.compactMap { reason in
            Bool.random() ? reason : nil
        }
    }()
    
    private static let fineList = {
        (4..<10).map { _ -> Fine in
            let date = Date.random()
            let fineReason: FineReason
            if Bool.random() {
                fineReason = FineReasonTemplate(templateId: reasonList.randomElement()!.id)
            } else {
                fineReason = FineReasonCustom(reason: reasons.randomElement()!, amount: .random(between: .lowRange), importance: .random)
            }
            return Fine(id: Fine.ID(rawValue: UUID()), assoiatedPersonId: personId, date: date, payed: .random(after: date), number: .random(in: 1..<5), fineReason: fineReason)
        }
    }()
    
    static func fetchPlaceholderLists() {
        person.list = [Person(id: personId, name: PersonName(firstName: "Max", lastName: "Mustermann"), signInData: nil)]
        reason.list = reasonList
        fine.list = fineList
    }
}

extension Importance {
    static var random: Importance {
        [.low, .medium, .high].randomElement()!
    }
}

extension Amount {
    static func random(between range: Range<Amount>) -> Amount {
        let lowerBound = range.lowerBound.doubleValue
        let upperBound = range.upperBound.doubleValue
        let doubleValue = Double.random(in: lowerBound..<upperBound)
        return Amount(doubleValue: doubleValue)
    }
}

extension Range where Bound == Amount {
    static var lowRange = Amount(1, subUnit: 0)..<Amount(15, subUnit: 0)
}

extension Date {
    static func random(since startDate: Date = Date(timeIntervalSince1970: 0), till endDate: Date = Date()) -> Date {
        let interval = endDate.timeIntervalSince(startDate)
        let randomInterval = TimeInterval(arc4random_uniform(UInt32(interval)))
        return startDate.addingTimeInterval(randomInterval)
    }
}

extension Payed {
    static func random(after payDate: Date) -> Payed {
        Bool.random() ? .unpayed : .payed(date: .random(since: payDate))
    }
}
