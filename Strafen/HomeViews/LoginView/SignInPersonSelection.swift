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
    @State var personList: [Person]? = nil
    
    /// Id of selected person
    @State var selectedPersonId: Person.ID? = nil
    
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
        Logging.shared.log(with: .info, "Start fetching person list of clubId: \(clubId)")
        
        let url = URL.personList(with: clubId)
        Fetcher.shared.fetch(from: url, wait: 2) { (personList: [Person]?) in
            guard let personList = personList else {
                Logging.shared.log(with: .error, "Couldn't fetch person list.")
                return fetchConnectionState = .failed
            }
            Logging.shared.log(with: .info, "Person list fetched successfully.")
            Logging.shared.log(with: .info, "Person list: \(personList)")
            self.personList = personList
            fetchConnectionState = .passed
        }
        Fetcher.shared.observe(of: url, list: $personList)
    }
    
    /// Handles sign in
    func handleSignIn() {
        guard signInConnectionState != .loading else { return }
        guard personList != nil else { return }
        errorMessages = nil
        signInConnectionState = .loading
        Logging.shared.log(with: .info, "Started to sign in.")
        
        let personId = selectedPersonId ?? Person.ID(rawValue: UUID())
        let cachedProperties = SignInCache.shared.cachedStatus?.property as! SignInCache.PropertyUserIdNameClubId
        
        // Register person to database
        let callItem = RegisterPersonCall(cachedProperties: cachedProperties, personId: personId)
        FunctionCaller.shared.call(callItem) { (result: RegisterPersonCall.CallResult) in
            
            Logging.shared.log(with: .info, "Sign in succeeded.")
            Logging.shared.log(with: .info, "With result: \(result)")
            signInConnectionState = .passed
            SignInCache.shared.setState(to: nil)
            let clubProperties = Settings.Person.ClubProperties(id: cachedProperties.clubId, name: result.clubName, identifier: result.clubIdentifier, regionCode: result.regionCode, inAppPaymentActive: result.inAppPaymentActive)
            Settings.shared.person = .init(clubProperties: clubProperties, id: personId, name: cachedProperties.name, signInDate: Date(), isCashier: false)
            
        } failedHandler: { error in
            Logging.shared.log(with: .error, "An error occurs, that isn't handled: \(error.localizedDescription)")
            errorMessages = .internalErrorSignIn(code: 9)
            signInConnectionState = .failed
        }
    }
    
    /// Person List
    struct PersonList: View {
        
        /// List of all persons of selected club
        let personList: [Person]
        
        /// Id of selected person
        @Binding var selectedPersonId: Person.ID?
        
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
        let person: Person
        
        /// Id of selected person
        @Binding var selectedPersonId: Person.ID?
        
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
            if person.signInData != nil {
                return Color.custom.red
            } else if person.id == selectedPersonId {
                return Color.custom.lightGreen
            }
            return nil
        }
        
        /// Fetch person image
        func fetchPersonImage() {
            let clubId = (SignInCache.shared.cachedStatus?.property as! SignInCache.PropertyUserIdNameClubId).clubId
            ImageStorage.shared.getImage(.personImage(clubId: clubId, personId: person.id), size: .thumbsSmall) { image in
                self.image = image
            }
        }
        
        /// Handle tap
        func handleTap() {
            guard person.signInData == nil else { return }
            if person.id == selectedPersonId {
                selectedPersonId = nil
            } else {
                selectedPersonId = person.id
            }
        }
    }
}
