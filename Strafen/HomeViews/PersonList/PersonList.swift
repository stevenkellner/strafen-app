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
    
    /// Indicates if addNewPerson sheet is shown
    @State var isAddNewPersonSheetShown = false
    
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
                        .padding(.top, 35)
                    
                    // Search Bar and Person List
                    ScrollView(showsIndicators: false) {
                        
                        // Search Bar
                        SearchBar(searchText: $searchText)
                            .frame(width: 360)
                        
                        // Person List
                        LazyVStack(spacing: 15) {
                            ForEach(personListData.list!.filter({ searchText == "" || $0.personName.formatted.hasSubstring(searchText) }).sorted(by: {
                                if $0.id == settings.person!.id { return true
                                } else if $1.id == settings.person!.id { return false }
                                return $0.personName.formatted < $1.personName.formatted
                            })) { person in
                                NavigationLink(destination: PersonDetail(person: person, dismissHandler: $dismissHandler)) {
                                    PersonListRow(person: person)
                                        .animation(.none)
                                }.buttonStyle(PlainButtonStyle())
                            }
                        }.padding(.bottom, 20)
                            .padding(.top, 5)
                        
                    }.padding(.top, 10)
                        .animation(.default)
                    
                    Spacer()
                }
                
                // Add New Person Button
                if settings.person!.isCashier {
                    VStack(spacing: 0) {
                        Spacer()
                        HStack(spacing: 0) {
                            Spacer()
                            RoundedCorners()
                                .strokeColor(settings.style.strokeColor(colorScheme))
                                .fillColor(settings.style.fillColor(colorScheme, defaultStyle: Color.custom.lightGreen))
                                .lineWidth(settings.style == .default ? 1.5 : 0.5)
                                .radius(settings.style.radius)
                                .frame(width: 45, height: 45)
                                .overlay(
                                    Image(systemName: "text.badge.plus")
                                        .font(.system(size: 25, weight: .light))
                                        .foregroundColor(.textColor)
                                )
                                .padding([.trailing, .bottom], 20)
                                .onTapGesture {
                                    isAddNewPersonSheetShown = true
                                }
                                .sheet(isPresented: $isAddNewPersonSheetShown) {
                                    // PersonAddNew() TODO
                                }
                        }
                    }
                }
                
            }.edgesIgnoringSafeArea(.all)
                .navigationTitle("Title")
                .navigationBarHidden(true)
        }
    }
}

/// A Row of person list with details of one person.
struct PersonListRow: View {
    
    /// Contains details of the person
    let person: Person
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Person image
    @State var image: UIImage?
    
    /// Fine List Data
    @ObservedObject var fineListData = ListData.fine
    
    var body: some View {
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
                
            }.frame(width: 245)
            
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
                
            }.frame(width: 100)
            
        }.frame(width: 345, height: 50)
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
