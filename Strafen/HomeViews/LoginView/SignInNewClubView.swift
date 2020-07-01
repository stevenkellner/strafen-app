//
//  SignInNewClubView.swift
//  Strafen
//
//  Created by Steven on 01.07.20.
//

import SwiftUI
import AVFoundation

struct SignInNewClubView: View {
    
    /// Generated club id
    let clubId = UUID()
    
    /// Selected image
    @State var image: UIImage?
    
    /// Club name
    @State var clubName = ""
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    var body: some View {
        ZStack {
            
            // Back Button
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("Zurück")
                        .font(.text(25))
                        .foregroundColor(.textColor)
                        .padding(.leading, 15)
                        .onTapGesture {
                            presentationMode.wrappedValue.dismiss()
                        }
                    Spacer()
                }.padding(.top, 30)
                Spacer()
            }
            
            VStack(spacing: 0) {
                
                // Bar to wipe sheet down
                SheetBar()
                
                // Header
                Header("Neuer Verein")
                    .padding(.top, 30)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        // Image
                        ImageSelector(image: $image).padding(.top, 35)
                        
                        // Club name
                        VStack(spacing: 0) {
                            
                            // Title
                            HStack(spacing: 0) {
                                Text("Vereinsname:")
                                    .foregroundColor(Color.textColor)
                                    .font(.text(20))
                                    .padding(.leading, 10)
                                Spacer()
                            }
                            
                            // Text Field
                            CustomSecureField(text: $clubName, placeholder: "Vereinsname")
                                .frame(width: 345, height: 50)
                                .padding(.top, 5)
                        }.padding(.top, 15)
                        
                        // Club id
                        VStack(spacing: 0) {
                            
                            // Text
                            Text("Dein Vereinscode:")
                                .foregroundColor(.textColor)
                                .font(.text(25))
                            
                            // Id
                            HStack(spacing: 0) {
                                Spacer()
                                
                                // Id
                                Text(clubId.uuidString)
                                    .foregroundColor(.orange)
                                    .font(.text(20))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 15)
                                
                                Spacer()
                                
                                // Copy Button
                                Button {
                                    UIPasteboard.general.string = clubId.uuidString
                                    AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, nil)
                                    
                                } label: {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 30, weight: .light))
                                        .foregroundColor(.textColor)
                                }
                                
                                Spacer()
                            }.padding(.top, 10)
                            
                            // Text
                            Text("Benutze ihn um andere Spieler hinzuzufügen.")
                                .foregroundColor(.textColor)
                                .font(.text(20))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 15)
                                .padding(.top, 10)
                            
                        }.padding(.top, 35)
                        
                        Spacer()
                    }.padding(.vertical, 10)
                }.padding(.vertical, 10)
                
                // Confirm Button
                ConfirmButton("Erstellen") {
                    
                }.padding(.bottom, 50)

            }
        }.background(colorScheme.backgroundColor)
            .navigationTitle("title")
            .navigationBarHidden(true)
    }
}

#if DEBUG
struct SignInNewClubView_Previews: PreviewProvider {
    static var previews: some View {
        SignInNewClubView()
            .edgesIgnoringSafeArea(.all)
    }
}
#endif
