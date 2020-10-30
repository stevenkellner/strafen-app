//
//  SignInPersonSelection.swift
//  Strafen
//
//  Created by Steven on 10/24/20.
//

import SwiftUI

/// Sign in view to select the person
struct SignInPersonSelection: View {
    
    /// Error messages
    @State var errorMessages: ErrorMessages? = nil
    
    /// State of the connection of person list fetch
    @State var fetchConnectionState: ConnectionState = .loading
    
    /// State of the connection of sign in button handles
    @State var signInConnectionState: ConnectionState = .passed
    
    /// List of all persons of selected club
    @State var personList: [NewPerson]? = nil
    
    /// Id of selected person
    @State var selectedPersonId: UUID? = nil
    
    /// Screen size of this view
    @State var screenSize: CGSize?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                // Bar to wipe sheet down
                SheetBar()
                
                // Header
                Header("Person Auswählen")
                
                if let personList = personList {
                    PersonList(personList: personList, selectedPersonId: $selectedPersonId, errorMessages: $errorMessages)
                    Spacer()
                } else if fetchConnectionState == .loading {
                    Spacer()
                    ProgressView("Laden")
                    Spacer()
                } else {
                    
                    // No connection
                    Spacer()
                    VStack(spacing: 30) {
                        Text("Keine Internetverbindung")
                            .configurate(size: 25)
                            .padding(.horizontal, 15)
                            .lineLimit(2)
                        Text("Erneut versuchen")
                            .foregroundColor(Color.custom.red)
                            .configurate(size: 25)
                            .padding(.horizontal, 15)
                            .lineLimit(2)
                            .onTapGesture(perform: fetchPersonList)
                    }
                    Spacer()
                    
                }
                
                // Confirm Button
                ConfirmButton()
                    .title("Registrieren")
                    .onButtonPress(handleSignIn)
                    .connectionState($signInConnectionState)
                    .errorMessages($errorMessages)
                    .padding(.bottom, 50)
                
            }.screenSize($screenSize, geometry: geometry)
        }.onAppear(perform: fetchPersonList)
        
    }
    
    /// Fetches person list of selected club
    func fetchPersonList() {
        fetchConnectionState = .loading
        let clubId = (SignInCache.shared.cachedStatus?.property as! SignInCache.PropertyUserIdNameClubId).clubId
        let url = URL(string: "clubs")!.appendingPathComponent(clubId.uuidString.uppercased()).appendingPathComponent("persons")
        NewFetcher.shared.fetch(from: url, wait: 2) { (personList: [NewPerson]?) in
            guard let personList = personList else {
                return fetchConnectionState = .failed
            }
            self.personList = personList
            fetchConnectionState = .passed
        }
        NewFetcher.shared.observe(of: url, list: $personList)
    }
    
    /// Handles sign in
    func handleSignIn() {
        guard signInConnectionState != .loading else { return }
        guard personList != nil else { return }
        errorMessages = nil
        signInConnectionState = .loading
        
        let personId = selectedPersonId ?? UUID()
        let cachedProperties = SignInCache.shared.cachedStatus?.property as! SignInCache.PropertyUserIdNameClubId
        let callItem = NewRegisterPersonCall(cachedProperties: cachedProperties, personId: personId)
        FunctionCaller.shared.call(callItem) { (taskState: TaskState) in
            if taskState == .passed {
                signInConnectionState = .passed
                SignInCache.shared.setState(to: nil)
                // TODO sign in
            } else {
                errorMessages = .internalErrorSignIn
                signInConnectionState = .failed
            }
        }
    }
    
    /// Person List
    struct PersonList: View {
        
        /// List of all persons of selected club
        let personList: [NewPerson]
        
        /// Id of selected person
        @Binding var selectedPersonId: UUID?
        
        /// Error messages
        @Binding var errorMessages: ErrorMessages?
        
        /// Search text
        @State var searchText = ""
        
        var body: some View {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // Search Bar
                    SearchBar(searchText: $searchText)
                        .frame(width: UIScreen.main.bounds.width * 0.95 + 15)
                    
                    // Text
                    if errorMessages == nil {
                        Text("Wähle deinen Namen aus, wenn er vorhanden ist.")
                            .configurate(size: 20)
                            .padding(.horizontal, 20)
                            .lineLimit(2)
                    } else {
                        ErrorMessageView(errorMessages: $errorMessages)
                    }
                    
                    // Person List
                    LazyVStack(spacing: 15) {
                        ForEach(personList.filterSorted(for: searchText, at: \.name.formatted)) { person in
                            PersonListRow(person: person, selectedPersonId: $selectedPersonId)
                        }.animation(.none)
                    }.padding(.top, 20)
                    
                }.padding(.bottom, 10)
                    .padding(.top, 5)
                    .animation(.default)
            }.padding(.bottom, 10)
                .padding(.top, 5)
        }
    }
    
    /// Row of person list
    struct PersonListRow: View {
        
        /// Person of this row
        let person: NewPerson
        
        /// Id of selected person
        @Binding var selectedPersonId: UUID?
        
        /// Image of the person
        @State var image: UIImage?
        
        var body: some View {
            ZStack {
                
                // Outline
                Outline()
                    .fillColor(fillColor)
                
                // Inside
                HStack(spacing: 0) {
                    
                    // Image
                    PersonRowImage(image: $image)
                    
                    // Name
                    Text(person.name.formatted)
                        .foregroundColor(plain: fillColor)
                        .font(.text(20))
                        .lineLimit(1)
                        .padding(.trailing, 15)
                    
                    Spacer()
                }
                
            }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                .onAppear(perform: fetchPersonImage)
                .onTapGesture(perform: handleTap)
        }
        
        /// Fill color
        var fillColor: Color? {
            if person.isCashier != nil {
                return Color.custom.red
            } else if person.id == selectedPersonId {
                return Color.custom.lightGreen
            }
            return nil
        }
        
        /// Fetch person image
        func fetchPersonImage() {
            // TODO
        }
        
        /// Handle tap
        func handleTap() {
            guard person.isCashier == nil else { return }
            if person.id == selectedPersonId {
                selectedPersonId = nil
            } else {
                selectedPersonId = person.id
            }
        }
    }
}



// TODO
import FirebaseDatabase
import CodableFirebase

/// Protocol for a list type of database
protocol NewListType: Identifiable where ID == UUID {
    
    /// Codable list type
    associatedtype CodableSelf: CodableListType
}

/// Protocol for a codable list type of database
protocol CodableListType: Codable {
    
    /// Associated list type of database
    associatedtype AssociatedListType: NewListType
    
    /// Convert it to associated list type
    func listType(with id: UUID) -> AssociatedListType
}

/// Contains all properties of a person
struct NewPerson: NewListType {
    
    /// Id
    let id: UUID
    
    /// Name
    let name: PersonName
    
    /// Indicates if person is cachier, is nil if person isn't signed in
    let isCashier: Bool?
    
    /// User id for authentication
    let userId: String?
    
    /// Person to fetch from database
    struct CodableSelf: CodableListType {
        
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
    
        /// Name
        let name: CodablePersonName
        
        /// Indicates if person is cachier, is nil if person isn't signed in
        let cashier: Bool?
        
        /// User id for authentication
        let userId: String?
        
        /// Convertes to person
        func listType(with id: UUID) -> NewPerson {
            NewPerson(id: id, name: name.personName, isCashier: cashier, userId: userId)
        }
    }
}

/// Fetches list from database
struct NewFetcher {
    
    /// Data event type set with childAdded, childChanged, childRemoved
    struct DataEventTypeSet: OptionSet {
        
        /// Raw value
        let rawValue: Int

        /// Child was addedy
        static let childAdded = DataEventTypeSet(rawValue: 1 << 0)
        
        /// Child was changed
        static let childChanged = DataEventTypeSet(rawValue: 1 << 1)
        
        /// Child was removed
        static let childRemoved = DataEventTypeSet(rawValue: 1 << 2)
        
        /// All
        static let all: DataEventTypeSet = [.childAdded, .childChanged, .childRemoved]
    }
    
    /// Shared instance for singelton
    static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    /// Fetches a list of list type from database
    func fetch<Type>(from url: URL, wait waitingTime: Double? = nil, completion completionHandler: @escaping ([Type]?) -> Void) where Type: NewListType {
        
        /// Indicates if task should be executed
        var executeTask = true
        
        // Set execute task to false after waiting time is expired
        if let waitingTime = waitingTime {
            DispatchQueue.main.asyncAfter(deadline: .now() + waitingTime) {
                executeTask = false
                completionHandler(nil)
            }
        }
        
        // Fetch data from database
        Database.database().reference(withPath: url.path).observeSingleEvent(of: .value) { snapshot in
            guard executeTask else { return }
            guard let data = snapshot.value else { return completionHandler(nil) }
            let list: [Type]? = decodeFetchedList(from: data)
            completionHandler(list)
        }
        
    }
    
    /// Decodes fetched data from database to list
    private func decodeFetchedList<Type>(from data: Any) -> [Type]? where Type: NewListType {
        let decoder = FirebaseDecoder()
        let dictionary = try? decoder.decode(Dictionary<String, Type.CodableSelf>.self, from: data)
        let list = dictionary.map { dictionary in
            dictionary.map { idString, item in
                item.listType(with: UUID(uuidString: idString)!) as! Type
            }
        }
        return list
    }
    
    /// Observe a list of database and change local list if database list changed
    func observe<Type>(of url: URL, eventTypes: DataEventTypeSet = .all, list listBinding: Binding<[Type]?>) where Type: NewListType {
        if eventTypes.contains(.childAdded) {
            observeChildAdded(of: url, list: listBinding)
        }
        if eventTypes.contains(.childChanged) {
            observeChildChanged(of: url, list: listBinding)
        }
        if eventTypes.contains(.childRemoved) {
            observeChildRemove(of: url, list: listBinding)
        }
    }
    
    /// Observe a list of database if a child was added and change local list
    private func observeChildAdded<Type>(of url: URL, list listBinding: Binding<[Type]?>) where Type: NewListType {
        Database.database().reference(withPath: url.path).observe(.childAdded) { snapshot in
            guard let data = snapshot.value else { return }
            if let item: Type = decodeFetchedItem(from: data, key: snapshot.key) {
                listBinding.wrappedValue?.append(item)
            }
        }
    }
    
    /// Observe a list of database if a child was changed and change local list
    private func observeChildChanged<Type>(of url: URL, list listBinding: Binding<[Type]?>) where Type: NewListType {
        Database.database().reference(withPath: url.path).observe(.childChanged) { snapshot in
            guard let data = snapshot.value else { return }
            if let item: Type = decodeFetchedItem(from: data, key: snapshot.key) {
                listBinding.wrappedValue?.mapped { $0.id == item.id ? item : $0 }
            }
        }
    }
    
    /// Observe a list of database if a child was removed and change local list
    private func observeChildRemove<Type>(of url: URL, list listBinding: Binding<[Type]?>) where Type: NewListType {
        Database.database().reference(withPath: url.path).observe(.childRemoved) { snapshot in
            listBinding.wrappedValue?.filtered { $0.id != UUID(uuidString: snapshot.key)! }
        }
    }
    
    /// Decodes fetched data from database to list type item
    private func decodeFetchedItem<Type>(from data: Any, key: String) -> Type? where Type: NewListType {
        let decoder = FirebaseDecoder()
        let item = try? decoder.decode(Type.CodableSelf.self, from: data)
        return item?.listType(with: UUID(uuidString: key)!) as! Type?
    }
}



// TODO
import FirebaseFunctions

/// Can be call with Firebase functions
protocol FunctionCallable {
    
    /// Https callable function name
    var functionName: String { get }
    
    /// Change parametes
    var parameters: NewParameters { get }
}

/// Function call has a decodable result
protocol FunctionCallResult {
    
    /// Type of call result data
    associatedtype CallResult: Decodable
}

/// Parameters for change
struct NewParameters {
    
    /// Parameters
    var parameters: [String : String]
    
    init(_ parameters: [String : String] = [:], _ adding: ((inout [String : String]) -> Void)? = nil) {
        self.parameters = parameters
        if let adding = adding {
            adding(&self.parameters)
        }
    }
    
    /// Add single value
    mutating func add(_ value: String, for key: String) {
        parameters[key] = value
    }
    
    /// Add more values
    mutating func add(_ moreParameters: [String : String]) {
        parameters.merge(moreParameters) { firstValue, _ in firstValue}
    }
}

/// Used to register a new person in the database
struct NewRegisterPersonCall: FunctionCallable {
    
    /// Cached user id, name and club id
    let cachedProperties: SignInCache.PropertyUserIdNameClubId
    
    /// Person id
    let personId: UUID
    
    /// Function name
    let functionName = "registerPerson"
    
    /// Parameters
    var parameters: NewParameters {
        NewParameters { parameters in
            parameters["clubId"] = cachedProperties.clubId.uuidString
            parameters["id"] = personId.uuidString
            parameters["firstName"] = cachedProperties.name.firstName
            parameters["lastName"] = cachedProperties.name.lastName
            parameters["userId"] = cachedProperties.userId
            parameters["signInDate"] = String(data: try! JSONEncoder().encode(Date()), encoding: .utf8)!
        }
    }
}

/// Used to create a new club in the database
struct NewClubCall: FunctionCallable {
    
    /// Cached user id, name
    let cachedProperties: SignInCache.PropertyUserIdName
    
    /// Club credentials with club name and club identifer
    let clubCredentials: SignInClubInput.ClubCredentials
    
    /// Club id
    let clubId: UUID
    
    /// Person id
    let personId: UUID
    
    /// Function name
    let functionName: String = "newClub"
    
    /// Parameters
    var parameters: NewParameters {
        NewParameters { parameters in
            parameters["clubId"] = clubId.uuidString
            parameters["clubName"] = clubCredentials.clubName
            parameters["personId"] = personId.uuidString
            parameters["personFirstName"] = cachedProperties.name.firstName
            parameters["personLastName"] = cachedProperties.name.lastName
            parameters["clubIdentifier"] = clubCredentials.clubIdentifier
            parameters["userId"] = cachedProperties.userId
            parameters["signInDate"] = String(data: try! JSONEncoder().encode(Date()), encoding: .utf8)!
        }
    }
}

/// Used to get club id from club identifer
struct GetClubIdCall: FunctionCallable, FunctionCallResult {
    
    /// Result type
    typealias CallResult = UUID
    
    /// Club identifier
    let identifier: String
    
    /// Function name
    let functionName = "getClubId"
    
    /// Parameters
    var parameters: NewParameters {
        NewParameters { parameters in
            parameters["identifier"] = identifier
        }
    }
}

/// Used to get club and person id from user id
struct GetClubPersonIdCall: FunctionCallable,FunctionCallResult {
    
    /// Function call result
    struct CallResult: Decodable {
        
        /// Person id
        let personId: UUID
        
        /// Club id
        let clubId: UUID
    }
    
    /// User id
    let userId: String
    
    /// Function name
    let functionName = "getClubPersonId"
    
    /// Parameters
    var parameters: NewParameters {
        NewParameters { parameters in
            parameters["userId"] = userId
        }
    }
}

/// Used to check if a club identifier already exists
struct ClubIdentifierAlreadyExistsCall: FunctionCallable, FunctionCallResult {
    
    /// Result type
    typealias CallResult = Bool
    
    /// Club identifier
    let identifier: String
    
    /// Function name
    let functionName = "existsClubWithIdentifier"
    
    /// Parameters
    var parameters: NewParameters {
        NewParameters { parameters in
            parameters["identifier"] = identifier
        }
    }
}

/// Calls firebase functions
struct FunctionCaller {
    
    /// Shared instance for singelton
    static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    /// Change given item on server and local
    func call(_ item: FunctionCallable, handler completionHandler: @escaping (Result<HTTPSCallableResult, Error>) -> Void) {
        Functions.functions(region: "europe-west1").httpsCallable(item.functionName).call(item.parameters.parameters) { result, error in
            if let result = result {
                completionHandler(.success(result))
            } else if let error = error {
                completionHandler(.failure(error))
            } else {
                fatalError("Function call returns no result and no error.")
            }
        }
    }
    
    /// Change given item on server and local
    func call(_ item: FunctionCallable, passedHandler: @escaping (HTTPSCallableResult) -> Void, failedHandler: @escaping (Error) -> Void) {
        call(item) { (result: Result<HTTPSCallableResult, Error>) in
            switch result {
            case .success(let result):
                passedHandler(result)
            case .failure(let error):
                failedHandler(error)
            }
        }
    }
    
    /// Change given item on server and local
    func call<CallType>(_ item: CallType, handler completionHandler: @escaping (Result<CallType.CallResult, Error>) -> Void) where CallType: FunctionCallable & FunctionCallResult {
        call(item) { (result: Result<HTTPSCallableResult, Error>) in
            let decodedResult = result.flatMap { result -> Result<CallType.CallResult, Error> in
                let decoder = FirebaseDecoder()
                do {
                    let decodedResult = try decoder.decode(CallType.CallResult.self, from: result.data)
                    return .success(decodedResult)
                } catch {
                    return .failure(error)
                }
            }
            completionHandler(decodedResult)
        }
    }
    
    /// Change given item on server and local
    func call<CallType>(_ item: CallType, passedHandler: @escaping (CallType.CallResult) -> Void, failedHandler: @escaping (Error) -> Void) where CallType: FunctionCallable & FunctionCallResult {
        call(item) { (result: Result<CallType.CallResult, Error>) in
            switch result {
            case .success(let result):
                passedHandler(result)
            case .failure(let error):
                failedHandler(error)
            }
        }
    }
    
    /// Change given item on server and local
    func call(_ item: FunctionCallable, taskStateHandler: @escaping (TaskState) -> Void) {
        call(item) { _ in
            taskStateHandler(.passed)
        } failedHandler: { _ in
            taskStateHandler(.failed)
        }
    }
}
