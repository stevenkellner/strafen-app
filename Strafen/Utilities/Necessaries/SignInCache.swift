//
//  SignInCache.swift
//  Strafen
//
//  Created by Steven on 10/17/20.
//

import Foundation

/// Cache of sign in status
class SignInCache: ObservableObject {
    
    /// Codable properties of user id and optional person name
    struct PropertyUserId: SignInCacheProperty {
        
        /// User id
        let userId: String
        
        /// Person name
        let name: PersonNameComponents
    }
    
    /// Codable properties of user id and person name
    struct PropertyUserIdName: SignInCacheProperty {
        
        /// User id
        let userId: String
        
        /// Person name
        let name: PersonName
        
        /// Init with user id string and person name
        init(userId: String, name: PersonName) {
            self.userId = userId
            self.name = name
        }
        
        /// Init with PropertyUserId and person name
        init(userId: PropertyUserId, name: PersonName) {
            self.userId = userId.userId
            self.name = name
        }
    }
    
    /// Codable properties of user id, person name and club id
    struct PropertyUserIdNameClubId: SignInCacheProperty {
        
        /// User id
        let userId: String
        
        /// Person name
        let name: PersonName
        
        /// Club id
        let clubId: String
        
        /// Init with PropertyUserIdName and clubId
        init(userIdName: PropertyUserIdName, clubId: String) {
            self.userId = userIdName.userId
            self.name = userIdName.name
            self.clubId = clubId
        }
    }
    
    /// Status of signing in
    enum Status: Identifiable {
        
        /// Inputs first and last name
        case nameInput(property: PropertyUserId)
        
        /// Selects club
        case clubSelection(property: PropertyUserIdName)
        
        /// Selects person
        case personSelection(property: PropertyUserIdNameClubId)
        
        /// Inputs club properties
        case clubPropertiesInput(property: PropertyUserIdName)
        
        /// Decoding error
        enum DecodingError: Error {
            
            /// Value not found
            case valueNotFound
        }
        
        /// Gets status of a data
        static func getStatus(of data: Data) throws -> Status {
            let rootDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            var propertyData: Data? = nil
            if let property = rootDictionary?["property"] {
                propertyData = try JSONSerialization.data(withJSONObject: property, options: [])
            }
            switch rootDictionary?["status"] as? String {
            case "nameInput":
                return .nameInput(property: try getProperty(of: propertyData!))
            case "clubSelection":
                return .clubSelection(property: try getProperty(of: propertyData!))
            case "personSelection":
                return .personSelection(property: try getProperty(of: propertyData!))
            case "clubPropertiesInput":
                return .clubPropertiesInput(property: try getProperty(of: propertyData!))
            default:
                throw DecodingError.valueNotFound
            }
        }
        
        /// Gets property of a data
        private static func getProperty<Property>(of data: Data?) throws -> Property where Property: SignInCacheProperty {
            guard let data = data else {
                throw DecodingError.valueNotFound
            }
            let decoder = JSONDecoder()
            return try decoder.decode(Property.self, from: data)
        }
        
        /// Save status
        func saveStatus() throws {
            let data = try getJsonData()
            if FileManager.default.fileExists(atPath: SignInCache.fileUrl.path) {
                try data.write(to: SignInCache.fileUrl, options: .atomic)
            } else {
                FileManager.default.createFile(atPath: SignInCache.fileUrl.path, contents: data)
            }
        }
        
        /// Gets JSON data
        private func getJsonData() throws -> Data {
            struct JsonObject<Property>: Encodable where Property: SignInCacheProperty {
                let status: String
                let property: Property?
            }
            let encoder = JSONEncoder()
            let data: Data
            switch self {
            case .nameInput(property: let property):
                data = try encoder.encode(JsonObject(status: "nameInput", property: property))
            case .clubSelection(property: let property):
                data = try encoder.encode(JsonObject(status: "clubSelection", property: property))
            case .personSelection(property: let property):
                data = try encoder.encode(JsonObject(status: "personSelection", property: property))
            case .clubPropertiesInput(property: let property):
                data = try encoder.encode(JsonObject(status: "clubPropertiesInput", property: property))
            }
            return data
        }
        
        /// The stable identity of the entity associated with this instance.
        var id: Int { .zero }
    }
    
    /// Url to cache file
    static let fileUrl: URL = {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("signInCache").appendingPathExtension("json")
    }()
    
    /// Shared instance for singelton
    static let shared = SignInCache()
    
    /// Private init for singleton
    private init() {}
    
    /// Status of signing in
    @Published var state: Status? = nil
    
    /// Checks status of signing in
    func checkSignInStatus() {
        setState(to: cachedStatus)
    }
    
    /// Cached status
    var cachedStatus: Status? {
        guard let data = FileManager.default.contents(atPath: SignInCache.fileUrl.path) else {
            return  nil
        }
        return try! Status.getStatus(of: data)
    }
    
    /// Set state
    func setState(to newState: Status?) {
        state = newState
        if let state = newState {
            try! state.saveStatus()
        } else {
            try? FileManager.default.removeItem(at: SignInCache.fileUrl)
        }
    }
}

/// Sign in cache property protocol
protocol SignInCacheProperty: Codable {}
