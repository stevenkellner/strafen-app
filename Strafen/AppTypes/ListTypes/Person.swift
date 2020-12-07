//
//  Person.swift
//  Strafen
//
//  Created by Steven on 03.07.20.
//

import Foundation

/// Person with name, id
struct Person: ListTypes, Identifiable, Equatable {
    
    /// Url to list on server
    static var serverListUrl = \AppUrls.listTypesUrls?.person
    
    /// List data of this server list type
    static let listData = ListData.person
    
    /// Url to changer on server
    static let changerUrl: KeyPath<AppUrls, URL>? = \AppUrls.changer.personList
    
    /// Parameters for POST method
    var postParameters: [String : Any]? {
        [
            "id": id,
            "firstName": firstName,
            "lastName": lastName
        ]
    }
    
    /// First name
    let firstName: String
    
    /// Last name
    let lastName: String
    
    /// id
    let id: UUID
    
    /// First and last name
    var personName: PersonName {
        PersonName(firstName: firstName, lastName: lastName)
    }
}

/// Contains all properties of a person
struct NewPerson {
    
    /// Type of Id
    typealias ID = Tagged<(NewPerson, id: Void), UUID>
    
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
extension NewPerson: NewListType {
    
    /// Url for database refernce
    static var url: URL {
        guard let clubId = NewSettings.shared.properties.person?.clubProperties.id else {
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
    
    /// Get person list of ListData
    static func getDataList() -> [NewPerson]? {
        NewListData.person.list
    }
    
    /// Change person list of ListData
    static func changeHandler(_ newList: [NewPerson]?) {
        NewListData.person.list = newList
    }
    
    /// Parameters for database change call
    var callParameters: NewParameters {
        NewParameters { parameters in
            parameters["itemId"] = id
            parameters["firstName"] = name.firstName
            parameters["lastName"] = name.lastName
            parameters["listType"] = "person"
        }
    }
}

// Extension of Person for CodableSelf
extension NewPerson {
    
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
        let last: String
        
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
