//
//  PersonDetailImage.swift
//  Strafen
//
//  Created by Steven on 29.05.21.
//

import SwiftUI

/// Image View for Person Detail
struct PersonDetailImage: View {

    /// Image of the person
    @Binding var image: UIImage?

    /// Person
    let person: FirebasePerson

    /// Size of the image
    private let imageSize: CGSize = CGSize(width: 100, height: 100)

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
                    .overlay(Circle().stroke(Color.textColor, lineWidth: 2).frame(size: imageSize))
//                    .sheet(isPresented: $showImageDetail) {
//                        ImageDetail(image: image, person: person) TODO
//                    }
            } else {
                Image(systemName: "person")
                    .resizable()
                    .font(.system(size: imageSize.height * 0.45, weight: .thin))
                    .frame(size: imageSize * 0.45)
                    .scaledToFit()
                    .offset(y: -imageSize.height * 0.03)
                    .foregroundColor(.textColor)
                    .overlay(Circle().stroke(Color.textColor, lineWidth: 2).frame(size: imageSize * 0.75))
            }
        }.frame(size: imageSize)
    }
}
