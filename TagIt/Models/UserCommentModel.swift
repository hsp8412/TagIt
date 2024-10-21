//
//  UserCommentModel.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-16.
//

import Foundation
import FirebaseFirestore

struct UserComments: Identifiable, Codable {
    @DocumentID var id: String?
    var userID: String
    var commentText: String
    
    var commentType: CommentType // Use enum for type instead of Int
    var upvote: Int
    var downvote: Int
    
    enum CommentType: Int, Codable {
        case deal = 0
        case barcodeItem = 1
    }
}


func findCommentByID(id: String) -> UserComments? {
    let comments = [
        UserComments(id: "CommentID1", userID: "2", commentText: "Comments.", commentType: .deal, upvote: 6, downvote: 7),
        UserComments(id: "CommentID2", userID: "2", commentText: "Comments.", commentType: .barcodeItem, upvote: 8, downvote: 9),
        UserComments(id: "CommentID3", userID: "2", commentText: "Comments.", commentType: .deal, upvote: 10, downvote: 11)
    ]

    return comments.first { $0.id == id }
}

