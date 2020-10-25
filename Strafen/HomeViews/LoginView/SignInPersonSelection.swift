//
//  SignInPersonSelection.swift
//  Strafen
//
//  Created by Steven on 10/24/20.
//

import SwiftUI
import FirebaseFunctions

/// Sign in view to select the person
struct SignInPersonSelection: View {
    
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
                    PersonList(personList: personList, selectedPersonId: $selectedPersonId)
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
                ConfirmButton("Registrieren", connectionState: $signInConnectionState, buttonHandler: handleSignIn)
                    .padding(.bottom, 50)
                
            }.screenSize($screenSize, geometry: geometry)
        }.onAppear(perform: fetchPersonList)
            .onAppear(perform: changeAppereanceStyle)
        
    }
    
    /// Fetches person list of selected club
    func fetchPersonList() {
        fetchConnectionState = .loading
        let clubId = (SignInCache.shared.cachedStatus?.property as! SignInCache.PropertyUserIdNameClubId).clubId
        let url = URL(string: "clubs")!.appendingPathComponent(clubId.uuidString.uppercased()).appendingPathComponent("persons")
        NewFetcher.shared.fetch(from: url) { personList in
            guard let personList = personList else {
                return fetchConnectionState = .failed
            }
            self.personList = personList
            fetchConnectionState = .passed
        }
    }
    
    /// Handles sign in
    func handleSignIn() {
        guard signInConnectionState != .loading else { return }
        guard personList != nil else { return }
        signInConnectionState = .loading
        
        let personId = selectedPersonId ?? UUID()
        let cachedProperties = SignInCache.shared.cachedStatus?.property as! SignInCache.PropertyUserIdNameClubId
        let parameters: [String : String] = [
            "clubId": cachedProperties.clubId.uuidString,
            "id": personId.uuidString,
            "firstName": cachedProperties.name.firstName,
            "lastName": cachedProperties.name.lastName,
            "userId": cachedProperties.userId
        ]
        Functions.functions(region: "europe-west1").httpsCallable("registerPerson").call(parameters) { _, error in
            if error == nil {
                signInConnectionState = .passed
                SignInCache.shared.setState(to: nil)
                // TODO sign in
            } else {
                signInConnectionState = .failed
                // TODO show alert
            }
        }
    }
    
    /// Person List
    struct PersonList: View {
        
        /// List of all persons of selected club
        let personList: [NewPerson]
        
        /// Id of selected person
        @Binding var selectedPersonId: UUID?
        
        /// Search text
        @State var searchText = ""
        
        var body: some View {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // Search Bar
                    SearchBar(searchText: $searchText)
                        .frame(width: UIScreen.main.bounds.width * 0.95 + 15)
                    
                    // Text
                    Text("Wähle deinen Namen aus, wenn er vorhanden ist.")
                        .configurate(size: 20)
                        .padding(.horizontal, 20)
                        .lineLimit(2)
                    
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
        
        /// Observed Object that contains all settings of the app of this device
        @ObservedObject var settings = Settings.shared
        
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
                        .foregroundColor(settings: settings, plain: fillColor)
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

/// Contains all properties of a person
struct NewPerson: Identifiable {
    
    /// Id
    let id: UUID
    
    /// Name
    let name: PersonName
    
    /// Indicates if person is cachier, is nil if person isn't signed in
    let isCashier: Bool?
    
    /// User id for authentication
    let userId: String?
    
    /// Person to fetch from database
    struct CodablePerson: Codable {
    
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
        func person(with id: UUID) -> NewPerson {
            NewPerson(id: id, name: name.personName, isCashier: cashier, userId: userId)
        }
    }
}

struct NewFetcher {
    
    /// Shared instance for singelton
    static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    func fetch(from url: URL, completion completionHandler: @escaping ([NewPerson]?) -> Void) {
        Database.database().reference(withPath: url.path).observeSingleEvent(of: .value) { snapshot in
            guard let data = snapshot.value else { return completionHandler(nil) }
            let decoder = FirebaseDecoder()
            let personDict = try? decoder.decode(Dictionary<String, NewPerson.CodablePerson>.self, from: data)
            let personList = personDict.map { personDict in
                personDict.map { idString, person in
                    person.person(with: UUID(uuidString: idString)!)
                }
            }
            completionHandler(personList)
        }
    }
}
