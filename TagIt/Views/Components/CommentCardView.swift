//
//  CommentView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-21.
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CommentCardView: View {
    @State var comment: UserComments
    @State var user: UserProfile? // Dynamically loaded user
    @State var curUserID: String?
    @State private var isExpanded: Bool = false // Tracks whether the card is expanded
    @State private var errorMessage: String?

    private let maxTextLength: Int = 255 // Maximum visible characters before truncation

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // User Info Row
            HStack {
                if let user = user {
                    UserAvatarView(avatarURL: user.avatarURL ?? "")
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.displayName ?? "Unknown User")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)

                        // Display formatted date
                        Text(comment.date ?? "Just now")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .font(.caption)
                        .foregroundColor(.red)
                } else {
                    ProgressView()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
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

                if let curUserID = curUserID {
                    UpDownVoteView(
                        userId: curUserID,
                        type: .comment,
                        id: comment.id ?? "",
                        upVote: $comment.upvote,
                        downVote: $comment.downvote
                    )
                } else {
                    ProgressView()
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
            updateCommentDate() // Update the comment date on appear
            fetchUserForComment()
            fetchVotesForComment()
            fetchCurUserID()
        }
    }

    private func fetchCurUserID() {
        if let curUser = Auth.auth().currentUser {
            curUserID = curUser.uid
        }
    }

    private func fetchUserForComment() {
        UserService.shared.getUserById(id: comment.userID) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedUser):
                    self.user = fetchedUser
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func fetchVotesForComment() {
        guard let commentId = comment.id else { return }

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

    private func updateCommentDate() {
        if let timestamp = comment.dateTime {
            // Check the raw date value
            print("Raw dateTime: \(timestamp.dateValue())")
            
            // Generate the time ago string
            comment.date = Utils.timeAgoString(from: timestamp)
        } else {
            comment.date = "Just now"
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
            downvote: 7,
            date: Utils.timeAgoString(from: Timestamp(date: Date().addingTimeInterval(-3600))),
            dateTime: Timestamp(date: Date().addingTimeInterval(-3600)) // 1 hour ago
        )
    )
}

