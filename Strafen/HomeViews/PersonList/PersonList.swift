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
    @Binding var dismissHandler: (() -> ())?
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Person List Data
    @ObservedObject var personListData = ListData.person
    
    /// Text searched in search bar
    @State var searchText = ""
    
    /// Screen size
    @State var screenSize: CGSize?
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ZStack {
                    
                    // Background color
                    colorScheme.backgroundColor
                    
                    // Header and list
                    VStack(spacing: 0) {
                        
                        // Header
                        Header("Alle Personen")
                            .padding(.top, 50)
                        
                        // Empty List Text
                        if personListData.list!.isEmpty {
                            if settings.person!.isCashier {
                                Text("Du hast noch keine Person erstellt.")
                                    .font(.text(25))
                                    .foregroundColor(.textColor)
                                    .padding(.horizontal, 15)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 50)
                                Text("Füge eine Neue mit der Taste unten rechts hinzu.")
                                    .font(.text(25))
                                    .foregroundColor(.textColor)
                                    .padding(.horizontal, 15)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 20)
                            } else {
                                Text("Es sind keine Personen registriert.")
                                    .font(.text(25))
                                    .foregroundColor(.textColor)
                                    .padding(.horizontal, 15)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 50)
                            }
                        }
                        
                        // Search Bar and Person List
                        ScrollView {
                            
                            // Search Bar
                            if !personListData.list!.isEmpty {
                                SearchBar(searchText: $searchText)
                                    .frame(width: UIScreen.main.bounds.width * 0.95 + 15)
                            }
                            
                            // Person List
                            LazyVStack(spacing: 15) {
                                ForEach(personListData.list!.filter(for: searchText, at: \.personName.formatted).sorted(for: settings.person!)) { person in
                                    PersonListRow(person: person, dismissHandler: $dismissHandler)
                                }.animation(.none)
                            }.padding(.bottom, 20)
                                .padding(.top, 5)
                                .animation(.default)

                        }.padding(.top, 10)
                        
                        Spacer()
                    }
                    
                    // Add New Person Button
                    AddNewListItemButton(list: $personListData.list) {
                        PersonAddNew()
                    }
                    
                }.edgesIgnoringSafeArea(.all)
                    .navigationTitle("Title")
                    .navigationBarHidden(true)
                
            }.frame(size: screenSize ?? geometry.size)
                .onAppear {
                    screenSize = geometry.size
                }
        }
    }
}

/// A Row of person list with details of one person.
struct PersonListRow: View {
    
    /// Contains details of the person
    let person: Person
    
    ///Dismiss handler
    @Binding var dismissHandler: (() -> ())?
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Person image
    @State var image: UIImage?
    
    /// Fine List Data
    @ObservedObject var fineListData = ListData.fine
    
    /// Indicates if navigation link is active
    @State var isLinkActive = false
    
    var body: some View {
        ZStack {
            
            NavigationLink(destination: PersonDetail(person: person, dismissHandler: $dismissHandler), isActive: $isLinkActive) {
                EmptyView()
            }.buttonStyle(PlainButtonStyle())
                .frame(size: .zero)
            
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
                        Text(person.personName.formatted)
                            .foregroundColor(.textColor)
                            .font(.text(20))
                            .lineLimit(1)
                            .padding(.trailing, 15)
                        
                        Spacer()
                    }
                    
                }.frame(width: UIScreen.main.bounds.width * 0.675)
                
                // Right of the divider
                ZStack {
                    
                    // Outline
                    Outline(.right)
                        .fillColor(settings.style.fillColor(colorScheme, defaultStyle: color))
                    
                    // Inside
                    Text(amountText)
                        .foregroundColor(settings.style == .default ? .textColor : color)
                        .font(.text(20))
                        .lineLimit(1)
                    
                }.frame(width: UIScreen.main.bounds.width * 0.275)
                
            }
                .onTapGesture {
                    UIApplication.shared.dismissKeyboard()
                    isLinkActive = true
                }
            
        }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
            .padding(.horizontal, 1)
            .onAppear {
                ImageData.shared.fetch(of: person.id) { image in
                    self.image = image
                }
            }
    }
    
    /// Color of the section right of the divider
    var color: Color {
        fineListData.list!.unpayedAmountSum(of: person.id) != .zero ? Color.custom.red : Color.custom.lightGreen
    }
    
    /// Text of the displayed amount
    var amountText: String {
        fineListData.list!.unpayedAmountSum(of: person.id) != .zero ? fineListData.list!.unpayedAmountSum(of: person.id).description : fineListData.list!.payedAmountSum(of: person.id).description
    }
}
