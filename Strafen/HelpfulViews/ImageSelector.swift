//
//  ImageSelector.swift
//  Strafen
//
//  Created by Steven on 07.06.21.
//

import SwiftUI

/// Image and Placeholder with image picker
struct ImageSelector: View {

    /// Selected Image
    @Binding var image: UIImage?

    /// Indicates image upload progress
    @Binding var uploadProgress: Double?

    /// Completion handler
    let completionHandler: (() -> Void)?

    /// Init with image and upload progress binding
    init(image: Binding<UIImage?>, uploadProgress: Binding<Double?> = .constant(nil), onCompletion completionHandler: (() -> Void)? = nil) {
        _image = image
        _uploadProgress = uploadProgress
        self.completionHandler = completionHandler
    }

    /// Indicate if image picker is shown
    @State var showImagePicker = false

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {

                // Image
                VStack(spacing: 0) {

                    // Image
                    if let inputImage = image {
                        Image(uiImage: inputImage)
                            .resizable()
                            .aspectRatio(inputImage.size, contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.textColor, lineWidth: 2).frame(size: geometry.size))
                            .frame(size: geometry.size)

                    // No image
                    } else {
                        Image(systemName: "person")
                            .resizable()
                            .font(.system(size: geometry.size.width * 0.6, weight: .thin))
                            .frame(size: geometry.size * 0.6)
                            .scaledToFit()
                            .offset(y: -6)
                            .foregroundColor(.textColor)
                            .overlay(Circle().stroke(Color.textColor, lineWidth: 2).frame(size: geometry.size))
                            .frame(size: geometry.size)
                    }

                    // Change image text
                    if uploadProgress == nil {
                        Text("Bild ändern")
                            .foregroundColor(.textColor)
                            .font(.system(size: geometry.size.width / 7.5, weight: .thin))
                            .frame(width: geometry.size.width)
                            .lineLimit(1)
                            .padding(.top, 5)
                    }

                }.onTapGesture {
                        if uploadProgress == nil {
                            showImagePicker = true
                        }
                    }
                    .sheet(isPresented: self.$showImagePicker) {
                        ImagePicker($image) { _, _ in
                            completionHandler?()
                        }
                    }

                // Remove image button
                if image != nil && uploadProgress == nil {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.customRed)
                        .font(.system(size: geometry.size.width / 3, weight: .thin))
                        .padding(.leading, geometry.size.width / 10)
                        .onTapGesture {
                            withAnimation { image = nil }
                        }
                }
            }

        }
    }
}
