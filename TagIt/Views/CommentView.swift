//
//  CommentView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-21.
//

import SwiftUI

struct CommentView: View {
    @State var comment: UserComments
    let user: UserProfile = UserProfile(userId: "UID1", email: "user@example.com", displayName: "User Name", avatarURL: "https://i.imgur.com/8ciNZcY.jpeg")
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
                
                HStack {
                    // Upvote and downvote button
                    // Need to be fully implemented
                    Button(action: {
                        print("Thumbsup Tapped")
                        comment.upvote = comment.upvote + 1
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.green)
                                .frame(width: 100, height: 30)
                            
                            HStack {
                                Image(systemName: "hand.thumbsup.fill")
                                    .foregroundStyle(Color.white)
                                
                                Text("\(comment.upvote)")
                                    .padding(.horizontal)
                                    .foregroundColor(.white)
                            }
                            
                        }
                    }
                    
                    Button(action: {
                        print("Thumbsdown Tapped")
                        comment.downvote = comment.downvote + 1
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.red)
                                .frame(width: 100, height: 30)
                            
                            HStack {
                                Image(systemName: "hand.thumbsdown.fill")
                                    .foregroundStyle(Color.white)
                                
                                Text("\(comment.downvote)")
                                    .padding(.horizontal)
                                    .foregroundColor(.white)
                            }
                            
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding()
        }
    }
}

#Preview {
    CommentView(comment: UserComments(id: "CommentID1", userID: "2", commentText: "Comments.", type: 0, upvote: 6, downvote: 7))
}
