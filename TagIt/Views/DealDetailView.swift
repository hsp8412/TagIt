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
            }
            .overlay() {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray, lineWidth: 1)
//                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 40)
            }
            .padding()
            .onSubmit {
                print("New Comment \"\(new_comment)\" Submitted!")
            }
        }
        .padding(.vertical)
        .onAppear {
            // Fetch comments when the view appears
            fetchComments()
        }
        
        
    }

    // Function to fetch comments
    private func fetchComments() {
        isLoading = true
        CommentService.shared.getComments { result in
            switch result {
            case .success(let fetchedComments):
                self.comments = fetchedComments
                self.isLoading = false
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

#Preview {
    DealDetailView(deal: Deal(id: "DealID", userID: "UID1", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", productText: "Product Text", postText: "Post Text. Post Text. Post Text. Post Text. Post Text. Post Text.", price: 1.23, location: "Safeway", date: "2d", commentIDs: ["CommentID1", "CommentID2"], upvote: 5, downvote: 6)
    )
}
