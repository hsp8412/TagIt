//
//  DealDetailandCommentsView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-21.
//
import SwiftUI
import FirebaseAuth

struct DealDetailView: View {
    @State var deal: Deal
    @State private var comments: [UserComments] = []
    @State private var isLoading: Bool = true
    @State private var newComment: String = ""
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            ScrollView {
                DealInfoView(deal: $deal)
                
                Text("Comments")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                if isLoading {
                    ProgressView("Loading comments...")
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                } else if comments.isEmpty {
                    Text("No Comments Yet")
                } else {
                    VStack(alignment: .leading, spacing: 30) {
                        ForEach(comments) { comment in
                            CommentCardView(comment: comment)
                                .background(Color.white)
                                .onAppear {
                                    print("Fetching votes for comment: \(comment.id ?? "unknown")")
                                    fetchVotesForComment(comment)
                                }
                        }
                    }
                }
            }
            
            // New comment bar
            HStack {
                Image(systemName: "lasso.and.sparkles")
                    .foregroundStyle(Color.gray)
                    .padding(.leading)
                
                TextField("New Comment", text: $newComment)
                    .autocapitalization(.none)
                    .onSubmit {
                        print("Submitting new comment: \(newComment)")
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
            print("DealDetailView appeared, fetching votes and comments for deal ID: \(deal.id ?? "unknown")")
            updateVoteCounts()
            fetchComments()
        }
    }
    
    private func fetchComments() {
        guard let dealId = deal.id else {
            print("Error: Deal ID is nil")
            return
        }

        isLoading = true
        print("Fetching comments for deal ID: \(dealId)")
        CommentService.shared.getCommentsForItem(itemID: dealId, commentType: .deal) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedComments):
                    print("Fetched \(fetchedComments.count) comments for deal ID: \(dealId)")
                    self.comments = fetchedComments
                    self.isLoading = false
                case .failure(let error):
                    print("Error fetching comments for deal ID \(dealId): \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private func fetchVotesForComment(_ comment: UserComments) {
        guard let commentId = comment.id else {
            print("Error: Comment ID is nil")
            return
        }

        print("Fetching votes for comment ID: \(commentId)")
        VoteService.shared.getVoteCounts(itemId: commentId, itemType: .comment) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let counts):
                    print("Fetched votes for comment ID \(commentId): \(counts.upvotes) upvotes, \(counts.downvotes) downvotes")
                    if let index = self.comments.firstIndex(where: { $0.id == comment.id }) {
                        var updatedComment = self.comments[index]
                        updatedComment.upvote = counts.upvotes
                        updatedComment.downvote = counts.downvotes
                        self.comments[index] = updatedComment
                    }
                case .failure(let error):
                    print("Error fetching votes for comment ID \(commentId): \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func postComment() {
        guard !newComment.isEmpty else {
            print("Error: New comment text is empty")
            return
        }

        let commentToPost = UserComments(
            id: nil,
            userID: AuthService.shared.getCurrentUserID() ?? "",
            itemID: deal.id ?? "",
            commentText: self.newComment,
            commentType: .deal,
            upvote: 0,
            downvote: 0
        )

        print("Posting comment: \(commentToPost.commentText)")
        CommentService.shared.addComment(newComment: commentToPost) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Comment posted successfully!")
                    self.newComment = ""
                    self.fetchComments()
                case .failure(let error):
                    print("Error posting comment: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateVoteCounts() {
        guard let dealId = deal.id else {
            print("Error: Deal ID is nil")
            return
        }

        print("Fetching votes for deal ID: \(dealId)")
        VoteService.shared.getVoteCounts(itemId: dealId, itemType: .deal) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let counts):
                    print("Fetched votes for deal ID \(dealId): \(counts.upvotes) upvotes, \(counts.downvotes) downvotes")
                    var updatedDeal = self.deal
                    updatedDeal.upvote = counts.upvotes
                    updatedDeal.downvote = counts.downvotes
                    self.deal = updatedDeal
                case .failure(let error):
                    print("Error fetching votes for deal ID \(dealId): \(error.localizedDescription)")
                }
            }
        }
    }
}
