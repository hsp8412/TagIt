import FirebaseAuth
import FirebaseFirestore
import SwiftUI

/**
 A view that displays a comment card, showing the user's avatar, display name, comment text, and the option to vote.
 The comment text is expandable if it exceeds a set length, and the view allows interaction with voting controls.
 */
struct CommentCardView: View {
    // MARK: - Properties

    /// The comment to display in the card.
    @State var comment: UserComments
    /// The user profile associated with the comment.
    @State var user: UserProfile?
    /// The current user ID for vote tracking and interactions.
    @State var curUserID: String?
    /// Tracks whether the comment is expanded for full text visibility.
    @State private var isExpanded: Bool = false
    /// Error message to be displayed in case of failure.
    @State private var errorMessage: String?

    /// Maximum visible characters for the comment before truncation.
    private let maxTextLength: Int = 255

    // MARK: - View Body

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // User Info Row
            HStack {
                if let user {
                    UserAvatarView(avatarURL: user.avatarURL ?? "")
                        .frame(width: 40, height: 40)
                        .clipShape(Circle()) // Display user avatar

                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.displayName ?? "Unknown User")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)

                        // Display formatted date of the comment
                        Text(comment.date ?? "Just now")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                } else if let errorMessage {
                    Text("Error: \(errorMessage)")
                        .font(.caption)
                        .foregroundColor(.red) // Display error message if user data fails to load
                } else {
                    ProgressView()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle()) // Show loading spinner while fetching user
                }

                Spacer()
            }

            // Comment Text Section
            if isExpanded || comment.commentText.count <= maxTextLength {
                Text(comment.commentText)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .lineLimit(nil) // No line limit when expanded
            } else {
                Text(String(comment.commentText.prefix(maxTextLength)) + "...")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .lineLimit(3) // Limit the displayed text
            }

            // "More" Button to expand or collapse the comment text
            if comment.commentText.count > maxTextLength {
                Button(action: {
                    isExpanded.toggle() // Toggle expanded state
                }) {
                    Text(isExpanded ? "Show Less" : "Show More")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue) // Button color for expand/collapse
                }
            }

            // Voting Controls Section (aligned to bottom-right)
            HStack {
                Spacer() // Align voting controls to the right

                if let curUserID {
                    UpDownVoteView(
                        userId: curUserID,
                        type: .comment,
                        id: comment.id ?? "",
                        upVote: $comment.upvote,
                        downVote: $comment.downvote
                    )
                } else {
                    ProgressView() // Show a loading spinner if current user ID is not available
                }
            }
        }
        .padding(12) // Padding for comment card
        .background(
            Color.white
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3) // Card background and shadow
        )
        .padding(.horizontal)
        .onAppear {
            updateCommentDate() // Update comment date on view appear
            fetchUserForComment() // Fetch user details for the comment
            fetchVotesForComment() // Fetch vote counts for the comment
            fetchCurUserID() // Fetch current user ID for vote tracking
        }
    }

    // MARK: - Helper Functions

    /**
     Fetches the current user's ID from Firebase authentication.
     This is used to track votes from the current user.
     */
    private func fetchCurUserID() {
        if let curUser = Auth.auth().currentUser {
            curUserID = curUser.uid
        }
    }

    /**
     Fetches the user profile associated with the comment by user ID.
     */
    private func fetchUserForComment() {
        UserService.shared.getUserById(id: comment.userID) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(fetchedUser):
                    user = fetchedUser
                case let .failure(error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    /**
     Fetches the upvote and downvote counts for the comment.
     */
    private func fetchVotesForComment() {
        guard let commentId = comment.id else { return }

        VoteService.shared.getVoteCounts(itemId: commentId, itemType: .comment) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(counts):
                    comment.upvote = counts.upvotes
                    comment.downvote = counts.downvotes
                case let .failure(error):
                    print("Error fetching vote counts: \(error.localizedDescription)")
                }
            }
        }
    }

    /**
     Updates the comment's date by converting the timestamp to a "time ago" string.
     */
    private func updateCommentDate() {
        if let timestamp = comment.dateTime {
            comment.date = Utils.timeAgoString(from: timestamp) // Convert timestamp to "time ago" string
        } else {
            comment.date = "Just now" // Default if no timestamp
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
