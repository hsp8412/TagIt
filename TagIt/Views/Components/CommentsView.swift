//
//  CommentThreadsView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-21.
//

import SwiftUI

struct CommentsView: View {
    @State var comments: [UserComments]

    var body: some View {
        VStack {
            // Title
            HStack {
                Image(systemName: "list.bullet.rectangle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
                    .foregroundColor(.green)

                Text("Comments (\(comments.count))")
                    .foregroundColor(.green)
                    .font(.system(size: 24, weight: .bold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading)
            .padding(.bottom, 10)

            // Comments List
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(comments) { comment in
                        CommentCardView(comment: comment)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical, 10)
            }
        }
        .padding(.top, 20)
        .background(Color(.systemGroupedBackground)) // Subtle background color
    }
}

#Preview {
    CommentsView(comments: [
        UserComments(id: "CommentID1", userID: "2", itemID: "DealID1", commentText: "This is the first comment.", commentType: .deal, upvote: 6, downvote: 7),
        UserComments(id: "CommentID2", userID: "2", itemID: "DealID1", commentText: "This is another insightful comment.", commentType: .deal, upvote: 8, downvote: 9),
        UserComments(id: "CommentID3", userID: "2", itemID: "DealID1", commentText: "Here is yet another comment.", commentType: .deal, upvote: 10, downvote: 11)
    ])
}
