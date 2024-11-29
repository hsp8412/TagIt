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
    var itemID: String
    var commentText: String
    var commentType: CommentType
    var upvote: Int
    var downvote: Int
    var date: String // Change to non-optional to ensure consistency
    @ServerTimestamp var dateTime: Timestamp? // Populated by Firestore

    enum CommentType: String, Codable {
        case deal
        case barcodeItemReview
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case itemID
        case commentText
        case commentType
        case upvote
        case downvote
        case date
        case dateTime
    }
}

