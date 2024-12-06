//
//  ImageUploadView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-20.
//

import PhotosUI
import SwiftUI

/**
 A view that allows the user to upload an image by either choosing from their photo library or taking a photo using the camera.
 It displays a placeholder image when no image is uploaded, and handles image selection and camera interaction.
 */
struct ImageUploadView: View {
    // MARK: - Properties

    /// The image to upload, bound to the parent view.
    @Binding var imageToUpload: UIImage?
    /// The selected photo item from PhotosPicker.
    @State private var selectedItem: PhotosPickerItem?
    /// State for toggling the PhotosPicker.
    @State private var showPicker: Bool = false
    /// State for toggling the Camera.
    @State private var showCamera: Bool = false
    /// State for showing the confirmation dialog.
    @State private var showDialog: Bool = false

    /// The placeholder image displayed when no image is selected.
    var placeholderImage: UIImage
    /// The width of the image frame.
    var width: CGFloat
    /// The height of the image frame.
    var height: CGFloat

    // MARK: - View Body

    var body: some View {
        VStack {
            // Tappable image that acts as a button to trigger dialog
            Button(action: {
                showDialog = true // Show the dialog for options
            }) {
                Image(uiImage: imageToUpload ?? placeholderImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .clipped() // Ensure the image fits the frame
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            .confirmationDialog("Choose an option", isPresented: $showDialog, titleVisibility: .visible) {
                // Option to pick an image from the photo library
                Button("Choose from Library") {
                    showPicker = true // Show PhotosPicker
                }

                // Option to take a photo using the camera
                Button("Take a Photo") {
                    showCamera = true // Show camera
                }

                // Cancel button to dismiss the dialog
                Button("Cancel", role: .cancel) {}
            }
        }
        .photosPicker(isPresented: $showPicker, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let newItem,
                   let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data)
                {
                    imageToUpload = image // Update image to upload
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(image: $imageToUpload).ignoresSafeArea() // Camera view for taking a photo
        }.ignoresSafeArea()
    }
}

// CameraView for handling camera input
/**
 A view for presenting the camera and capturing an image. It is presented full-screen and allows the user to take a photo.
 */
struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    // MARK: - Coordinator

    /**
     Coordinator for managing image capture and camera dismissal.
     */
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraView

        init(parent: CameraView) {
            self.parent = parent
        }

        /**
         Capture the photo when user selects it and assign the captured image.
         */
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage // Assign the captured image
            }
            picker.dismiss(animated: true)
        }

        /**
         Dismiss the camera when the user cancels.
         */
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }

    // MARK: - Methods

    /**
     Create and return a Coordinator to manage the camera interaction.
     */
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self) // Create a coordinator for managing image capture
    }

    /**
     Create and configure the UIImagePickerController to access the camera.
     */
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera // Set to camera mode
        picker.modalPresentationStyle = .overFullScreen // Full screen presentation
        return picker
    }

    func updateUIViewController(_: UIImagePickerController, context _: Context) {}
}

// Preview for testing
#Preview {
    ImageUploadView(imageToUpload: .constant(nil),
                    placeholderImage: UIImage(systemName: "photo")!,
                    width: 100,
                    height: 100)
}
