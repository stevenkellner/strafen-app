//
//  Person.swift
//  Strafen
//
//  Created by Steven on 03.07.20.
//

import Foundation

/// Contains all properties of a person
struct Person {
    
    /// Type of Id
    typealias ID = Tagged<(Person, id: Void), UUID>
    
    /// Data if person is signed in
    struct SignInData: Codable {
        
        /// Indicates if person is cachier, is nil if person isn't signed in
        let isCashier: Bool
        
        /// User id for authentication
        let userId: String
        
        /// Date of sign in
        let signInDate: Date
    }
    
    /// Id
    let id: ID
    
    /// Name
    let name: PersonName
    
    /// Data if person is signed in
    let signInData: SignInData?
}

// Extension of Person to confirm to ListType
extension Person: ListType {
    
    /// Url for database refernce
    static var url: URL {
        guard let clubId = Settings.shared.person?.clubProperties.id else {
            fatalError("No person is logged in.")
        }
        return URL.personList(with: clubId)
    }
    
    /// Init with id and codable self
    init(with id: ID, codableSelf: CodableSelf) {
        self.id = id
        self.name = codableSelf.name.personName
        self.signInData = codableSelf.signInData?.signInData
    }
    
    #if TARGET_MAIN_APP
    /// Get person list of ListData
    static func getDataList() -> [Person]? {
        ListData.person.list
    }
    
    /// Change person list of ListData
    static func changeHandler(_ newList: [Person]?) {
        ListData.person.list = newList
    }
    
    /// Parameters for database change call
    var callParameters: Parameters {
        Parameters { parameters in
            parameters["itemId"] = id
            parameters["firstName"] = name.firstName
            parameters["lastName"] = name.lastName
            parameters["listType"] = "person"
        }
    }
    #endif
}

// Extension of Person for CodableSelf
extension Person {
    
    /// Person to fetch from database
    struct CodableSelf: Codable {
    
        /// Name
        let name: CodablePersonName
        
        /// Data if person is signed in
        let signInData: CodableSignInData?
    }
    
    /// Person name to fetch from database
    struct CodablePersonName: Codable {
        
        /// First name
        let first: String
        
        /// Last name
        let last: String?
        
        /// Convertes to person name
        var personName: PersonName {
            PersonName(firstName: first, lastName: last)
        }
    }
    
    /// Data if person is signed in
    struct CodableSignInData: Codable {
        
        /// Indicates if person is cachier, is nil if person isn't signed in
        let cashier: Bool
        
        /// User id for authentication
        let userId: String
        
        /// Date of sign in
        let signInDate: Date
        
        var signInData: SignInData {
            SignInData(isCashier: cashier, userId: userId, signInDate: signInDate)
        }
    }
}
