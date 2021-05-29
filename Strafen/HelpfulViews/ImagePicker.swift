//
//  ImagePicker.swift
//  Strafen
//
//  Created by Steven on 29.05.21.
//

import SwiftUI

/// Pickes an image from photo library
struct ImagePicker: UIViewControllerRepresentable {

    /// Presentation Mode
    @Environment(\.presentationMode) var presentationMode

    /// Selected Image
    @Binding var image: UIImage?

    /// Handler executed after image was selected
    ///
    /// - first Parameter: selected image
    /// - second Parameter: indicates whether the binding image wasn't nil before selection
    let completionHandler: ((UIImage, Bool) -> Void)?

    /// Init with image binding and completion handler
    /// - Parameters:
    ///   - image: binding of image
    ///   - completionHandler: handler executed after image was selected
    ///
    ///      - first Parameter: selected image
    ///      - second Parameter: indicates whether the binding image wasn't nil before selection
    init(_ image: Binding<UIImage?>, completionHandler: ((UIImage, Bool) -> Void)? = nil) {
        self._image = image
        self.completionHandler = completionHandler
    }

    /// Image Picker Coordinator
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

        /// Image picker
        let parent: ImagePicker

        /// Init with image picker parent
        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                let isFirstImage = parent.image == nil
                parent.image = uiImage
                parent.completionHandler?(uiImage, isFirstImage)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}
}
