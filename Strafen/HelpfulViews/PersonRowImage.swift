//
//  PersonRowImage.swift
//  Strafen
//
//  Created by Steven on 04.07.20.
//

import SwiftUI

/// Image of a person of person row
struct PersonRowImage: View {
    
    /// Image of the person
    @Binding var image: UIImage?
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = NewSettings.shared
    
    var body: some View {
        VStack(spacing: 0) {
            if let image = image {
                
                // Image
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(image.size, contentMode: .fill)
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(settings.properties.style.strokeColor(colorScheme), lineWidth: settings.properties.style.lineWidth)
                            .frame(width: 36, height: 36)
                    )
            } else {
                Spacer()
                HStack(spacing: 0) {
                    Spacer()
                    
                    // No image
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .scaledToFit()
                        .foregroundColor(settings.properties.style.strokeColor(colorScheme))
                        .padding(.horizontal, 2)
                    
                    Spacer()
                }
                Spacer()
            }
        }.frame(width: 36, height: 36)
            .padding(.horizontal, 13)
    }
}
