//
//  UserCommentModel.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-16.
//

import Foundation
import FirebaseFirestore

struct Comment: Identifiable, Decodable {
    @DocumentID var id: String?
    var userID: String
    var commentText: String
    
    // 0: Deals, 1: Barcode Item
    var type: Int
    var upvote: Int
    var downvote: Int
}

func findCommentByID (id: String) -> Comment? {
    // Stub
    let comments = [
        Comment(id: "CommentID1", userID: "2", commentText: "Comments.", type: 0, upvote: 6, downvote: 7),
        Comment(id: "CommentID2", userID: "2", commentText: "Comments.", type: 1, upvote: 8, downvote: 9),
        Comment(id: "CommentID3", userID: "2", commentText: "Comments.", type: 0, upvote: 10, downvote: 11)
    ]

    return comments.first {$0.id == id}
}
