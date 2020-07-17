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
    @Binding var dismissHandler: (() -> ())?
    
    /// Indicate if image picker is shown
    @State var showImagePicker = false
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Fine List Data
    @ObservedObject var fineListData = ListData.fine
    
    /// Person image
    @State var image: UIImage?
    
    var body: some View {
        NavigationView {
            ZStack {
                
                // Background color
                colorScheme.backgroundColor
                
                VStack(spacing: 0) {
                    
                    // Image and edit button
                    HStack(spacing: 0) {
                        
                        // Image
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(image.size, contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(settings.style.strokeColor(colorScheme), lineWidth: settings.style.lineWidth)
                                        .frame(width: 100, height: 100)
                                )
                                .padding(.leading, 30)
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
                                        .stroke(settings.style.strokeColor(colorScheme), lineWidth: 2)
                                        .frame(width: 75, height: 75)
                                )
                                .padding(.leading, 55)
                        }
                        
                        Spacer()
                        
                        // Edit button
                        ZStack {
                            
                            // Ouline
                            Outline()
                            
                            // Text
                            Text("Bearbeiten")
                                .foregroundColor(.textColor)
                                .font(.text(20))
                                .lineLimit(1)
                            
                        }.frame(width: 150, height: 35)
                            .padding(.trailing, 30)
                            .onTapGesture {
                                showImagePicker = true
                            }
                            .sheet(isPresented: self.$showImagePicker) {
                                ImagePicker($image) { image in
                                    // TODO save image
                                }
                            }
                        
                    }.frame(height: 100)
                        .padding(.top, 35)
                    
                    // Name
                    HStack {
                        Text(settings.person!.name.formatted)
                            .foregroundColor(.textColor)
                            .font(.text(35))
                            .padding(.horizontal, 15)
                            .lineLimit(1)
                        Spacer()
                    }.padding(.top, 10)
                    
                    // Payed and unpayed Display
                    HStack(spacing: 0) {
                        Spacer()
                        
                        // Payed Display
                        HStack(spacing: 0) {
                            
                            // Left of Divider
                            ZStack {
                               
                                // Outline
                                Outline(.left)
                               
                                // Text
                                Text("Bezahlt:")
                                    .foregroundColor(.textColor)
                                    .font(.text(16))
                                    .lineLimit(1)
                                    .padding(.horizontal, 2)
                               
                            }.frame(width: 100, height: 35)
                            
                            // Right of the Divider
                            ZStack {
                                
                                // Outline
                                Outline(.right)
                                    .fillColor(settings.style.fillColor(colorScheme, defaultStyle: Color.custom.lightGreen))
                                
                                // Amount
                                Text((fineListData.list?.payedAmountSum(of: settings.person!.id)).text)
                                    .foregroundColor(settings.style == .default ? .textColor : Color.custom.lightGreen)
                                    .font(.text(16))
                                    .lineLimit(1)
                                    .padding(.horizontal, 2)
                                
                            }.frame(width: 75, height: 35)
                        }
                        
                        Spacer()
                        
                        // Unpayed Display
                        HStack(spacing: 0) {
                            
                            // Left of Divider
                            ZStack {
                               
                                // Outline
                                Outline(.left)
                               
                                // Text
                                Text("Ausstehend:")
                                    .foregroundColor(.textColor)
                                    .font(.text(16))
                                    .lineLimit(1)
                                    .padding(.horizontal, 2)
                               
                            }.frame(width: 100, height: 35)
                            
                            // Right of the Divider
                            ZStack {
                                
                                // Outline
                                Outline(.right)
                                    .fillColor(settings.style.fillColor(colorScheme, defaultStyle: Color.custom.red))
                                
                                // Amount
                                Text((fineListData.list?.unpayedAmountSum(of: settings.person!.id)).text)
                                    .foregroundColor(settings.style == .default ? .textColor : Color.custom.red)
                                    .font(.text(16))
                                    .lineLimit(1)
                                    .padding(.horizontal, 2)
                                
                            }.frame(width: 75, height: 35)
                        }
                        
                        Spacer()
                    }.padding(.top, 10)
                    
                    // Total Display
                    HStack(spacing: 0) {
                        Spacer()
                        HStack(spacing: 0) {
                            
                            // Left of Divider
                            ZStack {
                               
                                // Outline
                                Outline(.left)
                               
                                // Text
                                Text("Gesamt:")
                                    .foregroundColor(.textColor)
                                    .font(.text(16))
                                    .lineLimit(1)
                                    .padding(.horizontal, 2)
                               
                            }.frame(width: 100, height: 35)
                            
                            // Right of the Divider
                            ZStack {
                                
                                // Outline
                                Outline(.right)
                                    .fillColor(settings.style.fillColor(colorScheme, defaultStyle: Color.custom.blue))
                                
                                // Amount
                                Text((fineListData.list?.totalAmountSum(of: settings.person!.id)).text)
                                    .foregroundColor(settings.style == .default ? .textColor : Color.custom.blue)
                                    .font(.text(16))
                                    .lineLimit(1)
                                    .padding(.horizontal, 2)
                                
                            }.frame(width: 75, height: 35)
                        }
                        Spacer()
                    }.padding(.top, 10)
                    
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
                    
                    // Fine list
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 15) {
                            ForEach(fineListData.list!.filter({ $0.personId == settings.person!.id }).sorted(by: \.wrappedReason.localizedUppercase)) { fine in
                                NavigationLink(destination: PersonFineDetail(personName: settings.person!.name, fine: fine, dismissHandler: $dismissHandler)) {
                                    PersonDetailRow(fine: fine)
                                }.buttonStyle(PlainButtonStyle())
                            }
                        }.padding(.bottom, 20)
                            .padding(.top, 5)
                    }.padding(.top, 10)
                    
                    Spacer()
                }
            }.edgesIgnoringSafeArea(.all)
                .navigationBarTitle("Title")
                .navigationBarHidden(true)
        }.onAppear {
            ImageData.shared.fetch(of: settings.person!.id) { image in
                self.image = image
            }
        }
    }
}
