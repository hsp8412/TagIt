//
//  DealDetailandCommentsView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-21.
//
import FirebaseAuth
import SwiftUI

/**
 `DealDetailView` displays detailed information about a deal and its associated comments.
 It allows users to post comments and interact with existing ones.
 */
struct DealDetailView: View {
    @State var deal: Deal
    @State private var comments: [UserComments] = []
    @State private var isLoading: Bool = true
    @State private var newComment: String = ""
    @State private var errorMessage: String?
    @State private var showAllComments: Bool = false // Toggles showing all comments
    @State private var totalComments: Int = 0 // Tracks the total number of comments

    var body: some View {
        VStack {
            ScrollView {
                // Deal Information
                DealInfoView(deal: $deal)
                    .onTapGesture {
                        UIApplication.shared.hideKeyboard()
                    }

                // Comments Section Header
                HStack {
                    Text(showAllComments ? "Hide Comments" : "View all \(totalComments) comments")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.blue)
                        .onTapGesture {
                            withAnimation {
                                showAllComments.toggle()
                                if showAllComments, comments.isEmpty {
                                    fetchComments() // Load comments only when "View all" is selected
                                }
                            }
                        }

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)

                // Comments List
                if isLoading, showAllComments {
                    ProgressView("Loading comments...")
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity)
                } else if let errorMessage, showAllComments {
                    Text("Error: \(errorMessage)")
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                } else if showAllComments {
                    if comments.isEmpty {
                        Text("No Comments Yet")
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                    } else {
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(comments) { comment in
                                CommentCardView(comment: comment)
                                    .frame(maxWidth: .infinity) // Expand to fill horizontally
                                    .onAppear {
                                        fetchVotesForComment(comment)
                                    }
                                    .onTapGesture {
                                        UIApplication.shared.hideKeyboard()
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }

            // New Comment Bar
            HStack {
                Image(systemName: "lasso.and.sparkles")
                    .foregroundColor(.gray)
                    .padding(.leading)

                TextField("New Comment", text: $newComment)
                    .autocapitalization(.none)
                    .onSubmit {
                        postComment()
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray, lineWidth: 1)
                    .frame(height: 40)
            }
            .padding()
        }
        .padding(.vertical)
        .onAppear {
            updateVoteCounts()
            fetchCommentCount() // Fetch total comment count when the view appears
        }
        .background(Color.white // <-- this is also a view
            .onTapGesture { // <-- add tap gesture to it
                UIApplication.shared.hideKeyboard()
            })
    }

    /**
     Fetches the total number of comments for the deal.
     */
    private func fetchCommentCount() {
        guard let dealId = deal.id else {
            print("Error: Deal ID is nil")
            return
        }

        print("Fetching comment count for deal ID: \(dealId)")
        CommentService.shared.getCommentsForItem(itemID: dealId) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(fetchedComments):
                    totalComments = fetchedComments.count
                case let .failure(error):
                    print("Error fetching comment count: \(error.localizedDescription)")
                }
            }
        }
    }

    /**
     Fetches the comments associated with the deal.
     */
    private func fetchComments() {
        guard let dealId = deal.id else {
            print("Error: Deal ID is nil")
            return
        }

        isLoading = true
        CommentService.shared.getCommentsForItem(itemID: dealId) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(fetchedComments):
                    comments = fetchedComments
                    totalComments = fetchedComments.count
                    isLoading = false
                case let .failure(error):
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }

    /**
     Fetches the vote counts (upvotes and downvotes) for a specific comment.

     - Parameter comment: The comment for which vote counts are being fetched.
     */
    private func fetchVotesForComment(_ comment: UserComments) {
        guard let commentId = comment.id else {
            return
        }

        VoteService.shared.getVoteCounts(itemId: commentId, itemType: .comment) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(counts):
                    if let index = comments.firstIndex(where: { $0.id == comment.id }) {
                        var updatedComment = comments[index]
                        updatedComment.upvote = counts.upvotes
                        updatedComment.downvote = counts.downvotes
                        comments[index] = updatedComment
                    }
                case let .failure(error):
                    print("Error fetching votes for comment ID \(commentId): \(error.localizedDescription)")
                }
            }
        }
    }

    /**
     Posts a new comment for the deal.
     */
    private func postComment() {
        guard !newComment.isEmpty else {
            return
        }

        let commentToPost = UserComments(
            id: nil,
            userID: AuthService.shared.getCurrentUserID() ?? "",
            itemID: deal.id ?? "",
            commentText: newComment,
            commentType: .deal,
            upvote: 0,
            downvote: 0,
            date: "Just now",
            dateTime: nil
        )

        CommentService.shared.addComment(newComment: commentToPost) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    newComment = ""
                    fetchComments() // Reload comments to include the new one
                case let .failure(error):
                    print("Error posting comment: \(error.localizedDescription)")
                }
            }
        }
    }

    /**
     Updates the vote counts (upvotes and downvotes) for the deal.
     */
    private func updateVoteCounts() {
        guard let dealId = deal.id else {
            return
        }

        VoteService.shared.getVoteCounts(itemId: dealId, itemType: .deal) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(counts):
                    var updatedDeal = deal
                    updatedDeal.upvote = counts.upvotes
                    updatedDeal.downvote = counts.downvotes
                    deal = updatedDeal
                case let .failure(error):
                    print("Error fetching votes for deal ID \(dealId): \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    DealDetailView(deal: Deal(id: "1A3584D9-DF4E-4352-84F1-FA6812AE0A26", userID: "OvG9dRB6BqSeVHqvwuN0CfHLYfp2", photoURL: "", productText: "", postText: "", price: 43, location: "", date: "", commentIDs: [], upvote: 5, downvote: 6))
}
