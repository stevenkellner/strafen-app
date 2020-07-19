//
//  AddNewFinePerson.swift
//  Strafen
//
//  Created by Steven on 17.07.20.
//

import SwiftUI

/// View to select person for new fine
struct AddNewFinePerson: View {
    
    /// Handles person selection
    let completionHandler: (UUID) -> ()
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Person List Data
    @ObservedObject var personListData = ListData.person
    
    init(completionHandler: @escaping (UUID) -> ()) {
        self.completionHandler = completionHandler
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Bar to wipe sheet down
            SheetBar()
            
            // Title
            Header("Person Auswählen")
            
            // Empty List Text
            if personListData.list!.isEmpty {
                Text("Es sind keine Personen registriert.")
                    .font(.text(25))
                    .foregroundColor(.textColor)
                    .padding(.horizontal, 15)
                    .multilineTextAlignment(.center)
                    .padding(.top, 50)
            }
            
            // List of reasons
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 15) {
                    ForEach(personListData.list!.sorted(by: \.personName.formatted)) { person in
                        AddNewFinePersonRow(person: person)
                            .onTapGesture {
                                completionHandler(person.id)
                                presentationMode.wrappedValue.dismiss()
                            }
                    }
                }.padding(.bottom, 20)
                    .padding(.top, 5)
            }.padding(.top, 10)
            
            Spacer()
            
            // Cancel Button
            CancelButton {
                presentationMode.wrappedValue.dismiss()
            }.padding(.bottom, 30)
                .padding(.top, 15)
            
        }
    }
}

/// Row of a person of AddNewFinePerson
struct AddNewFinePersonRow: View {
    
    /// Person of this row
    let person: Person
    
    /// Image of the person
    @State var image: UIImage?
    
    var body: some View {
        ZStack {
            
            // Outline
            Outline()
            
            // Inside
            HStack(spacing: 0) {
                
                // Image
                PersonRowImage(image: $image)
                
                // Name
                Text(person.personName.formatted)
                    .font(.text(20))
                    .foregroundColor(.textColor)
                    .lineLimit(1)
                    .padding(.horizontal, 15)
                
                Spacer()
            }
            
        }.frame(width: 345, height: 50)
        .onAppear {
            ImageData.shared.fetch(of: person.id) { image in
                self.image = image
            }
        }
    }
}
