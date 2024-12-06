//
//  UserCommentModel.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-16.
//

import FirebaseFirestore
import Foundation

/**
     Represents a comment made by a user on a specific deal.

     This struct captures all relevant details of a user comment, including the user who made the comment,
     the item being commented on (such as a deal or a barcode item review), the content of the comment,
     and engagement metrics like upvotes and downvotes.

     It conforms to `Identifiable` and `Codable` protocols to facilitate easy integration with SwiftUI views
     and Firestore database operations.
 */
struct UserComments: Identifiable, Codable {
    /// The unique identifier for the comment, automatically managed by Firestore.
    @DocumentID var id: String?

    /// The unique identifier of the user who made the comment.
    var userID: String

    /// The unique identifier of the item being commented on.
    var itemID: String

    /// The text content of the comment.
    var commentText: String

    /// The type of item being commented on (e.g., deal, barcode item review).
    var commentType: CommentType

    /// The number of upvotes the comment has received.
    var upvote: Int

    /// The number of downvotes the comment has received.
    var downvote: Int

    /// The date when the comment was posted, formatted for display purposes.
    var date: String // Changed to non-optional to ensure consistency

    /// The server-generated timestamp indicating when the comment was created or last updated.
    @ServerTimestamp var dateTime: Timestamp? // Populated by Firestore

    /**
         Enumeration representing the types of items that can be commented on.

         - `deal`: Indicates that the comment is made on a deal.
         - `barcodeItemReview(DEPRECIATED)`: Indicates that the comment is made on a barcode item review.
     */
    enum CommentType: String, Codable {
        case deal
        case barcodeItemReview
    }

    /**
         Enumeration to map the struct's properties to Firestore document fields.

         This ensures accurate encoding and decoding between the `UserComments` struct and Firestore documents.
     */
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
