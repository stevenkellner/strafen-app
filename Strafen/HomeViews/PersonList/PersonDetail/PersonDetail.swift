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
    let person: Person
    
    ///Dismiss handler
    @Binding var dismissHandler: DismissHandler
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Fine List Data
    @ObservedObject var fineListData = ListData.fine
    
    /// Reason List Data
    @ObservedObject var reasonListData = ListData.reason
    
    /// Id of selected row for large design
    @State var selectedForLargeDesign: Fine.ID? = nil
    
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
                PersonImage(image: $image, person: person)
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
                            if settings.person?.isCashier ?? false {
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
                VStack(spacing: 0) {

                    // Bar to wipe sheet down
                    SheetBar()

                    // Content
                    AddNewFine(with: person.id)
                        .padding(.bottom, 15)

                }
            }
            
        }.edgesIgnoringSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .setDismissHandler($dismissHandler)
            .setScreenSize
            .onAppear {
                guard let clubId = settings.person?.clubProperties.id else { return }
                ImageStorage.shared.getImage(.personImage(clubId: clubId, personId: person.id), size: .thumbBig) { image in
                    self.image = image
                }
            }
    }
    
    /// Image View for Person Detail
    struct PersonImage: View {
        
        /// Image of the person
        @Binding var image: UIImage?
        
        /// Person
        let person: Person

        /// Color scheme to get appearance of this device
        @Environment(\.colorScheme) var colorScheme
        
        /// Observed Object that contains all settings of the app of this device
        @ObservedObject var settings = Settings.shared
        
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
                        .overlay(Circle().stroke(settings.style.strokeColor(colorScheme), lineWidth: settings.style.lineWidth).frame(size: imageSize))
                        .sheet(isPresented: $showImageDetail) {
                            ImageDetail(image: image, person: person)
                        }
                } else {
                    Image(systemName: "person")
                        .resizable()
                        .font(.system(size: imageSize.height * 0.45, weight: .thin))
                        .frame(size: imageSize * 0.45)
                        .scaledToFit()
                        .offset(y: -imageSize.height * 0.03)
                        .foregroundColor(settings.style.strokeColor(colorScheme))
                        .overlay(Circle().stroke(settings.style.strokeColor(colorScheme), lineWidth: settings.style.lineWidth).frame(size: imageSize * 0.75))
                }
            }
        }
    }
    
    /// Detail of the Image
    struct ImageDetail: View {
        
        /// Image
        @State var image: UIImage
        
        /// Person
        let person: Person

        /// Color scheme to get appearance of this device
        @Environment(\.colorScheme) var colorScheme
        
        /// Observed Object that contains all settings of the app of this device
        @ObservedObject var settings = Settings.shared

        /// Presentation mode
        @Environment(\.presentationMode) var presentationMode
        
        /// Image download progress
        @State var downloadProgress: Double? = nil
        
        /// Indicates if an error occured
        @State var errorOccured = false
        
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
                                .stroke(settings.style.strokeColor(colorScheme), lineWidth: 3)
                        )
                        .contextMenu {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    ActivityView.shared.shareImage(image, title: person.name.formatted)
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
                    
                    // Download progress
                    if let downloadProgress = downloadProgress {
                        VStack(spacing: 5) {
                            Text("Original Bild laden")
                                .configurate(size: 15)
                                .padding(.horizontal, 20)
                                .lineLimit(1)
                            ProgressView(value: downloadProgress)
                                .progressViewStyle(LinearProgressViewStyle())
                                .frame(width: UIScreen.main.bounds.width * 0.95)
                        }
                    } else if errorOccured {
                        Text("Fehlen beim Laden")
                            .configurate(size: 15)
                            .padding(.horizontal, 20)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                }
            }.background(colorScheme.backgroundColor)
                .onAppear {
                    errorOccured = false
                    guard let clubId = Settings.shared.person?.clubProperties.id else { return }
                    ImageStorage.shared.getImage(.personImage(clubId: clubId, personId: person.id), size: .original) { image in
                        downloadProgress = nil
                        if let image = image {
                            self.image = image
                        } else {
                            errorOccured = true
                        }
                    } progressChangeHandler: { progress in
                        downloadProgress = progress
                    }
                }
        }
    }
}

// Extension of Array to filter and sort it for person list
extension Array where Element == Fine {
    
    /// Filtered and sorted for person list
    fileprivate func sortedForList(of personId: Person.ID, with reasonList: [ReasonTemplate]?) -> [Element] {
        filter {
            $0.assoiatedPersonId == personId
        }.sorted {
            $0.fineReason.reason(with: reasonList).localizedUppercase
        }
    }
}
