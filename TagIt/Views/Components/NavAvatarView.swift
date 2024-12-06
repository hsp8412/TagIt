//
//  NavAvatarView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-11-28.
//

import SwiftUI

/**
 A view that displays a user's avatar in a circular shape.
 If no avatar image is provided, a default system icon is shown.
 Otherwise, the provided avatar image is displayed.
 */
struct NavAvatarView: View {
    // MARK: - Properties

    /// The avatar image to display, bound to the parent view.
    @Binding var avatar: UIImage?

    // MARK: - View Body

    var body: some View {
        // Default avatar if no image is provided
        if avatar == nil {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.gray) // Default gray color for the icon
        } else {
            // Display the provided avatar image in a circular shape
            Image(uiImage: avatar!)
                .resizable()
                .scaledToFit()
                .clipShape(Circle()) // Clip image to a circle
        }
    }
}

#Preview {
    @Previewable @State var avatarURL: UIImage?
    NavAvatarView(avatar: $avatarURL)
}
