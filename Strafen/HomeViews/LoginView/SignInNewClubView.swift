//
//  SignInNewClubView.swift
//  Strafen
//
//  Created by Steven on 01.07.20.
//

import SwiftUI
import AVFoundation

struct SignInNewClubView: View {
    
    /// Contains first and last name of a person
    let personName: PersonName
    
    /// Contains all properties for the login
    let personLogin: PersonLogin
    
    /// Generated club id
    let clubId = UUID()
    
    /// Selected image
    @State var image: UIImage?
    
    /// Club name
    @State var clubName = ""
    
    /// True if empty String in club name field
    @State var isClubNameError = false
    
    /// Inidcate whether the error alert is shown
    @State var showErrorAlert = false
    
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
                            CustomTextField("Vereinsname", text: $clubName)
                                .frame(width: 345, height: 50)
                                .padding(.top, 5)
                            
                            // Error Text
                            if isClubNameError {
                                Text("Dieses Feld darf nicht leer sein!")
                                    .foregroundColor(Color.custom.red)
                                    .font(.text(20))
                                    .lineLimit(1)
                                    .padding(.horizontal, 15)
                                    .padding(.top, 5)
                            }
                            
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
                    isClubNameError = clubName == ""
                    if !isClubNameError {
                        let personId = UUID()
                        let club = NewClubChanger.Club(clubId: clubId, clubName: clubName, personId: personId, personName: personName, login: personLogin)
                        NewClubChanger.shared.createNewClub(club)
                        if let image = image {
                            ClubImageChanger.shared.changeImage(.add(image: image, clubId: clubId))
                        }
                        Settings.shared.person = Settings.CodableSettings.Person(id: personId, name: personName, clubId: clubId)
                    } else {
                        showErrorAlert = true
                    }
                }.padding(.bottom, 50)
                .alert(isPresented: $showErrorAlert) {
                    Alert(title: Text("Eingabefehler"), message: Text("Es gab ein Fehler in der Eingabe des Verseinsnamens."), dismissButton: .default(Text("Verstanden")))
                }

            }
        }.background(colorScheme.backgroundColor)
            .navigationTitle("title")
            .navigationBarHidden(true)
    }
}

#if DEBUG
struct SignInNewClubView_Previews: PreviewProvider {
    static var previews: some View {
        SignInNewClubView(personName: PersonName(firstName: "", lastName: ""), personLogin: PersonLoginEmail(email: "", password: ""))
            .edgesIgnoringSafeArea(.all)
    }
}
#endif
