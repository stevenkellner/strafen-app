//
//  SettingsForceSignOut.swift
//  Strafen
//
//  Created by Steven on 9/7/20.
//

import SwiftUI

/// View to force sign out other persons
struct SettingsForceSignOut: View {
    
    /// Alert Type
    enum AlertType {
        
        /// No Connection
        case noConnection
        
        /// No person selected
        case noPersonSelected
        
        /// Confirm alert
        case confirm
        
    }
    
    ///Dismiss handler
    @Binding var dismissHandler: (() -> ())?
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Club list data
    @ObservedObject var clubListData = ListData.club
    
    /// Ids of selected persons
    @State var personIds = [UUID]()
    
    /// Text searched in search bar
    @State var searchText = ""
    
    /// Connection State
    @State var connectionState: ConnectionState = .passed
    
    /// Indicates if a alert is shown
    @State var showAlert = false
    
    /// Alert type
    @State var alertType: AlertType = .confirm
    
    var body: some View {
        ZStack {
            
            // Background Color
            colorScheme.backgroundColor
            
            // Back Button
            BackButton()
            
            // Content
            VStack(spacing: 0) {
                
                // Header
                Header("Abmelden Erzwingen")
                    .padding(.top, 75)
                
                // Empty List Text
                if clubListData.list?.first(where: { $0.id == settings.person?.clubId })?.allPersons.filter({ !$0.isCashier }).isEmpty ?? true {
                    Text("Es sind keine weiteren Personen registriert.")
                        .font(.text(25))
                        .foregroundColor(.textColor)
                        .padding(.horizontal, 15)
                        .multilineTextAlignment(.center)
                        .padding(.top, 50)
                }
                
                // Search Bar and Person List
                if let allPersons = clubListData.list?.first(where: { $0.id == settings.person?.clubId })?.allPersons.filter({ !$0.isCashier }) {
                    ScrollView {
                        
                        // Search Bar
                        if !allPersons.isEmpty {
                            SearchBar(searchText: $searchText)
                                .frame(width: UIScreen.main.bounds.width * 0.95 + 15)
                        }
                        
                        // Person List
                        LazyVStack(spacing: 15) {
                            ForEach(allPersons.filter(for: searchText, at: \.personName.formatted).sorted(by: \.personName.formatted)) { person in
                                SettingsForceSignOutRow(person: person, personIds: $personIds)
                            }.animation(.none)
                        }.padding(.bottom, 20)
                            .padding(.top, 5)
                            .animation(.default)

                    }.padding(.top, 10)
                }
                
                Spacer()
                
                // Cancel and confirm button
                CancelConfirmButton(connectionState: $connectionState) {
                    presentationMode.wrappedValue.dismiss()
                } confirmButtonHandler: {
                    guard !(clubListData.list?.first(where: { $0.id == settings.person?.clubId })?.allPersons.filter({ !$0.isCashier }).isEmpty ?? true) else {
                        return presentationMode.wrappedValue.dismiss()
                    }
                    alertType = personIds.isEmpty ? .noPersonSelected : .confirm
                    showAlert = true
                }.alert(isPresented: $showAlert) {
                    switch alertType {
                    case .confirm:
                        return Alert(title: Text("\(personIds.count == 1 ? "Person" : "Personen") Abmelden"), message: Text("Möchtest du diese \(personIds.count == 1 ? "Person" : "Personen") wirklich abmelden?"), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Bestätigen"), action: handleConfirm))
                    case .noConnection:
                        return Alert(title: Text("Kein Internet"), message: Text("Für diese Aktion benötigst du eine Internetverbindung."), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Erneut versuchen"), action: handleConfirm))
                    case .noPersonSelected:
                        return Alert(title: Text("Keine Person Ausgewählt"), message: Text("Wähle die Personen aus, die du abmelden möchtest."), dismissButton: .default(Text("Verstanden")))
                    }
                }.padding(.bottom, 30)
            }
            
        }.edgesIgnoringSafeArea(.all)
            .navigationTitle("title")
            .navigationBarHidden(true)
            .onAppear {
                dismissHandler = {
                    presentationMode.wrappedValue.dismiss()
                }
            }
    }
    
    /// Handles cofirm button pressed
    func handleConfirm() {
        connectionState = .loading
        let dispatchGroup = DispatchGroup()
        for personId in personIds {
            dispatchGroup.enter()
            ForceSignOutChanger.shared.change(of: personId) { taskState in
                if taskState == .passed {
                    personIds.filtered { $0 != personId }
                    dispatchGroup.leave()
                } else {
                    connectionState = .failed
                    alertType = .noConnection
                    showAlert = true
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            connectionState = .passed
            presentationMode.wrappedValue.dismiss()
        }
    }
}

/// Row of a SettingsForceSignOut
struct SettingsForceSignOutRow: View {
    
    /// Person of this row
    let person: Club.ClubPerson

    /// Ids of selected persons
    @Binding var personIds: [UUID]
    
    /// Image of the person
    @State var image: UIImage?
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    var body: some View {
        ZStack {
            
            // Outline
            Outline()
                .fillColor(personIds.contains(person.id) ? Color.custom.lightGreen : settings.style.fillColor(colorScheme))
            
            // Inside
            HStack(spacing: 0) {
                
                // Image
                PersonRowImage(image: $image)
                
                // Name
                Text(person.personName.formatted)
                    .font(.text(20))
                    .foregroundColor(settings.style == .default || !personIds.contains(person.id) ? .textColor : Color.custom.lightGreen)
                    .lineLimit(1)
                    .padding(.horizontal, 15)
                
                Spacer()
            }
            
        }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
            .onTapGesture {
                if personIds.contains(person.id) {
                    personIds.filtered { $0 != person.id }
                } else {
                    personIds.append(person.id)
                }
            }
            .onAppear {
                ImageData.shared.fetch(of: person.id) { image in
                    self.image = image
                }
            }
    }
}
