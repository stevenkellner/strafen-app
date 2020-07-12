//
//  ImageSelector.swift
//  Strafen
//
//  Created by Steven on 01.07.20.
//

import SwiftUI

/// Image and Placeholder with image picker
struct ImageSelector: View {
    
    /// Selected Image
    @Binding var image: UIImage?
    
    /// Indicate if image picker is shown
    @State var showImagePicker = false
    
    var body: some View {
        HStack(spacing: 0) {
            
            // image
            VStack(spacing: 0) {
                
                // Image
                if let inputImage = image {
                    Image(uiImage: inputImage)
                        .resizable()
                        .aspectRatio(inputImage.size, contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.custom.gray, lineWidth: 4)
                                .frame(width: 150, height: 150)
                        )
                        .frame(width: 150, height: 150)
                    
                // No image
                } else {
                    Image(systemName: "person")
                        .resizable()
                        .font(.system(size: 90, weight: .thin))
                        .frame(width: 90, height: 90)
                        .scaledToFit()
                        .offset(y: -6)
                        .foregroundColor(Color.custom.gray)
                        .overlay(
                            Circle()
                                .stroke(Color.custom.gray, lineWidth: 4)
                                .frame(width: 150, height: 150)
                        )
                        .frame(width: 150, height: 150)
                }
                
                // Change image text
                Text("Bild ändern")
                    .foregroundColor(Color.custom.gray)
                    .font(.custom("Futura-Medium", size: 20))
                    .lineLimit(1)
                    .padding(.top, 5)
                
            }.onTapGesture {
                    showImagePicker = true
                }
                .sheet(isPresented: self.$showImagePicker) {
                    ImagePicker($image)
                }
            
            // remove image button
            if image != nil {
                Image(systemName: "xmark.circle")
                    .foregroundColor(Color.custom.red)
                    .font(.system(size: 50, weight: .light))
                    .padding(.leading, 15)
                    .onTapGesture {
                        withAnimation {
                            image = nil
                        }
                    }
            }
            
        }
    }
}

/// Pickes an image from photo library
struct ImagePicker: UIViewControllerRepresentable {
    
    /// Presentation Mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Selected Image
    @Binding var image: UIImage?
    
    /// Completion handler
    let completionHandler: ((UIImage) -> ())?
    
    init(_ image: Binding<UIImage?>, completionHandler: ((UIImage) -> ())? = nil) {
        self._image = image
        self.completionHandler = completionHandler
    }
    
    /// Image Oicker Coordinator
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        /// Image picker
        let parent: ImagePicker
        
        /// Completion handler
        let completionHandler: ((UIImage) -> ())?
        
        init(_ parent: ImagePicker, completionHandler: ((UIImage) -> ())?) {
            self.parent = parent
            self.completionHandler = completionHandler
        }
        
        /// delegation function
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                if let completionHandler = completionHandler { completionHandler(uiImage) }
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    /// make coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(self, completionHandler: completionHandler)
    }
    
    /// make controller
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    /// update controller
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}
}

