//
//  PersonDetail.swift
//  Strafen
//
//  Created by Steven on 13.07.20.
//

import SwiftUI

/// Person Detail View
struct PersonDetail: View {
    
    /// Contains details of the person
    let person: NewPerson
    
    ///Dismiss handler
    @Binding var dismissHandler: DismissHandler
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = NewSettings.shared
    
    /// Fine List Data
    @ObservedObject var fineListData = NewListData.fine
    
    /// Reason List Data
    @ObservedObject var reasonListData = NewListData.reason
    
    /// Id of selected row for large design
    @State var selectedForLargeDesign: NewFine.ID? = nil
    
    /// Person image
    @State var image: UIImage?
    
    var body: some View {
        ZStack {
            
            // Background color
            colorScheme.backgroundColor
            
            // Back and edit button
            BackAndEditButton {
                PersonEditor(person: person) { image in
                    self.image = image
                }
            }
            
            // Person info and fine list
            VStack(spacing: 0) {
                
                // Image
                PersonImage(image: $image, personName: person.name)
                    .padding(.top, 60)
                    .padding(.vertical, image == nil ? 20 : 10)
                
                // Name
                Text(person.name.formatted)
                    .configurate(size: 35)
                    .lineLimit(1)
                    .padding(.horizontal, 25)
                
                // Amount Display
                AmountDisplay(personId: person.id)
                    .padding(.top, 15)
                
                // Underlines
                Underlines()
                    .padding(.top, 10)
                
                if let fineList = fineListData.list {
                    
                    // Empty List Text
                    if fineList.filter({ $0.assoiatedPersonId == person.id }).isEmpty {
                        VStack(spacing: 20) {
                            Text("Diese Person hat keine Strafen.")
                                .configurate(size: 25).lineLimit(2)
                            if settings.properties.person?.isCashier ?? false {
                                Text("Füge eine Neue mit der Taste unten rechts hinzu.")
                                .configurate(size: 25).lineLimit(2)
                            }
                        }.padding(.horizontal, 15)
                            .padding(.top, 30)
                    }
                    
                    // Fine List
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(fineList.sortedForList(of: person.id, with: reasonListData.list)) { fine in
                                FineListRow(of: fine, selectedForLargeDesign: $selectedForLargeDesign, dismissHandler: $dismissHandler)
                            }
                        }.padding(.bottom, 10)
                            .padding(.top, 5)
                    }.padding(.top, 10)
                    
                } else {
                    Text("No available view")
                }
                
                Spacer(minLength: 0)
            }
            
            // Add New Fine Button
            AddNewListItemButton(list: $fineListData.list, listFilter: { $0.assoiatedPersonId == person.id }) {
                Text("Test")
//                VStack(spacing: 0) { TODO
//
//                    // Bar to wipe sheet down
//                    SheetBar()
//
//                    // Content
//                    AddNewFine(personIds: [person.id])
//
//                }
            }
            
        }.edgesIgnoringSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .setDismissHandler($dismissHandler)
            .setScreenSize
            .onAppear {
//                ImageData.shared.fetch(of: person.id) { image in TODO
//                    self.image = image
//                }
            }
    }
    
    /// Image View for Person Detail
    struct PersonImage: View {
        
        /// Image of the person
        @Binding var image: UIImage?
        
        /// Person name
        let personName: PersonName

        /// Color scheme to get appearance of this device
        @Environment(\.colorScheme) var colorScheme
        
        /// Observed Object that contains all settings of the app of this device
        @ObservedObject var settings = NewSettings.shared
        
        /// Size of the image
        let imageSize: CGSize = .square(100)
        
        /// True if image detail is showed
        @State var showImageDetail = false
        
        var body: some View {
            VStack(spacing: 0) {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(image.size, contentMode: .fill)
                        .frame(size: imageSize)
                        .clipShape(Circle())
                        .toggleOnTapGesture($showImageDetail)
                        .overlay(Circle().stroke(settings.properties.style.strokeColor(colorScheme), lineWidth: settings.properties.style.lineWidth).frame(size: imageSize))
                        .sheet(isPresented: $showImageDetail) {
                            ImageDetail(image: image, personName: personName)
                        }
                } else {
                    Image(systemName: "person")
                        .resizable()
                        .font(.system(size: imageSize.height * 0.45, weight: .thin))
                        .frame(size: imageSize * 0.45)
                        .scaledToFit()
                        .offset(y: -imageSize.height * 0.03)
                        .foregroundColor(settings.properties.style.strokeColor(colorScheme))
                        .overlay(Circle().stroke(settings.properties.style.strokeColor(colorScheme), lineWidth: settings.properties.style.lineWidth).frame(size: imageSize * 0.75))
                }
            }
        }
    }
    
    /// Detail of the Image  // TODO improve image detail
    struct ImageDetail: View {
        
        /// Image
        let image: UIImage
        
        /// Person name
        let personName: PersonName

        /// Color scheme to get appearance of this device
        @Environment(\.colorScheme) var colorScheme
        
        /// Observed Object that contains all settings of the app of this device
        @ObservedObject var settings = NewSettings.shared

        /// Presentation mode
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
            ZStack {
                VStack(spacing: 0) {
                    
                    // Sheet bar
                    SheetBar()
                    
                    Spacer()
                    
                    // Image
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(image.size, contentMode: .fit)
                        .overlay(
                            Rectangle()
                                .stroke(settings.properties.style.strokeColor(colorScheme), lineWidth: 3)
                        )
                        .contextMenu {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    ActivityView.shared.shareImage(image, title: personName.formatted)
                                }
                            }) {
                                Text("Bild speichern")
                                Image(systemName: "tray.and.arrow.down")
                            }
                            Button(action: {}) {
                                Text("Abbrechen")
                                Image(systemName: "xmark.octagon")
                            }
                        }
                    
                    Spacer()
                }
            }.background(colorScheme.backgroundColor)
        }
    }
}

// Extension of Array to filter and sort it for person list
extension Array where Element == NewFine {
    
    /// Filtered and sorted for person list
    fileprivate func sortedForList(of personId: NewPerson.ID, with reasonList: [ReasonTemplate]?) -> [Element] {
        filter {
            $0.assoiatedPersonId == personId
        }.sorted {
            $0.fineReason.reason(with: reasonList).localizedUppercase
        }
    }
}
