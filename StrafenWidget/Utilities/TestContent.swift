//
//  TestContent.swift
//  StrafenWidgetExtension
//
//  Created by Steven on 26.07.20.
//

import SwiftUI

// This functions / variables / datas is used to test this widget and to display data in previews

extension Array {
    func permutate<T, R>(with other: [T], using transform: (Element, T) -> R) -> [R] {
        var permutatedList = [R]()
        forEach { element in
            other.forEach { otherElement in
                permutatedList.append(transform(element, otherElement))
            }
        }
        return permutatedList
    }
}

protocol EnumRandom: CaseIterable {
    static var random: Self { get }
}

extension EnumRandom {
    static var random: Self {
        allCases.randomElement()!
    }
}

extension Date {
    static func random(since startDate: Date = Date(timeIntervalSince1970: 0), till endDate: Date = Date()) -> Date {
        let interval = endDate.timeIntervalSince(startDate)
        let randomInterval = TimeInterval(arc4random_uniform(UInt32(interval)))
        return startDate.addingTimeInterval(randomInterval)
    }
}

struct TestReasonList {
    private let testReasonList = """
        [{"reason":"Training Unentschuldigtes Fehlen","id":"B68DBD8D-9224-40B2-B23B-CC3D3A647FA5","amount":30,"importance":"high"},
        {"reason":"Training Zu Spät >5min","id":"808ABE0E-FE9B-4DF2-AF70-413F8508F018","amount":5,"importance":"medium"},
        {"reason":"Training Zu Spät <5min","id":"9E98C047-5EF7-46D0-BE8B-3A72CD578FA3","amount":0.5,"importance":"low"},
        {"reason":"Training Schuhe Vergessen","id":"D701C811-1409-497B-8499-7265A644969D","amount":5,"importance":"medium"},
        {"reason":"Training Ausrüstung Vergessen","id":"E1D55E94-2BA1-497E-BE17-2EA066768444","amount":1,"importance":"low"},
        {"reason":"Eckla","id":"D72C0598-D074-45A8-8B27-12FED03D7428","amount":0.5,"importance":"low"},
        {"reason":"über Gesperrten Platz Laufen","id":"3FB5E6EA-D462-4793-A2DE-F5C67874C6AA","amount":1,"importance":"medium"},
        {"reason":"Spiel Unentschuldigtes Fehlen","id":"0672A386-1586-4AC8-8AB6-75698475FCFA","amount":50,"importance":"high"},
        {"reason":"Spiel Zu Spät >10min","id":"274DC22C-EA5A-41C9-9F23-09E78F9EC205","amount":7.5,"importance":"high"},
        {"reason":"Spiel Zu Spät 5-10min","id":"9A8CE442-45AE-4DA4-9B21-11DE8BE1935B","amount":5,"importance":"medium"},
        {"reason":"Spiel Zu Spät <5min","id":"349F3125-7B11-49A5-9448-5D0A244C0AED","amount":0.5,"importance":"low"},
        {"reason":"Spiel Schuhe Vergessen","id":"117F5D3E-8A5B-4DA2-AB79-939483B7EF85","amount":5,"importance":"medium"},
        {"reason":"Spiel Ausrüstung Vergessen","id":"555ACDCB-C845-449E-A4AA-A84C6D3EA95B","amount":3,"importance":"low"},
        {"reason":"Gelbe Karte Unsportlichkeit ","id":"A0A5B3DC-21F5-4336-8013-43015DC3B8BC","amount":10,"importance":"high"},
        {"reason":"Gelb-Rote Karte Unsportlichkeit ","id":"D69209A9-B423-42F2-B635-0C666B47829B","amount":30,"importance":"high"},
        {"reason":"Rote Karte Unsportlichkeit ","id":"D38C50F2-2D72-42B6-9E55-14CE8851B90C","amount":50,"importance":"high"},
        {"reason":"Verweis Vom Platz","id":"4735743D-7A37-404C-A0C9-9384A483E556","amount":50,"importance":"high"},
        {"reason":"Beleidigung Mitspieler","id":"2B37481E-DFF7-4961-9F53-CE250F2486BF","amount":10,"importance":"high"},
        {"reason":"Beleidigung Trainer","id":"67E6E873-8990-422E-9BC5-CA1CB73C46E0","amount":15,"importance":"high"},
        {"reason":"Ausrüstung In Kabine Vergessen","id":"C91E3042-4A4A-48DD-8E16-E477D783AA52","amount":1,"importance":"low"},
        {"reason":"Mit Stutzen Auslaufen","id":"7D986880-08D5-406B-88D0-336D57AF09F2","amount":2,"importance":"low"},
        {"reason":"Trikot Verkehrt Im Korb","id":"CD7CE504-8C0E-415C-B6C6-FE13802AF2AB","amount":1,"importance":"low"},
        {"reason":"Rauchen / Alkohol Im Trikot","id":"27EAD8D2-02CC-467A-8310-9B498573CA4A","amount":5,"importance":"medium"},
        {"reason":"Handy In Sitzung","id":"C39021FD-6CB2-42D3-B6AF-418125237652","amount":2,"importance":"low"},
        {"reason":"Sitzung Unentschuldigtes Fehlen","id":"35191E22-9A0A-4A6B-AEA6-CAEECFFAE729","amount":5,"importance":"medium"},
        {"reason":"Sitzung Zu Spät (pro 1min)","id":"E12449CB-B260-43A7-A557-47F5F9D4650C","amount":0.5,"importance":"high"},
        {"reason":"Einstand","id":"C3267651-164D-479A-B5BA-F1B57A429529","amount":50,"importance":"high"},
        {"reason":"Jahresbeitrag","id":"C131B98A-0069-46DB-9E9E-AAFD32D1E1EB","amount":50,"importance":"high"}]
        """
    
    let reasonList: [WidgetReason]
    
    static let shared = Self()
    
    private init() {
        let decoder = JSONDecoder()
        reasonList = try! decoder.decode([WidgetReason].self, from: testReasonList.data(using: .utf8)!)
    }
}

extension FineReasonCustom {
    static var random: FineReasonCustom {
        let randomReason = TestReasonList.shared.reasonList.randomElement()!
        return FineReasonCustom(reason: randomReason.reason, amount: randomReason.amount, importance: randomReason.importance)
    }
}

extension WidgetFineNoTemplate {
    static var random: WidgetFineNoTemplate {
        let randomPayed: WidgetFine.Payed
        if Bool.random() {
            randomPayed = .unpayed
        } else {
            var dateComponents = DateComponents()
            dateComponents.year = 2019
            dateComponents.month = 1
            dateComponents.day = 1
            let userCalendar = Calendar.current
            let startDate = userCalendar.date(from: dateComponents)
            let randomDate = Date.random(since: startDate ?? Date(timeIntervalSince1970: 1545264000), till: Date())
            randomPayed = .payed(date: randomDate)
        }
        return WidgetFineNoTemplate(date: FormattedDate(date: .random()), payed: randomPayed, number: (1...5).randomElement()!, id: UUID(), fineReason: .random)
    }
}

extension WidgetUrls.CodableSettings.Person {
    static var `default`: WidgetUrls.CodableSettings.Person {
        .init(id: UUID(), name: PersonName(firstName: "Max", lastName: "Mustermann"), clubId: UUID(), clubName: "Vereinsname", isCashier: false)
    }
}

extension Array where Element == WidgetFineNoTemplate {
    static var random: [Element] {
        (0..<5).map { _ in WidgetFineNoTemplate.random }
    }
}

let styleColorSchemPermutations = Array(WidgetUrls.CodableSettings.Style.allCases.permutate(with: ColorScheme.allCases, using: { (style: $0, colorScheme: $1) }).enumerated())
