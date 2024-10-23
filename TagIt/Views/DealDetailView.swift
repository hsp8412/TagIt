//
//  DealDetailandCommentsView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-21.
//

import SwiftUI

struct DealDetailView: View {
    @State var deal: Deal
    @State var new_comment: String = ""

    let comments: [UserComments] = [
        UserComments(id: "CommentID1", userID: "2", commentText: "Comments.", commentType: .deal, upvote: 6, downvote: 7),
        UserComments(id: "CommentID2", userID: "2", commentText: "Comments.", commentType: .deal, upvote: 8, downvote: 9),
        UserComments(id: "CommentID3", userID: "2", commentText: "Comments.", commentType: .deal, upvote: 10, downvote: 11)
    ]

    var body: some View {
        VStack {
            DealDetailView(deal: deal)
            
            CommentsView(comments: comments)
                .padding(.top)
            
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
        
        
    }
}

#Preview {
    DealDetailView(deal: Deal(id: "DealID", userID: "UID1", photoURL: "https://i.imgur.com/8ciNZcY.jpeg", productText: "Product Text", postText: "Post Text. Post Text. Post Text. Post Text. Post Text. Post Text.", price: 1.23, location: "Safeway", date: "2d", commentIDs: ["CommentID1", "CommentID2"], upvote: 5, downvote: 6)
    )
}
