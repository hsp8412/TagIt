//
//  ImageUploadView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-20.
//

import SwiftUI
import PhotosUI

struct ImageUploadView: View {
    @Binding var imageToUpload: UIImage?    // Bind image to parent view
    @State private var photosPickerItem: PhotosPickerItem?
    
    var placeholderImage: UIImage           // Placeholder image when no image is uploaded
    var width: CGFloat                      // Width of the image frame
    var height: CGFloat                     // Height of the image frame
    
    var body: some View {
        HStack {
            PhotosPicker(selection: $photosPickerItem, matching: .images) {
                Image(uiImage: imageToUpload ?? placeholderImage)   // Use the passed placeholder image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .clipped()                                      // Clip to the frame size
            }
        }
        .onChange(of: photosPickerItem) { _, _ in
            Task {
                if let photosPickerItem,
                   let data = try? await photosPickerItem.loadTransferable(type: Data.self) {
                    if let image = UIImage(data: data) {
                        imageToUpload = image
                    }
                }
                photosPickerItem = nil
            }
        }
    }
}

#Preview {
    ImageUploadView(imageToUpload: .constant(nil),
                    placeholderImage: UIImage(named: "addImageIcon")!,
                    width: 100,
                    height: 100)
}
