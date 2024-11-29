//
//  NavAvatarView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-11-28.
//

import SwiftUI

struct NavAvatarView: View {
    @Binding var avatar:UIImage?
    
    var body: some View {
        // Default avatar
        if (avatar == nil) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.gray)
        } else {
            Image(uiImage: avatar!)
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
        }
    }
}

#Preview {
    @Previewable @State var avatarURL:UIImage?
    NavAvatarView(avatar:$avatarURL)
}
