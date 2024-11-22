//
//  CommentView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-21.
import SwiftUI

struct CommentCardView: View {
    @State var comment: UserComments
    @State var user: UserProfile? // Dynamically loaded user
    let time = "1h" // Placeholder for now, can be calculated dynamically based on comment's timestamp
    
    var body: some View {
        ZStack {
            Color.white
                .frame(height: 170)
                .shadow(radius: 5)
            
            VStack(alignment: .leading) {
                HStack {
                    if let user = user, let avatarURL = user.avatarURL, let url = URL(string: avatarURL) {
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
                    
                    VStack(alignment: .leading) {
                        Text(user?.displayName ?? "Loading...")
                            .lineLimit(1)
                        
                        Text(time)
                    }
                }
                
                Text(comment.commentText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 5)
                
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
            fetchUserForComment()
            fetchVotesForComment()
        }
    }
    
    private func fetchUserForComment() {
        let userId = comment.userID // Directly use `comment.userID` since it's not optional
        
        UserService.shared.getUserById(id: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedUser):
                    self.user = fetchedUser
                case .failure(let error):
                    print("Error fetching user for comment: \(error.localizedDescription)")
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
            DispatchQueue.main.async {
                switch result {
                case .success(let counts):
                    comment.upvote = counts.upvotes
                    comment.downvote = counts.downvotes
                case .failure(let error):
                    print("Error fetching vote counts: \(error.localizedDescription)")
                }
            }
        }
    }
}
