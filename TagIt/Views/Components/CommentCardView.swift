//
//  CommentView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-21.
//

import SwiftUI

struct CommentCardView: View {
    @State var comment: UserComments
    let user: UserProfile = UserProfile(id: "UID1", email: "user@example.com", displayName: "User Name", avatarURL: "https://i.imgur.com/8ciNZcY.jpeg", score: 0, savedDeals: [])
    let time = "1h"

    var body: some View {
        ZStack {
            Color.white
                .frame(height: 170)
                .shadow(radius: 5)
            
            // Comment
            VStack (alignment: .leading) {
                HStack {
                    VStack (alignment: .leading) {
                        HStack {
                            if let avatarURL = user.avatarURL, let url = URL(string: avatarURL) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                    } else {
                                        ProgressView()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                    }
                                }
                            }
                            
                            VStack (alignment: .leading) {
                                Text(user.displayName)
                                    .lineLimit(1)
                                
                                Text(time)
                            }
                        }
                    }
                }
                
                Text(comment.commentText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 5)
                
                // UpVote DownVote Button
                // TAP STATUS NEED TO BE IMPLEMENTED
                UpDownVoteView(type: .comment, id: comment.id!, upVote: comment.upvote, downVote: comment.downvote, upVoteTap: false, downVoteTap: false)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding()
        }
    }
}

#Preview {
    CommentCardView(comment: UserComments(id: "CommentID1", userID: "2", itemID: "DealID1", commentText: "Comments.", commentType: .deal, upvote: 6, downvote: 7))
}
