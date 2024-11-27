//
//  CommentView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-21.
import SwiftUI
import FirebaseAuth

struct CommentCardView: View {
    @State var comment: UserComments
    @State var user: UserProfile? // Dynamically loaded user
    @State var curUserID: String?
    @State private var isExpanded: Bool = false // Tracks whether the card is expanded
    let time = "1h" // Placeholder for now, can be dynamically calculated from the comment timestamp

    private let maxTextLength: Int = 255 // Maximum visible characters before truncation

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // User Info Row
            HStack(spacing: 10) {
                // User Avatar
                if let user = user, let avatarURL = user.avatarURL, let url = URL(string: avatarURL) {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } else {
                            ProgressView()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        }
                    }
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40) // Placeholder avatar
                }

                // User Name and Timestamp
                VStack(alignment: .leading, spacing: 2) {
                    Text(user?.displayName ?? "Loading...")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .lineLimit(1)

                    Text(time)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }

                Spacer()
            }

            // Comment Text
            if isExpanded || comment.commentText.count <= maxTextLength {
                Text(comment.commentText)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .lineLimit(nil)
            } else {
                Text(String(comment.commentText.prefix(maxTextLength)) + "...")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .lineLimit(3)
            }

            // "More" Button
            if comment.commentText.count > maxTextLength {
                Button(action: {
                    isExpanded.toggle()
                }) {
                    Text(isExpanded ? "Show Less" : "Show More")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                }
            }

            // Voting Controls (aligned to bottom-right)
            HStack {
                Spacer() // Push voting controls to the right

                if (curUserID == nil) {
                    ProgressView()
                } else {
                    UpDownVoteView(
                        userId: curUserID!, // Use the fetched user ID
                        type: .comment,
                        id: comment.id ?? "", // Ensure `comment.id` is unwrapped
                        upVote: $comment.upvote, // Binding for upvotes
                        downVote: $comment.downvote // Binding for downvotes
                    )
                }
            }
        }
        .padding(12) // Reduced padding for a compact design
        .background(
            Color.white
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
        )
        .padding(.horizontal)
        .onAppear {
            fetchUserForComment()
            fetchVotesForComment()
            fetchCurUserID()
        }
    }
    
    private func fetchCurUserID() {
        if let curUser = Auth.auth().currentUser {
            curUserID = curUser.uid
        } else {
            print("[DEBUG] User does not auth")
        }
    }

    private func fetchUserForComment() {
        let userId = comment.userID

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

#Preview {
    CommentCardView(
        comment: UserComments(
            id: "CommentID1",
            userID: "2",
            itemID: "DealID1",
            commentText: "This is a sample comment. It can be multiline and styled appropriately. If the text is too long, it will be truncated and expandable with a 'Show More' option.",
            commentType: .deal,
            upvote: 6,
            downvote: 7
        )
    )
}
