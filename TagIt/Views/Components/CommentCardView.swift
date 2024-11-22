//
//  CommentView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-21.
//
import SwiftUI

struct CommentCardView: View {
    @State var comment: UserComments
    @State var user: UserProfile?
    @State var isLoading = true
    @State private var errorMessage: String?
//    let time = "1h"
    
    var body: some View {
        ZStack {
            Color.white
                .frame(height: 170)
                .shadow(radius: 5)
            
            VStack(alignment: .leading) {
                HStack {
                    UserAvatarView(avatarURL: user?.avatarURL ?? "")
                        .frame(width: 40, height: 40)
                    
                    VStack(alignment: .leading) {
                        Text(user?.displayName ?? "")
                            .lineLimit(1)
                        
//                        Text(time)
                    }
                }
                .frame(height: 40)
                
                Text(comment.commentText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 5)
                    .lineLimit(3)
                
                UpDownVoteView(
                    userId: user?.id ?? "", // Pass user ID dynamically
                    type: .comment,
                    id: comment.id ?? "", // Ensure `comment.id` is unwrapped
                    upVote: $comment.upvote, // Pass as a binding
                    downVote: $comment.downvote // Pass as a binding
                )
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding()
        }
        .onAppear {
            fetchUserProfile()
            fetchVotesForComment()
        }
    }
    
    // Fetch the current user's profile
    private func fetchUserProfile() {
        isLoading = true
        if !comment.userID.isEmpty {
            UserService.shared.getUserById(id: comment.userID) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let fetchUserProfilebyID):
                        self.user = fetchUserProfilebyID
                        self.isLoading = false
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        self.isLoading = false
                    }
                }
            }
        }
    }
    
    private func fetchVotesForComment() {
        guard let commentId = comment.id else {
            print("Error: Comment ID is nil")
            return
        }

        VoteService.shared.getVoteCounts(itemId: commentId, itemType: .comment) { result in
            switch result {
            case .success(let counts):
                DispatchQueue.main.async {
                    comment.upvote = counts.upvotes
                    comment.downvote = counts.downvotes
                }
            case .failure(let error):
                print("Error fetching vote counts: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    CommentCardView(comment: UserComments(userID: "PtMxESE6kEONluP2QtWTAh7tWax2", itemID: "", commentText: "Comment~!!~!~!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", commentType: .deal, upvote: 10, downvote: 20))
}
