//
//  ImageUploadView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-20.
//

import SwiftUI
import PhotosUI

struct ImageUploadView: View {
    @Binding var imageToUpload: UIImage? // Bind image to parent view
    @State private var selectedItem: PhotosPickerItem? // Selected item from PhotosPicker
    @State private var showPicker: Bool = false        // State for toggling PhotosPicker
    @State private var showCamera: Bool = false        // State for toggling Camera
    @State private var showDialog: Bool = false        // State for confirmation dialog
    
    var placeholderImage: UIImage           // Placeholder image when no image is uploaded
    var width: CGFloat                      // Width of the image frame
    var height: CGFloat                     // Height of the image frame
    
    var body: some View {
        VStack {
            // Tappable image that acts as a button
            Button(action: {
                showDialog = true // Show the dialog
            }) {
                Image(uiImage: imageToUpload ?? placeholderImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .clipped() // Clip to the frame size
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            .confirmationDialog("Choose an option", isPresented: $showDialog, titleVisibility: .visible) {
                // Option to pick from library
                Button("Choose from Library") {
                    showPicker = true // Show the PhotosPicker
                }
                
                // Option to use camera
                Button("Take a Photo") {
                    showCamera = true // Show the camera
                }
                
                // Cancel button
                Button("Cancel", role: .cancel) {}
            }
        }
        .photosPicker(isPresented: $showPicker, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) { _,newItem in
            Task {
                if let newItem = newItem,
                   let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    imageToUpload = image
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(image: $imageToUpload).ignoresSafeArea()
        }.ignoresSafeArea()
    }
    
}

// CameraView remains the same as in the previous implementation

// CameraView for handling camera input
struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraView
        
        init(parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera // Camera mode
        picker.modalPresentationStyle = .overFullScreen // Full-screen presentation
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

// Preview for testing
#Preview {
    ImageUploadView(imageToUpload: .constant(nil),
                    placeholderImage: UIImage(systemName: "photo")!,
                    width: 100,
                    height: 100)
}
