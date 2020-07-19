//
//  NoteDetail.swift
//  Strafen
//
//  Created by Steven on 19.07.20.
//

import SwiftUI

/// Detail View of a note
struct NoteDetail: View {
    
    /// Note of this detail view
    let note: Note
    
    ///Dismiss handler
    @Binding var dismissHandler: (() -> ())?
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    var body: some View {
        ZStack {
            
            // Background color
            colorScheme.backgroundColor
            
            // Back and edit button
            BackAndEditButton {
                NoteEditor(noteToEdit: note)
            }
            
            // Content
            VStack(spacing: 0) {
                
                // Header
                Header(note.subject)
                    .padding(.top, 75)
                    .padding(.trailing, 22)
                    .lineLimit(2)
                
                // Date
                HStack(spacing: 0) {
                    Text("vom:")
                        .foregroundColor(.textColor)
                        .font(.text(20))
                        .padding(.leading, 10)
                    Text(note.date.formatted)
                        .foregroundColor(.textColor)
                        .font(.text(25))
                        .padding(.leading, 10)
                    Spacer()
                }.padding(.top, 30)
                
                // Message
                ScrollView {
                    Text(note.message)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.textColor)
                        .font(.text(25))
                        .lineLimit(nil)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                }.padding(.vertical, 10)
                
                Spacer()
            }
        }.edgesIgnoringSafeArea(.all)
            .navigationTitle("Title")
            .navigationBarHidden(true)
            .onAppear {
                dismissHandler = {
                    presentationMode.wrappedValue.dismiss()
                }
            }
    }
}

#if DEBUG
struct NoteDetail_Previews: PreviewProvider {
    static var previews: some View {
        NoteDetail(note: Note(id: UUID(), subject: "Subject aldkkbadfkj lklöjadn kljhakdbl öilkjadlj", date: Date().formattedDate, message: "Message lakkna asdlknj alkd lfdjalkn adlk jöaijfknadf ajdskjnf ajfdikland jadoif klajdsf nadnf hadks fnadfiu iua dnfakhdi nadh fkahdnakj fakjdhf adfan dkfaiuha kfdna kdha iuh adsn alduhfaiud fandf klahdiuh akdnf auhd iad kadlfnaldihf kaljdnf aiusdf adskfnasdnf asdfhjiouad fnad kfhaiu dhf adnf kandskfhaisdf landfkjd aofj adsnf,and ka fpiudah fkjnmna dkngauh askdnfkadn fkhaiudf kankfajn diuah aldkkbadfkj lklöjadn kljhakdbl öilkjadlj lakkna asdlknj alkd lfdjalkn adlk jöaijfknadf ajdskjnf ajfdikland jadoif klajdsf nadnf hadks fnadfiu iua dnfakhdi nadh fkahdnakj fakjdhf adfan dkfaiuha kfdna kdha iuh adsn alduhfaiud fandf klahdiuh akdnf auhd iad kadlfnaldihf kaljdnf aiusdf adskfnasdnf asdfhjiouad fnad kfhaiu dhf adnf kandskfhaisdf landfkjd aofj adsnf,and ka fpiudah fkjnmna dkngauh askdnfkadn fkhaiudf kankfajn diuah"), dismissHandler: .constant(nil))
            .previewDevice("iPhone 11")
    }
}
#endif
