//
//  SettingsForceSignOut.swift
//  Strafen
//
//  Created by Steven on 9/7/20.
//

import SwiftUI

/// View to force sign out other persons
struct SettingsForceSignOut: View {
    
    /// Alert type
    enum AlertType: AlertTypeProtocol {

        /// Alert when confirm button is pressed
        case confirmButton(count: Int, action: () -> Void)

        /// Id for Identifiable
        var id: Int {
            switch self {
            case .confirmButton(count: _, action: _):
                return 0
            }
        }

        /// Alert of all alert types
        var alert: Alert {
            switch self {
            case .confirmButton(count: let count, action: let action):
                let personString = count == 1 ? "Person" : "Personen"
                return Alert(title: Text("\(personString) Abmelden"),
                             message: Text("Möchtest du diese \(personString) wirklich abmelden?"),
                             primaryButton: .destructive(Text("Abbrechen")),
                             secondaryButton: .default(Text("Bestätigen"), action: action))
            }
        }
    }
    
    ///Dismiss handler
    @Binding var dismissHandler: DismissHandler
    
    /// Person list data
    @ObservedObject var personListData = ListData.person
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Alert type
    @State var alertType: AlertType? = nil
    
    /// Ids of selected persons
    @State var personIds = [Person.ID]()
    
    /// Type of function call error
    @State var functionCallErrorMessages: ErrorMessages? = nil
    
    /// Connection State
    @State var connectionState: ConnectionState = .passed
    
    /// Text searched in search bar
    @State var searchText = ""
    
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
                
                if let personList = personListData.list?.filter({ $0.signInData != nil && $0.id != Settings.shared.person?.id }) {
                    
                    // Empty List Text
                    if personList.isEmpty {
                        Text("Es sind keine weiteren Personen registriert.")
                            .configurate(size: 25)
                            .lineLimit(2)
                            .padding(.horizontal, 15)
                            .padding(.top, 50)
                    }
                    
                    // Search Bar and Person List
                    ScrollView {
                        VStack(spacing: 0) {
                                
                            // Search Bar
                            if !personList.isEmpty {
                                SearchBar(searchText: $searchText)
                                    .frame(width: UIScreen.main.bounds.width * 0.95 + 15)
                            }
                            
                            LazyVStack(spacing: 15) {
                                ForEach(personList.sortedForList(with: searchText)) { person in
                                    SettingsForceSignOutRow(person: person, personIds: $personIds)
                                }
                            }.padding(.bottom, 10)
                            
                        }
                    }.padding(.top, 10)
                    
                } else {
                    Text("No available view")
                }
                
                Spacer()
                
                // Cancel and confirm button
                VStack(spacing: 5) {
                    
                    // Cancel and Confirm button
                    CancelConfirmButton()
                        .connectionState($connectionState)
                        .onCancelPress { presentationMode.wrappedValue.dismiss() }
                        .onConfirmPress($alertType, value: .confirmButton(count: personIds.count, action: handleConfirm)) {
                            guard !(personListData.list?.filter({ $0.signInData != nil && $0.id != Settings.shared.person?.id }).isEmpty ?? true) else {
                                presentationMode.wrappedValue.dismiss()
                                return false
                            }
                            if personIds.isEmpty {
                                functionCallErrorMessages = .noPersonsSelected
                                return false
                            }
                            return true
                        }.alert(item: $alertType)
                    
                    // Error messages
                    ErrorMessageView(errorMessages: $functionCallErrorMessages)
                    
                }.padding(.bottom, functionCallErrorMessages == nil ? 35 : 10)
                    .animation(.default)
            }
            
        }.edgesIgnoringSafeArea(.all)
            .setScreenSize
            .hideNavigationBarTitle()
            .onAppear {
                dismissHandler = { presentationMode.wrappedValue.dismiss() }
            }
    }
    
    /// Handles cofirm button pressed
    func handleConfirm() {
        functionCallErrorMessages = nil
        guard !personIds.isEmpty else { return functionCallErrorMessages = .noPersonsSelected }
        guard connectionState != .loading,
              let clubId = Settings.shared.person?.clubProperties.id else { return }
        connectionState = .loading
        
        let dispatchGroup = DispatchGroup()
        for personId in personIds {
            dispatchGroup.enter()
            let callItem = ForceSignOutCall(personId: personId, clubId: clubId)
            FunctionCaller.shared.call(callItem) { _ in
                personIds.filtered { $0 != personId }
                dispatchGroup.leave()
            } failedHandler: { _ in
                connectionState = .failed
                functionCallErrorMessages = .internalErrorSave
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            connectionState = .passed
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    /// Row of a SettingsForceSignOut
    struct SettingsForceSignOutRow: View {
        
        /// Person of this row
        let person: Person

        /// Ids of selected persons
        @Binding var personIds: [Person.ID]
        
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
                    Text(person.name.formatted)
                        .font(.text(20))
                        .foregroundColor(settings.style == .default || !personIds.contains(person.id) ? .textColor : Color.custom.lightGreen)
                        .lineLimit(1)
                        .padding(.horizontal, 15)
                    
                    Spacer()
                }
                
            }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                .onTapGesture {
                    personIds.toggle(person.id)
                }
                .onAppear {
                    guard let clubId = Settings.shared.person?.clubProperties.id else { return }
                    ImageStorage.shared.getImage(.personImage(clubId: clubId, personId: person.id), size: .thumbsSmall) { image in
                        self.image = image
                    }
                }
        }
    }
}

// Extension of Array to filter and sort it for person list
extension Array where Element == Person {
    
    /// Filtered and sorted for person list
    fileprivate func sortedForList(with searchText: String) -> [Element] {
        filter(for: searchText, at: \.name.formatted).sorted(by: \.name.formatted)
    }
}
