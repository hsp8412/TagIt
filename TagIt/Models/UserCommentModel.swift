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
    
    @ServerTimestamp var dateTime: Timestamp?
    
    
    enum CommentType: Int, Codable {
        case deal = 0
        case barcodeItem = 1
    }
}
