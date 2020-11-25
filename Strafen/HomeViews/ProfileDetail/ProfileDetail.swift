//
//  ProfileDetail.swift
//  Strafen
//
//  Created by Steven on 12.07.20.
//

import SwiftUI

/// Detail View of loggedIn person
struct ProfileDetail: View {
    
    ///Dismiss handler
    @Binding var dismissHandler: DismissHandler
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = NewSettings.shared
    
    /// Fine List Data
    @ObservedObject var fineListData = NewListData.fine
    
    /// Id of selected row for large design
    @State var selectedForLargeDesign: UUID? = nil
    
    /// Person image
    @State var image: UIImage? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                
                // Background color
                colorScheme.backgroundColor
                
                VStack(spacing: 10) {
                    
                    // Image and edit button
                    ImageEditButton(image: $image)
                    
                    // Name
                    HStack {
                        Text((settings.properties.person?.name ?? .unknown).formatted)
                            .configurate(size: 35)
                            .padding(.horizontal, 15)
                            .lineLimit(1)
                        Spacer()
                    }
                    
                    // Payed and unpayed Display
                    HStack(spacing: 0) {
                        Spacer()
                        
                        // Payed Display
                        AmountDisplay(displayType: .payed)
                        
                        Spacer()
                        
                        // Unpayed Display
                        AmountDisplay(displayType: .unpayed)
                        
                        Spacer()
                     }
                    
                    // Total Display
                    HStack(spacing: 0) {
                        Spacer()
                        AmountDisplay(displayType: .total)
                        Spacer()
                    }
                    
                    // Underlines
                    VStack(spacing: 5) {
                        
                        // Top Underline
                        HStack {
                            Rectangle()
                                .frame(width: 300, height: 2)
                                .border(settings.properties.style == .default ? Color.custom.darkGreen : (colorScheme == .dark ? Color.plain.lightGray : Color.plain.darkGray), width: 1)
                            Spacer()
                        }
                        
                        // Bottom Underline
                        HStack {
                            Rectangle()
                                .frame(width: 275, height: 2)
                                .border(settings.properties.style == .default ? Color.custom.darkGreen : (colorScheme == .dark ? Color.plain.lightGray : Color.plain.darkGray), width: 1)
                            Spacer()
                        }
                        
                    }
                    
                    if let personId = settings.properties.person?.id, let fineList = fineListData.list {
                        
                        // Empty List Text
                        if fineList.isEmpty({ $0.assoiatedPersonId == personId }) {
                         Text("Du hast keine Strafen.")
                             .configurate(size: 25)
                             .padding(.horizontal, 15)
                             .padding(.top, 20)
                        }
                        
                        // Fine list
                        ScrollView {
                            LazyVStack(spacing: 15) {
                                ForEach(fineList.sortedForList(of: personId)) { fine in
                                    FineListRow(of: fine, selectedForLargeDesign: $selectedForLargeDesign, withOpenUrl: true, dismissHandler: $dismissHandler)
                                }
                            }.padding(.bottom, 20)
                                .padding(.top, 5)
                        }
                        
                    } else {
                        Text("No available view")
                    }
                    
                    Spacer()
                }.padding(.top, 40)
                
            }.edgesIgnoringSafeArea(.all)
                .hideNavigationBarTitle()
            //        }.onAppear {
            //            ImageData.shared.fetch(of: settings.person!.id) { image in TODO
            //                self.image = image
            //            }
        }
    }
    
    /// View with image and image edit button of signed in person
    struct ImageEditButton: View {
        
        /// Person image
        @Binding var image: UIImage?
        
        /// Observed Object that contains all settings of the app of this device
        @ObservedObject var settings = NewSettings.shared
        
        /// Color scheme to get appearance of this device
        @Environment(\.colorScheme) var colorScheme
        
        /// True if image detail is showed
        @State var showImageDetail = false
        
        /// Indicate if image picker is shown
        @State var showImagePicker = false
        
        /// Size of the image
        let imageSize = CGSize(square: 100)
        
        var body: some View {
            HStack(spacing: 0) {
                
                // Image
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(image.size, contentMode: .fill)
                        .frame(size: imageSize)
                        .clipShape(Circle())
                        .toggleOnTapGesture($showImageDetail)
                        .overlay(Circle().stroke(settings.properties.style.strokeColor(colorScheme), lineWidth: settings.properties.style.lineWidth).frame(size: imageSize))
                        .sheet(isPresented: $showImageDetail) {
                            PersonDetail.ImageDetail(image: image, personName: settings.properties.person?.name ?? .unknown) // TODO improve image detail
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
                        .padding(.leading, 25)
                }
                
                Spacer()
                
                // Edit button
                ZStack {

                    // Ouline
                    Outline()

                    // Text
                    Text("Bearbeiten")
                        .configurate(size: 20)
                        .lineLimit(1)

                }.frame(width: 150, height: 35)
                    .toggleOnTapGesture($showImagePicker)
                    .sheet(isPresented: self.$showImagePicker) {
                        ImagePicker($image) { image, isFirstImage in
//                            let changeItem = PersonImageChange(changeType: isFirstImage ? .add : .update, image: image, personId: settings.person!.id)
//                            Changer.shared.change(changeItem) {} failedHandler: {} TODO
                        }
                    }
                
            }.frame(height: imageSize.height)
                .padding(.horizontal, 30)
        }
    }
    
    /// Displayes amout of payed / unpayed or total fines
    struct AmountDisplay: View {
        
        /// Types of this display
        enum DisplayType {
            
            /// Payed
            case payed
            
            /// Unpayed
            case unpayed
            
            /// Total
            case total
            
            /// Text
            var text: String {
                switch self {
                case .payed:
                    return "Bezahlt"
                case .unpayed:
                    return "Ausstehend"
                case .total:
                    return "Gesamt"
                }
            }
            
            /// Color
            var color: Color {
                switch self {
                case .payed:
                    return Color.custom.lightGreen
                case .unpayed:
                    return Color.custom.red
                case .total:
                    return Color.custom.blue
                }
            }
            
            /// Amount sum
            func amountSum(with fineList: [NewFine]?) -> Amount? {
                guard let personId = NewSettings.shared.properties.person?.id else { return nil }
                guard let amountSum = fineList?.amountSum(of: personId) else { return nil }
                switch self {
                case .payed:
                    return amountSum.payed
                case .unpayed:
                    return amountSum.unpayed
                case .total:
                    return amountSum.total
                }
            }
        }
        
        /// Type of this display
        let displayType: DisplayType
        
        /// Fine List Data
        @ObservedObject var fineListData = NewListData.fine
        
        var body: some View {
            HStack(spacing: 0) {
                
                // Left of Divider
                ZStack {
                    
                    // Outline
                    Outline(.left)
                    
                    // Text
                    Text("\(displayType.text):")
                        .configurate(size: 16)
                        .lineLimit(1)
                        .padding(.horizontal, 2)
                    
                }.frame(width: 100, height: 35)
                
                // Right of the Divider
                ZStack {
                    
                    // Outline
                    Outline(.right)
                        .fillColor(displayType.color)
                    
                    // Amount
                    Text(describing: displayType.amountSum(with: fineListData.list) ?? .zero)
                        .foregroundColor(plain: displayType.color)
                        .font(.text(16))
                        .lineLimit(1)
                        .padding(.horizontal, 2)
                    
                }.frame(width: 75, height: 35)
            }
        }
    }
}

// Extension of Array to filter and sort it for profile detail fine list
extension Array where Element == NewFine {
    
    /// Filtered and sorted for profile detail fine list
    fileprivate func sortedForList(of personId: UUID) -> [Element] {
        filter {
            $0.assoiatedPersonId == personId
        }.sorted(by: \.fineReason.reason.localizedUppercase)
    }
}
