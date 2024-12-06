//
//  UserAvatarView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-11-17.
//

import SwiftUI

/**
 A view that displays a user avatar. If the avatar URL is empty, it shows a default avatar icon.
 Otherwise, it fetches the image from the provided URL and displays it. The avatar is displayed within a circular frame.
 */
struct UserAvatarView: View {
    // MARK: - Properties

    /// The URL of the user's avatar image.
    let avatarURL: String

    // MARK: - View Body

    var body: some View {
        // Default avatar if URL is empty
        if avatarURL == "" {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.gray) // Default gray color for the icon
        } else {
            AsyncImage(url: URL(string: avatarURL)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle()) // Display image as a circle
                } else {
                    ProgressView()
                        .clipShape(Circle()) // Show a loading spinner while fetching the image
                }
            }
        }
    }
}

#Preview {
    UserAvatarView(avatarURL: "")
}
