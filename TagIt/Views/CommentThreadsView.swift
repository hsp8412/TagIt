//
//  CommentThreadsView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-21.
//

import SwiftUI

struct CommentThreadsView: View {
    @State var comments: [UserComments]

var body: some View {
        VStack {
            // Title
            HStack {
                Image(systemName: "list.bullet.rectangle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
                    .foregroundStyle(.green)
                

                Text("Comment (\(comments.count))")
                    .foregroundStyle(.green)
                    .font(.system(size: 30))
                    .bold()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading)

            // Comments
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    ForEach(comments) { comment in
                        CommentView(comment: comment)
                            .background(.white)
                    }
                }
            }
        }
    }
}

#Preview {
    CommentThreadsView(comments: [
        UserComments(id: "CommentID1", userID: "2", commentText: "Comments.", commentType: .deal, upvote: 6, downvote: 7),
        UserComments(id: "CommentID2", userID: "2", commentText: "Comments.", commentType: .deal, upvote: 8, downvote: 9),
        UserComments(id: "CommentID3", userID: "2", commentText: "Comments.", commentType: .deal, upvote: 10, downvote: 11)
    ])
}
