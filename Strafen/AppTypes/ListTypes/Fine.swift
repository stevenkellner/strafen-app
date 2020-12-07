//
//  Fine.swift
//  Strafen
//
//  Created by Steven on 12.07.20.
//

import SwiftUI

/// Contains all data of a fine
struct Fine: Identifiable, ListTypes {
    
    /// Url to list on server
    static let serverListUrl = \AppUrls.listTypesUrls?.fine
    
    /// List data of this server list type
    static let listData = ListData.fine
    
    /// Url to changer on server
    static let changerUrl: KeyPath<AppUrls, URL>? = \AppUrls.changer.fineList
    
    /// Parameters for POST method
    var postParameters: [String : Any]? {
        var parameters: [String : Any] = [
            "id": id,
            "personId": personId,
            "payed": payed.string,
            "number": number,
            "date": date.formattedForPost
        ]
        parameters.merge(fineReason.postParameters) { firstValue, _ in firstValue }
        return parameters
    }
    
    /// Importance of a fine
    enum Importance: Int, Codable {
        
        /// High importance
        case high = 2
        
        /// Medium importance
        case medium = 1
        
        /// Low importance
        case low = 0
        
        /// Error for decoding json
        enum CodingError: Error {
            
            /// Error for unknown string value
            case unknownStringValue
        }
        
        /// Init from decoder
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawImportance = try container.decode(String.self)
            switch rawImportance {
            case "high":
                self = .high
            case "medium":
                self = .medium
            case "low":
                self = .low
            default:
                throw CodingError.unknownStringValue
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(string)
        }
        
        /// String value of importance
        var string: String {
            switch self {
            case .high:
                return "high"
            case .medium:
                return "medium"
            case .low:
                return "low"
            }
        }
        
        /// Checks if an importance is higher or equal than another one
        static func >=(lhs: Importance, rhs: Importance) -> Bool {
            lhs.rawValue >= rhs.rawValue
        }
        
        /// Color of the imporance in the UI
        var color: Color {
            switch self {
            case .high:
                return Color.custom.red
            case .medium:
                return Color.custom.orange
            case .low:
                return Color.custom.yellow
            }
        }
    }
    
    /// Fine payed
    enum Payed: Decodable, Equatable {
        
        /// payed
        case payed(date: Date)
        
        /// unpayed
        case unpayed
        
        /// Coding Error
        enum CodingError: Error {
            
            /// Payed but no date
            case payedNoDate
        }
        
        /// Init from decoder
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            do {
                let rawPayed = try container.decode(Bool.self)
                if rawPayed {
                    throw CodingError.payedNoDate
                }
                self = .unpayed
            } catch CodingError.payedNoDate {
                throw CodingError.payedNoDate
            } catch {
                let date = try container.decode(FormattedDate.self)
                self = .payed(date: date.date)
            }
        }
        
        /// True if is payed
        var boolValue: Bool {
            self != .unpayed
        }
        
        /// String value of importance
        var string: String {
            switch self {
            case .payed(date: let date):
                return FormattedDate(date: date).formattedForPost
            case .unpayed:
                return "false"
            }
        }
        
        static func ==(lhs: Payed, rhs: Payed) -> Bool {
            lhs.string == rhs.string
        }
    }
    
    /// Id of the associated person
    let personId: UUID
    
    /// Date this fine was issued
    let date: FormattedDate
    
    /// Is fine payed
    var payed: Payed
    
    /// Number of fines
    let number: Int
    
    /// Id of the fine
    let id: UUID
    
    /// Fine reason for reason / amount / importance or templateId
    let fineReason: FineReason
}

// Extension of Fine to confirm to Equatable
extension Fine: Equatable {
    
    /// Function for Equatable
    static func == (lhs: Fine, rhs: Fine) -> Bool {
        var equal = lhs.personId == rhs.personId && lhs.date == rhs.date && lhs.payed == rhs.payed && lhs.number == rhs.number && lhs.id == rhs.id
        if let lhsFineReasonCustom = lhs.fineReason as? FineReasonCustom, equal {
            equal = lhsFineReasonCustom == rhs.fineReason as? FineReasonCustom
        } else if let lhsFineReasonTemplate = lhs.fineReason as? FineReasonTemplate, equal {
            equal = lhsFineReasonTemplate == rhs.fineReason as? FineReasonTemplate
        } else {
            equal = false
        }
        return equal
    }
}

// Extension of Fine to confirm to Decodable
extension Fine: Decodable {
    
    /// Keys for decoding json
    enum Keys: CodingKey {
        
        /// Person id
        case personId
        
        /// Date
        case date
        
        /// Payed
        case payed
        
        /// Number
        case number
        
        /// Id
        case id
        
        /// Reason
        case reason
        
        /// Amount
        case amount
        
        /// Importance
        case importance
        
        /// TemplateId
        case templateId
    }
    
    /// Init from decoder for decodable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        personId = try container.decode(UUID.self, forKey: .personId)
        date = try container.decode(FormattedDate.self, forKey: .date)
        payed = try container.decode(Payed.self, forKey: .payed)
        number = try container.decode(Int.self, forKey: .number)
        id = try container.decode(UUID.self, forKey: .id)
        let reason = try container.decode(Optional<String>.self, forKey: .reason)
        let amount = try container.decode(Optional<Euro>.self, forKey: .amount)
        let importace = try container.decode(Optional<Importance>.self, forKey: .importance)
        let templateId = try container.decode(Optional<UUID>.self, forKey: .templateId)
        if let templateId = templateId {
            fineReason = FineReasonTemplate(templateId: templateId)
        } else {
            fineReason = FineReasonCustom(reason: reason!, amount: amount!, importance: importace!)
        }
    }
}

/// Protocol of fine reason for reason / amount / importance or templateId
protocol FineReason {
    
    /// Reason
    ///
    /// Use it only if reason list is fetched
    var reason: String { get }
    
    /// Amount
    ///
    /// Use it only if reason list is fetched
    var amount: Euro { get }
    
    /// Importance
    ///
    /// Use it only if reason list is fetched
    var importance: Fine.Importance { get }
    
    /// Parameters for POST method
    var postParameters: [String : Any] { get }
}

/// Fine Reason for reason / amount / importance
struct FineReasonCustom: FineReason, Equatable {
    
    /// Reason
    let reason: String
    
    /// Amount
    let amount: Euro
    
    /// Importance
    let importance: Fine.Importance
    
    /// Parameters for POST method
    var postParameters: [String : Any] {
        [
            "amount": amount.doubleValue,
            "reason": reason,
            "importance": importance.string
        ]
    }
}

/// Fine Reason for templateId
struct FineReasonTemplate: FineReason, Equatable {
    
    /// Template id
    let templateId: UUID
    
    /// Reason
    ///
    /// Use it only if reason list is fetched
    var reason: String {
        ListData.reason.list!.first(where: { $0.id == templateId })!.reason
    }
    
    /// Amount
    ///
    /// Use it only if reason list is fetched
    var amount: Euro {
        ListData.reason.list!.first(where: { $0.id == templateId })!.amount
    }
    
    /// Importance
    ///
    /// Use it only if reason list is fetched
    var importance: Fine.Importance {
        ListData.reason.list!.first(where: { $0.id == templateId })!.importance
    }
    
    /// Parameters for POST method
    var postParameters: [String : Any] {
        [
            "templateId": templateId
        ]
    }
}

/// Extension of Fine to calculate the late payment interest
extension Fine {
    
    /// Late payment interest
    func latePaymentInterest(with latePaymentInterest: Settings.LatePaymentInterest) -> Euro {
        
        // Get start date
        let calender = Calendar.current
        var startDate = calender.startOfDay(for: date.date)
        startDate = calender.date(byAdding: latePaymentInterest.interestFreePeriod.unit.dateComponentFlag, value: latePaymentInterest.interestFreePeriod.value, to: startDate) ?? startDate
        
        // Get end date
        var endDate = Date()
        if case .payed(date: let paymentDate) = payed {
            endDate = paymentDate
        }
        
        // Return .zero if start date is greater than the end date
        guard startDate <= endDate else {
            return .zero
        }
        
        // Get number of components between start and end date
        let numberBetweenDates = latePaymentInterest.interestPeriod.unit.numberBetweenDates(start: startDate, end: endDate) / latePaymentInterest.interestPeriod.value
        
        // Original amount
        let originalAmount = fineReason.amount * number
        
        // Return late payment interest
        if latePaymentInterest.compoundInterest {
            return originalAmount * (pow(1 + latePaymentInterest.interestRate / 100, Double(numberBetweenDates)) - 1)
        } else {
            return originalAmount * (latePaymentInterest.interestRate / 100 * Double(numberBetweenDates))
        }
    }
    
    /// Late payment interest
    var latePaymentInterest: Euro? {
        guard let interest = Settings.shared.latePaymentInterest else { return nil }
        return latePaymentInterest(with: interest)
    }
}

/// Contains all properties of a fine
struct NewFine {
    
    /// Type of Id
    typealias Id = Tagged<(ReasonTemplate, id: Void), UUID>
    
    /// Id
    let id: Id
    
    /// Id of the associated person
    let assoiatedPersonId: NewPerson.ID
    
    /// Date this fine was issued
    let date: Date
    
    /// Is fine payed
    var payed: Payed
    
    /// Number of fines
    let number: Int
    
    /// Fine reason for reason / amount / importance or templateId
    let fineReason: NewFineReason
    
    /// Indicates if fine is payed
    var isPayed: Bool {
        payed != .unpayed
    }
    
    /// Complete amount of this fine
    func completeAmount(with reasonList: [ReasonTemplate]?) -> Amount {
        fineReason.amount(with: reasonList) * number + (latePaymentInterestAmount(with: reasonList) ?? .zero)
    }
    
    /// Color of amount text
    func amountTextColor(with reasonList: [ReasonTemplate]?) -> Color {
        isPayed ? Color.custom.lightGreen : fineReason.importance(with: reasonList).color
    }
}

// Extension of Fine to confirm to ListType
extension NewFine: NewListType {
    
    /// Url for database refernce
    static var url: URL {
        guard let clubId = NewSettings.shared.properties.person?.clubProperties.id else {
            fatalError("No person is logged in.")
        }
        return URL.fineList(with: clubId)
    }
    
    /// Init with id and codable self
    init(with id: ID, codableSelf: CodableSelf) {
        self.id = id
        self.assoiatedPersonId = codableSelf.personId
        self.date = codableSelf.date
        self.payed = codableSelf.payed
        self.number = codableSelf.number
        self.fineReason = codableSelf.reason.fineReason
    }
    
    /// Get fine list of ListData
    static func getDataList() -> [NewFine]? {
        NewListData.fine.list
    }
    
    /// Change fine list of ListData
    static func changeHandler(_ newList: [NewFine]?) {
        NewListData.fine.list = newList
    }
    
    
    /// Parameters for database change call
    var callParameters: NewParameters {
        NewParameters(fineReason.callParameters) { parameters in
            parameters["itemId"] = id
            parameters["personId"] = assoiatedPersonId
            parameters["payed"] = payed
            parameters["number"] = number
            parameters["date"] = date
            parameters["listType"] = "fine"
        }
    }
}

// Extension of Fine for CodableSelf
extension NewFine {
    
    /// Fine to fetch from database
    struct CodableSelf: Decodable {
        
        /// Id of the associated person
        let personId: NewPerson.ID
        
        /// Date this fine was issued
        let date: Date
        
        /// Is fine payed
        var payed: Payed
        
        /// Number of fines
        let number: Int
        
        /// Fine reason for reason / amount / importance or templateId
        let reason: NewCodableFineReason
    }
}

// Extension of Fine to calculate the late payment interest
extension NewFine {
    
    /// Late payment interest
    func latePaymentInterestAmount(with latePaymentInterest: Settings.LatePaymentInterest, reasonList: [ReasonTemplate]?) -> Amount {
        
        // Get start date
        let calender = Calendar.current
        var startDate = calender.startOfDay(for: date)
        startDate = calender.date(byAdding: latePaymentInterest.interestFreePeriod.unit.dateComponentFlag, value: latePaymentInterest.interestFreePeriod.value, to: startDate) ?? startDate
        
        // Get end date
        var endDate = Date()
        if case .payed(date: let paymentDate) = payed {
            endDate = paymentDate
        }
        
        // Return .zero if start date is greater than the end date
        guard startDate <= endDate else {
            return .zero
        }
        
        // Get number of components between start and end date
        let numberBetweenDates = latePaymentInterest.interestPeriod.unit.numberBetweenDates(start: startDate, end: endDate) / latePaymentInterest.interestPeriod.value
        
        // Original amount
        let originalAmount = fineReason.amount(with: reasonList) * number
        
        // Return late payment interest
        if latePaymentInterest.compoundInterest {
            return originalAmount * (pow(1 + latePaymentInterest.interestRate / 100, Double(numberBetweenDates)) - 1)
        } else {
            return originalAmount * (latePaymentInterest.interestRate / 100 * Double(numberBetweenDates))
        }
    }
    
    /// Late payment interest
    func latePaymentInterestAmount(with reasonList: [ReasonTemplate]?) -> Amount? {
        guard let interest = NewSettings.shared.properties.latePaymentInterest else { return nil }
        return latePaymentInterestAmount(with: interest, reasonList: reasonList)
    }
}
