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
    var itemID: String          // Generalized field for any BarcodeItemReview ID or DealID
    var commentText: String
    var commentType: CommentType
    var upvote: Int
    var downvote: Int
    @ServerTimestamp var dateTime: Timestamp?
    
    enum CommentType: String, Codable {
        case deal
        case barcodeItemReview
    }
}

