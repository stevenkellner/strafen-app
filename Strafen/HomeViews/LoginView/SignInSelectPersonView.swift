//
//  SignInSelectPersonView.swift
//  Strafen
//
//  Created by Steven on 02.07.20.
//

import SwiftUI

/// Sign in view to select the person
struct SignInSelectPersonView: View {
    
    /// Contains first and last name of a person
    let personName: PersonName
    
    /// Contains all properties for the login
    let personLogin: PersonLogin
    
    /// Club id
    let clubId: UUID!
    
    /// Club name
    let clubName: String!
    
    /// Selected person
    @State var selectedPerson: Person?
    
    /// Used to indicate whether signIn sheet is displayed or not
    @Binding var showSignInSheet: Bool
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Person List Data
    @ObservedObject var personListData = ListData.person
    
    /// State of send mail task connection
    @State var connectionState: ConnectionState = .passed
    
    /// Indicates if no connection alert is shown
    @State var noConnectionAlert = false
    
    /// Text searched in search bar
    @State var searchText = ""
    
    /// Screen size
    @State var screenSize: CGSize?
    
    var body: some View {
        ZStack {
            
            // Back Button
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("Zurück")
                        .font(.text(25))
                        .foregroundColor(.textColor)
                        .padding(.leading, 15)
                        .onTapGesture {
                            presentationMode.wrappedValue.dismiss()
                        }
                    Spacer()
                }.padding(.top, 30)
                Spacer()
            }
            
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    
                    // Bar to wipe sheet down
                    SheetBar()
                    
                    // Header
                    Header("Person Auswählen")
                        .padding(.top, 30)
                    
                    // Text
                    Text("Wähle dein Namen aus, wenn er nicht vorhanden ist, drücke auf 'Registrieren'.")
                        .font(.text(20))
                        .foregroundColor(.textColor)
                        .padding(.horizontal, 15)
                        .multilineTextAlignment(.center)
                        .padding(.top, 30)
                    
                    // Search bar and List
                    if let personList = personListData.list?.sorted(by: \.personName.formatted) {
                        ScrollView(showsIndicators: false) {
                            
                            // Search Bar
                            SearchBar(searchText: $searchText)
                                .frame(width: UIScreen.main.bounds.width * 0.95 + 15)
                            
                            LazyVStack(spacing: 15) {
                                ForEach(personList.filter(for: searchText, at: \.personName.formatted)) { person in
                                    SignInSelectPersonRow(person: person, clubId: clubId, selectedPerson: $selectedPerson)
                                }.animation(.none)
                            }.padding(.vertical, 10)
                                .animation(.default)
                        }.padding(.vertical, 10)
                    }
                    
                    Spacer()
                    
                    // Confirm Button
                    ConfirmButton("Registrieren", connectionState: $connectionState) {
                        registerPerson()
                    }.padding(.bottom, 50)
                        .alert(isPresented: $noConnectionAlert) {
                            Alert(title: Text("Kein Internet"), message: Text("Für diese Aktion benötigst du eine Internetverbindung."), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Erneut versuchen"), action: registerPerson))
                        }
                    
                }.frame(size: screenSize ?? geometry.size)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            screenSize = geometry.size
                        }
                    }
            }
        }.background(colorScheme.backgroundColor)
            .navigationTitle("title")
            .navigationBarHidden(true)
    }
    
    /// Register new person
    func registerPerson() {
        let personId = selectedPerson?.id ?? UUID()
        let person = RegisterPerson(clubId: clubId, personId: personId, personName: personName, login: personLogin)
        connectionState = .loading
        RegisterPersonChanger.shared.registerPerson(person) { taskState in
            if taskState == .passed {
                connectionState = .passed
                Settings.shared.person = .init(id: personId, name: selectedPerson?.personName ?? personName, clubId: clubId, clubName: clubName, isCashier: false)
                showSignInSheet = false
            } else {
                connectionState = .failed
                noConnectionAlert = true
            }
        }
    }
}

/// Row of SignInSelectPersonView
struct SignInSelectPersonRow: View {
    
    /// Person of this row
    let person: Person
    
    /// Club id
    let clubId: UUID!
    
    /// Selected person
    @Binding var selectedPerson: Person?
    
    /// Image of the person
    @State var image: UIImage?
    
    /// Indicates if alert shown
    @State var showAlert = false
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Club List Data
    @ObservedObject var clubListData = ListData.club
    
    var body: some View {
        ZStack {
            
            // Outline
            Outline()
                .fillColor(settings.style == .default ? (clubListData.list?.flatMap(\.allPersons).contains(where: { $0.id == person.id }) ?? false ? Color.custom.red : (person.id == selectedPerson?.id ? Color.custom.lightGreen : settings.style.fillColor(colorScheme))) : settings.style.fillColor(colorScheme))
            
            // Inside
            HStack(spacing: 0) {
                
                // Image
                PersonRowImage(image: $image)
                
                // Name
                Text(person.personName.formatted)
                    .foregroundColor(settings.style == .default ? .textColor : (clubListData.list?.flatMap(\.allPersons).contains(where: { $0.id == person.id }) ?? false ? Color.custom.red : (selectedPerson?.id == person.id ? Color.custom.lightGreen : .textColor)))
                    .font(.text(20))
                    .lineLimit(1)
                    .padding(.trailing, 15)
                
                Spacer()
            }
        }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
            .padding(.horizontal, 1)
            .onAppear {
                ImageData.shared.fetch(from: AppUrls.shared.imageDirUrl(of: clubId), of: person.id) { image in
                    self.image = image
                }
            }
            .onTapGesture {
                if clubListData.list?.flatMap(\.allPersons).contains(where: { $0.id == person.id }) ?? true {
                    showAlert = true
                } else if selectedPerson?.id != person.id {
                    selectedPerson = person
                } else {
                    selectedPerson = nil
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Nicht möglich"), message: Text("Diese Person ist bereits registriert."), dismissButton: .default(Text("Verstanden")))
            }
    }
}

#if DEBUG
struct SignInSelectPersonView_Previews: PreviewProvider {
    static var previews: some View {
        SignInSelectPersonView(personName: PersonName(firstName: "", lastName: ""), personLogin: PersonLoginEmail(email: "", password: ""), clubId: UUID(), clubName: "SG Kleinsendelbach / Hetzles", showSignInSheet: .constant(false))
    }
}
#endif
