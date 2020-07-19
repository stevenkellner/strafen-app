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
    @Binding var dismissHandler: (() -> ())?
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Indicates if edit sheet is shown
    @State var isEditSheetPresented = false
    
    /// Indicates if addNewFine sheet is shown
    @State var isAddNewFineSheetShown = false
    
    /// Fine List Data
    @ObservedObject var fineListData = ListData.fine
    
    /// Person image
    @State var image: UIImage?
    
    var body: some View {
        ZStack {
            
            // Background color
            colorScheme.backgroundColor
            
            // Back and edit button
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    
                    // Back Button
                    Text("Zurück")
                        .foregroundColor(.textColor)
                        .font(.text(25))
                        .padding(.leading, 10)
                        .padding(.top, 35)
                        .onTapGesture {
                            presentationMode.wrappedValue.dismiss()
                        }
                    Spacer()
                    
                    // EditButton
                    if settings.person!.isCashier {
                        Text("Bearbeiten")
                            .foregroundColor(.textColor)
                            .font(.text(25))
                            .padding(.trailing, 10)
                            .padding(.top, 35)
                            .onTapGesture {
                                isEditSheetPresented = true
                            }
                            .sheet(isPresented: $isEditSheetPresented) {
                                PersonEditor(person: person)
                            }
                    }
                }
                Spacer()
            }
            
            // Person info and fine list
            VStack(spacing: 0) {
                
                // Image
                PersonImage(image: $image)
                    .padding(.vertical, image == nil ? 20 : 10)
                
                // Name
                Text(person.personName.formatted)
                    .foregroundColor(.textColor)
                    .font(.text(35))
                    .lineLimit(1)
                    .padding(.horizontal, 25)
                
                // Amount Display
                AmountDisplay(personId: person.id)
                    .padding(.top, 15)
                
                // Top Underline
                HStack {
                    Rectangle()
                        .frame(width: 300, height: 2)
                        .border(settings.style == .default ? Color.custom.darkGreen : (colorScheme == .dark ? Color.plain.lightGray : Color.plain.darkGray), width: 1)
                    Spacer()
                }.padding(.top, 10)
                
                // Bottom Underline
                HStack {
                    Rectangle()
                        .frame(width: 275, height: 2)
                        .border(settings.style == .default ? Color.custom.darkGreen : (colorScheme == .dark ? Color.plain.lightGray : Color.plain.darkGray), width: 1)
                    Spacer()
                }.padding(.top, 5)
                
                // Fine List
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 15) {
                        ForEach(fineListData.list!.filter({ $0.personId == person.id }).sorted(by: \.fineReason.reason.localizedUppercase)) { fine in
                            NavigationLink(destination: PersonFineDetail(personName: person.personName, fine: fine, dismissHandler: $dismissHandler)) {
                                PersonDetailRow(fine: fine)
                            }.buttonStyle(PlainButtonStyle())
                        }
                    }.padding(.bottom, 20)
                        .padding(.top, 5)
                }.padding(.top, 10)
                
                Spacer()
            }.padding(.top, 60)
            
            // Add New fine button
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
                                isAddNewFineSheetShown = true
                            }
                            .sheet(isPresented: $isAddNewFineSheetShown) {
                                AddNewFine(personId: person.id)
                            }
                    }
                }
            }
            
        }.edgesIgnoringSafeArea(.all)
            .navigationTitle("Title")
            .navigationBarHidden(true)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                dismissHandler = {
                    presentationMode.wrappedValue.dismiss()
                }
                ImageData.shared.fetch(of: person.id) { image in
                    self.image = image
                }
            }
    }
    
    /// Image View for Person Detail
    struct PersonImage: View {
        
        /// Image of the person
        @Binding var image: UIImage?

        /// Color scheme to get appearance of this device
        @Environment(\.colorScheme) var colorScheme
        
        /// Observed Object that contains all settings of the app of this device
        @ObservedObject var settings = Settings.shared
        
        /// True if image detail is showed
        @State var showImageDetail = false
        
        var body: some View {
            VStack(spacing: 0) {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(image.size, contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(settings.style.strokeColor(colorScheme), lineWidth: 2)
                                .frame(width: 100, height: 100)
                        )
                        .onTapGesture {
                            showImageDetail = true
                        }
                        .sheet(isPresented: $showImageDetail) {
                            ImageDetail(image: image)
                        }
                } else {
                    Image(systemName: "person")
                        .resizable()
                        .font(.system(size: 45, weight: .thin))
                        .frame(width: 45, height: 45)
                        .scaledToFit()
                        .offset(y: -3)
                        .foregroundColor(settings.style.strokeColor(colorScheme))
                        .overlay(
                            Circle()
                                .stroke(settings.style.strokeColor(colorScheme), lineWidth: settings.style == .default ? 3 : 2)
                                .frame(width: 75, height: 75)
                        )
                }
            }
        }
    }
    
    /// Detail of the Image
    struct ImageDetail: View {
        
        /// Image
        let image: UIImage

        /// Color scheme to get appearance of this device
        @Environment(\.colorScheme) var colorScheme
        
        /// Observed Object that contains all settings of the app of this device
        @ObservedObject var settings = Settings.shared

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
                                .stroke(settings.style.strokeColor(colorScheme), lineWidth: 3)
                        )
                        .contextMenu {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    ActivityView.shared.shareImage(image)
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

/// Row of PersonDetail that shows details of one fine of this person
struct PersonDetailRow: View {
    
    /// Contains details of the fine
    let fine: Fine
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    var body: some View {
        HStack(spacing: 0) {
            
            // Left of the divider
            ZStack {
                
                // Outline
                Outline(.left)
                
                // Inside
                HStack(spacing: 0) {
                    Text(fine.fineReason.reason)
                        .foregroundColor(.textColor)
                        .font(.text(20))
                        .padding(.leading, 15)
                        .lineLimit(1)
                    Spacer()
                }
                
            }.frame(width: 245)
            
            // Right of the divider
            ZStack {
                
                // Outline
                Outline(.right)
                    .fillColor(fine.payed.boolValue ? Color.custom.lightGreen : fine.fineReason.importance.color)
                
                // Inside
                Text(String(describing: fine.fineReason.amount * fine.number))
                    .foregroundColor(settings.style == .default ? .textColor : fine.payed.boolValue ? Color.custom.lightGreen : fine.fineReason.importance.color)
                    .font(.text(20))
                    .lineLimit(1)
                
            }.frame(width: 100)
            
        }.frame(width: 345, height: 50)
            .padding(.horizontal, 1)
    }
}

/*#if DEBUG
struct PersonDetail_Previews: PreviewProvider {
    static var previews: some View {
        
        let phoneType = "iPhone 11"
        let colorScheme: ColorScheme = .light
        
        return Group {
            VStack(spacing: 0) {
                PersonDetail(person: Person(firstName: "Steven", lastName: "Kellner", id: UUID()), dismissHandler: .constant(nil), settings: .constant(Settings(style: .default, isCashier: false)))
                TabBar(dismissHandler: .constant(nil))
            }.previewDevice(.init(rawValue: phoneType))
                .previewDisplayName(phoneType)
                .edgesIgnoringSafeArea(.all)
                .environment(\.colorScheme, colorScheme)
            VStack(spacing: 0) {
                PersonDetail(person: Person(firstName: "Steven", lastName: "Kellner", id: UUID()), dismissHandler: .constant(nil), settings: .constant(Settings(style: .default, isCashier: true)))
                TabBar(dismissHandler: .constant(nil))
            }.previewDevice(.init(rawValue: phoneType))
                .previewDisplayName(phoneType)
                .edgesIgnoringSafeArea(.all)
                .environment(\.colorScheme, colorScheme)
            VStack(spacing: 0) {
                PersonDetail(person: Person(firstName: "Steven", lastName: "Kellner", id: UUID()), dismissHandler: .constant(nil), settings: .constant(Settings(style: .plain, isCashier: false)))
                TabBar(dismissHandler: .constant(nil))
            }.previewDevice(.init(rawValue: phoneType))
                .previewDisplayName(phoneType)
                .edgesIgnoringSafeArea(.all)
                .environment(\.colorScheme, colorScheme)
            VStack(spacing: 0) {
                PersonDetail(person: Person(firstName: "Steven", lastName: "Kellner", id: UUID()), dismissHandler: .constant(nil), settings: .constant(Settings(style: .plain, isCashier: true)))
                TabBar(dismissHandler: .constant(nil))
            }.previewDevice(.init(rawValue: phoneType))
                .previewDisplayName(phoneType)
                .edgesIgnoringSafeArea(.all)
                .environment(\.colorScheme, colorScheme)
        }
    }
}
#endif*/
