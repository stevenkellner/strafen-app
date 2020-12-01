//
//  PersonList.swift
//  Strafen
//
//  Created by Steven on 12.07.20.
//

import SwiftUI

/// List of all persons
struct PersonList: View {
    
    ///Dismiss handler
    @Binding var dismissHandler: DismissHandler
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = NewSettings.shared
    
    /// Person List Data
    @ObservedObject var personListData = NewListData.person
    
    /// Text searched in search bar
    @State var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                
                // Background color
                colorScheme.backgroundColor
                
                // Header and list
                VStack(spacing: 0) {
                    
                    // Header
                    Header("Alle Personen")
                        .padding(.top, 50)
                    
                    
                    if let personList = personListData.list {
                        
                        // Empty List Text
                        if personList.isEmpty {
                            VStack(spacing: 20) {
                                if settings.properties.person?.isCashier ?? false {
                                    Text("Du hast noch keine Person erstellt.")
                                        .configurate(size: 25).lineLimit(2)
                                    Text("Füge eine Neue mit der Taste unten rechts hinzu.")
                                        .configurate(size: 25).lineLimit(2)
                                } else {
                                    Text("Es sind keine Personen registriert.")
                                        .configurate(size: 25).lineLimit(2)
                                }
                            }.padding(.horizontal, 15)
                                .padding(.top, 50)
                        }
                        
                        // Search Bar and list
                        ScrollView {
                            
                            // Search Bar
                            if !personList.isEmpty {
                                SearchBar(searchText: $searchText)
                                    .frame(width: UIScreen.main.bounds.width * 0.95 + 15)
                            }
                            
                            LazyVStack(spacing: 15) {
                                ForEach(personList.sortedForList(with: searchText, settings: settings)) { person in
                                    PersonListRow(person: person, searchText: $searchText, dismissHandler: $dismissHandler)
                                }
                            }.padding(.bottom, 10)
                            
                        }.padding(.top, 10)
                        
                    } else {
                        Text("No available view")
                    }
                    
                    Spacer(minLength: 0)
                }
                
                // Add New Person Button
                AddNewListItemButton(list: $personListData.list) {
                    Text("Test") // PersonAddNew() TODO
                }
                
            }.hideNavigationBarTitle()
        }.edgesIgnoringSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .setScreenSize
    }
    
    
    /// A Row of person list with details of one person.
    struct PersonListRow: View {
        
        /// Contains details of the person
        let person: NewPerson
        
        /// Text searched in search bar
        @Binding var searchText: String
        
        ///Dismiss handler
        @Binding var dismissHandler: DismissHandler
        
        /// Fine List Data
        @ObservedObject var fineListData = NewListData.fine
        
        /// Reason List Data
        @ObservedObject var reasonListData = NewListData.reason
        
        /// Indicates if navigation link is active
        @State var isLinkActive = false
        
        /// Person image
        @State var image: UIImage?
        
        var body: some View {
            ZStack {
                
                // Navigation link to person detail
                EmptyNavigationLink(isActive: $isLinkActive) {
                    PersonDetail(person: person, dismissHandler: $dismissHandler)
                }
                
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        
                        // Left of the divider
                        ZStack {
                            
                            // Outline
                            Outline(.left)
                            
                            // Inside
                            HStack(spacing: 0) {
                                
                                // Image
                                PersonRowImage(image: $image)
                                
                                // Name
                                Text(person.name.formatted)
                                    .configurate(size: 20)
                                    .padding(.leading, 10)
                                    .lineLimit(1)
                                
                                Spacer()
                            }
                            
                        }.frame(width: geometry.size.width * 0.7)
                        
                        // Right of the divider
                        ZStack {
                            
                            // Outline
                            Outline(.right)
                                .fillColor(color)
                            
                            // Inside
                            Text(describing: amountText)
                                .foregroundColor(plain: color)
                                .font(.text(20))
                                .lineLimit(1)
                            
                        }.frame(width: geometry.size.width * 0.3)
                        
                    }
                }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                    .onTapGesture {
                        UIApplication.shared.dismissKeyboard()
                        searchText = ""
                        isLinkActive = true
                    }
                
//            }.onAppear { TODO
//                ImageData.shared.fetch(of: person.id) { image in
//                    self.image = image
//                }
            }
        }
        
        /// Amount sum of thsi person
        var amountSum: Array<NewFine>.AmountSum? {
            fineListData.list?.amountSum(of: person.id, with: reasonListData.list)
        }
        
        /// Color of the section right of the divider
        var color: Color {
            guard let unpayedSum = amountSum?.unpayed else { return Color.custom.lightGreen }
            return unpayedSum == .zero ? Color.custom.lightGreen : Color.custom.red
        }
        
        /// Text of the displayed amount
        var amountText: Amount {
            if let unpayedSum = amountSum?.unpayed, unpayedSum != .zero {
                return unpayedSum
            } else if let payedSum = amountSum?.payed {
                return payedSum
            }
            return .zero
        }
    }
}

// Extension of Array to filter and sort it for person list
extension Array where Element == NewPerson {
    
    /// Filtered and sorted for person list
    fileprivate func sortedForList(with searchText: String, settings: NewSettings) -> [Element] {
        filter(for: searchText, at: \.name.formatted).sorted(for: settings.properties.person)
    }
    
    /// Sort Array so that the logged in person is at start
    fileprivate func sorted(for loggedInPerson: NewSettings.Person?) -> [Element] {
        guard let loggedInPerson = loggedInPerson else { return self }
        return sorted { firstPerson, secondPerson in
            if firstPerson.id == loggedInPerson.id {
                return true
            } else if secondPerson.id == loggedInPerson.id {
                return false
            }
            return firstPerson.name.formatted < secondPerson.name.formatted
        }
    }
}
