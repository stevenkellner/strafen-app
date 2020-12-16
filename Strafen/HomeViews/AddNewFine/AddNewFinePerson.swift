//
//  AddNewFinePerson.swift
//  Strafen
//
//  Created by Steven on 17.07.20.
//

import SwiftUI

/// View to select person for new fine
struct AddNewFinePerson: View {
    
    /// Indicates if this view is for selecting several persons
    let forSeveralPersons: Bool
    
    /// Ids of selected persons
    @State var personIds: [NewPerson.ID]
    
    /// Handles person selection
    let completionHandler: ([NewPerson.ID]) -> Void
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Person List Data
    @ObservedObject var personListData = NewListData.person
    
    /// Text searched in search bar
    @State var searchText = ""
     
    var body: some View {
        VStack(spacing: 0) {
            
            // Bar to wipe sheet down
            SheetBar()
            
            // Header
            Header("Person Auswählen")
            
            if let personList = personListData.list {
                
                // Empty List Text
                if personList.isEmpty {
                    Text("Es sind keine Personen registriert.")
                        .configurate(size: 25)
                        .lineLimit(2)
                        .padding(.horizontal, 15)
                        .padding(.top, 50)
                }
                
                // Search Bar and list
                ScrollView {
                    VStack(spacing: 0) {
                            
                        // Search Bar
                        if !personList.isEmpty {
                            SearchBar(searchText: $searchText)
                                .frame(width: UIScreen.main.bounds.width * 0.95 + 15)
                        }
                        
                        LazyVStack(spacing: 15) {
                            ForEach(personList.sortedForList(with: searchText)) { person in
                                AddNewFinePersonRow(person: person, personIds: $personIds)
                                    .onTapGesture {
                                        personIds.toggle(person.id)
                                        if !forSeveralPersons {
                                            completionHandler(personIds)
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                    }
                            }
                        }.padding(.bottom, 10)
                        
                    }
                }.padding(.top, 10)
                
            } else {
                Text("No available view")
            }
            
            Spacer(minLength: 0)
            
            // Cancel and Cofirm Button
            ZStack {
                if forSeveralPersons {
                    
                    // Cancel and Cofirm Button
                    CancelConfirmButton()
                        .onCancelPress {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .onConfirmPress {
                            completionHandler(personIds)
                            presentationMode.wrappedValue.dismiss()
                        }

                } else {
                    
                    // Cancel Button
                    CancelButton()
                        .onButtonPress {
                            presentationMode.wrappedValue.dismiss()
                        }
                }
            }.padding(.bottom, 50)
                .padding(.top, 15)
            
        }.setScreenSize
    }
    
    
    /// Row of a person of AddNewFinePerson
    struct AddNewFinePersonRow: View {
        
        /// Person of this row
        let person: NewPerson
        
        /// Ids of selected persons
        @Binding var personIds: [NewPerson.ID]
        
        /// Image of the person
        @State var image: UIImage?
        
        var body: some View {
            ZStack {
                
                // Outline
                Outline()
                    .fillColor(personIds.contains(person.id) ? Color.custom.lightGreen : nil)
                
                // Inside
                HStack(spacing: 0) {
                    
                    // Image
                    PersonRowImage(image: $image)
                    
                    // Name
                    Text(person.name.formatted)
                        .foregroundColor(plain: personIds.contains(person.id) ? Color.custom.lightGreen : nil)
                        .font(.text(20))
                        .lineLimit(1)
                        .padding(.horizontal, 15)
                    
                    Spacer()
                }
                
            }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                .onAppear {
//                    ImageData.shared.fetch(of: person.id) { image in TODO
//                        self.image = image
//                    }
                }
        }
    }
}

// Extension of Array to filter and sort it for person list
extension Array where Element == NewPerson {
    
    /// Filtered and sorted for person list
    fileprivate func sortedForList(with searchText: String) -> [Element] {
        filter(for: searchText, at: \.name.formatted).sorted(by: \.name.formatted)
    }
}
