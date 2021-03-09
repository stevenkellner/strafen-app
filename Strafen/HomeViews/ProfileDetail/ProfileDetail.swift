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
    @ObservedObject var settings = Settings.shared
    
    /// Fine List Data
    @ObservedObject var fineListData = ListData.fine
    
    /// Reason List Data
    @ObservedObject var reasonListData = ListData.reason
    
    /// Id of selected row for large design
    @State var selectedForLargeDesign: Fine.ID? = nil
    
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
                        Text((settings.person?.name ?? .unknown).formatted)
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
                    Underlines()
                    
                    if let personId = settings.person?.id, let fineList = fineListData.list {
                        
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
                                ForEach(fineList.sortedForList(of: personId, with: reasonListData.list)) { fine in
                                    FineListRow(of: fine, selectedForLargeDesign: $selectedForLargeDesign, withOpenUrl: true, dismissHandler: $dismissHandler)
                                }
                            }.padding(.bottom, 10)
                                .padding(.top, 5)
                        }.padding(.top, 10)
                        
                        // Payment button
                        PaymentButton(personId: personId)
                        
                    } else {
                        Text("No available view")
                    }
                    
                    Spacer(minLength: 0)
                }.padding(.top, 40)
                
            }.edgesIgnoringSafeArea(.all)
                .hideNavigationBarTitle()
                .onAppear {
                    guard let person = settings.person else { return }
                    ImageStorage.shared.getImage(.personImage(clubId: person.clubProperties.id, personId: person.id), size: .thumbBig) { image in
                        self.image = image
                    }
                }
        }
    }
    
    /// View with image and image edit button of signed in person
    struct ImageEditButton: View {
        
        /// Person image
        @Binding var image: UIImage?
        
        /// Observed Object that contains all settings of the app of this device
        @ObservedObject var settings = Settings.shared
        
        /// Indicate if image picker is shown
        @State var showImagePicker = false
        
        var body: some View {
            HStack(spacing: 0) {
                
                // Image
                if let person = settings.person?.personProperties {
                    PersonDetail.PersonImage(image: $image, person: person)
                        .padding(.leading, image == nil ? 25 : 0)
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
                            guard let person = settings.person else { return }
                            ImageStorage.shared.store(image, of: .personImage(clubId: person.clubProperties.id, personId: person.id)) { _ in }
                        }
                    }
                
            }.frame(height: 100)
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
            func amountSum(with fineList: [Fine]?, reasonList: [ReasonTemplate]?) -> Amount? {
                guard let personId = Settings.shared.person?.id else { return nil }
                guard let amountSum = fineList?.amountSum(of: personId, with: reasonList) else { return nil }
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
        @ObservedObject var fineListData = ListData.fine
        
        /// Reason List Data
        @ObservedObject var reasonListData = ListData.reason
        
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
                    Text(describing: displayType.amountSum(with: fineListData.list, reasonList: reasonListData.list) ?? .zero)
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
extension Array where Element == Fine {
    
    /// Filtered and sorted for profile detail fine list
    fileprivate func sortedForList(of personId: Person.ID, with reasonList: [ReasonTemplate]?) -> [Element] {
        filter {
            $0.assoiatedPersonId == personId
        }.sorted(byValue: { fine in
            fine.fineReason.reason(with: reasonList).localizedUppercase
        })
    }
}
