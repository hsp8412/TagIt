//
//  UserAvatarView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-11-17.
//

import SwiftUI

struct UserAvatarView: View {
    let avatarURL:String

    var body: some View {
        // Default avatar
        if (avatarURL == "") {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.gray)
        } else {
            AsyncImage(url: URL(string: avatarURL)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                } else {
                    ProgressView()
                        .clipShape(Circle())
                }
            }
        }
    }
}

#Preview {
    UserAvatarView(avatarURL: "")
}
