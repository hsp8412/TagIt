//
//  DealDetailandCommentsView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-21.
//

import SwiftUI

struct DealDetailView: View {
    @State var deal: Deal
    @State private var comments: [UserComments] = []
    @State private var isLoading: Bool = true
    @State var new_comment: String = ""
    @State private var errorMessage: String?


    var body: some View {
        VStack {
            DealInfoView(deal: deal)
            
            if isLoading {
                ProgressView("Loading comments...")
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
            } else {
                // comments
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        ForEach(comments) { comment in
                            CommentCardView(comment: comment)
                                .background(.white)
                        }
                    }
                }
                .padding(.horizontal)
                .refreshable {
                    // Refresh the comments list
                    fetchComments()
                }
            }
            
            // New comment bar
            HStack {
                Image(systemName: "lasso.and.sparkles")
                    .foregroundStyle(Color.gray)
                    .padding(.leading)
                
                TextField("New Comment", text: $new_comment)
                    .autocapitalization(.none)
                    .onSubmit {
                        // Submit comment and clear the text field
                        postComment(comment: new_comment)
                        new_comment = "" // Clear the text field
                    }
            }
            .overlay() {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray, lineWidth: 1)
//                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 40)
            }
            .padding()
        }
        .padding(.vertical)
        .onAppear {
            // Fetch comments when the view appears
            fetchComments()
        }
    }

    /// Fetches comments for the current deal and updates the `comments` property.
    /// Sets `isLoading` to `true` while loading and handles errors by updating `errorMessage`.
    ///
    /// - Parameters: None
    /// - Returns: Void
    private func fetchComments() {
        isLoading = true
        // Fetch comments specific to the current deal
        CommentService.shared.getCommentsForItem(itemID: deal.id ?? "", commentType: .deal) { result in
            switch result {
            case .success(let fetchedComments):
                // Update comments with fetched results and reset loading state
                self.comments = fetchedComments
                self.isLoading = false
            case .failure(let error):
                // Handle error by setting the error message and stopping the loading indicator
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    /// Posts a new comment associated with the current deal.
    /// Checks if the user is authenticated before posting, then creates a `UserComments` object
    /// and passes it to `CommentService` for adding to Firestore. Upon success, fetches updated comments.
    ///
    /// - Parameter comment: The text content of the new comment.
    /// - Returns: Void
    private func postComment(comment: String) {
        // Retrieve current user ID to ensure user is authenticated
        guard let userID = AuthService.shared.getCurrentUserID() else {
            print("Error: User is not authenticated.")
            return
        }

        // Create a new comment for the current deal
        let newComment = UserComments(
            id: nil,
            userID: userID,
            itemID: deal.id ?? "",           // Associate comment with the current deal
            commentText: comment,
            commentType: .deal,              // Specify that the comment is for a deal
            upvote: 0,
            downvote: 0
        )

        // Add the new comment to Firestore and handle result
        CommentService.shared.addComment(newComment: newComment) { result in
            switch result {
            case .success:
                // Refresh comments after posting a new one
                self.fetchComments()
                print("Comment posted successfully!")
            case .failure(let error):
                // Handle error if posting fails
                print("Error posting comment: \(error.localizedDescription)")
            }
        }
    }

}

#Preview {
    DealDetailView(deal: Deal(id: "DealID", userID: "UID1", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", productText: "Product Text", postText: "Post Text. Post Text. Post Text. Post Text. Post Text. Post Text.", price: 1.23, location: "Safeway", date: "2d", commentIDs: ["CommentID1", "CommentID2"], upvote: 5, downvote: 6)
    )
}
