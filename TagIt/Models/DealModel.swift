//
//  DealModel.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-16.
//

import FirebaseFirestore
import Foundation

/**
 Represents a deal posted by a user.

 This struct captures all relevant details of a deal, including its association with a user, associated store, and engagement metrics such as upvotes and downvotes.
 */
struct Deal: Identifiable, Codable {
    /**
     The unique identifier for the deal.

     This ID is automatically managed by Firestore and is optional until the deal is saved to the database.
     */
    @DocumentID var id: String?

    /**
     The unique identifier of the user who posted the deal.

     This links the deal to a specific user in the system.
     */
    var userID: String

    /**
     The URL of the photo associated with the deal.

     This provides a visual representation of the deal item.
     */
    var photoURL: String

    /**
     A brief description or title of the product being dealt.

     This text highlights the key features or name of the product.
     */
    var productText: String

    /**
     The detailed post text describing the deal.

     This section provides comprehensive information about the deal, including terms, conditions, and any additional details.
     */
    var postText: String

    /**
     The price of the deal.

     This value represents the cost associated with the deal.
     */
    var price: Double

    /**
     The location where the deal is available.

     This can be a physical address or a general area where the deal is applicable.
     */
    var location: String

    /**
     The date when the deal was posted.

     This is a string representation of the posting date, formatted for display purposes.
     */
    var date: String

    /**
     An array of comment IDs associated with the deal.

     These IDs reference comments made by users on the deal, facilitating engagement and feedback.
     */
    var commentIDs: [String]

    /**
     The number of upvotes the deal has received.

     Upvotes indicate positive engagement and approval from users.
     */
    var upvote: Int

    /**
     The number of downvotes the deal has received.

     Downvotes indicate negative engagement or disapproval from users.
     */
    var downvote: Int

    /**
     The store associated with the deal.

     This optional property links the deal to a specific store, providing additional context and information.
     */
    var store: Store?

    /**
     The unique identifier of the store where the deal is available.

     This ID links the deal to its corresponding store in the Firestore `Stores` collection.
     */
    var locationId: String?

    /**
     The server-generated timestamp indicating when the deal was created or last updated.

     This property is automatically set by Firestore and is useful for sorting and displaying the deal's activity timeline.
     */
    @ServerTimestamp var dateTime: Timestamp?

    /**
     Enumeration to map the struct's properties to Firestore document fields.

     This ensures accurate encoding and decoding between the `Deal` struct and Firestore documents.
     */
    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case photoURL
        case productText
        case postText
        case price
        case location
        case date
        case commentIDs
        case upvote
        case downvote
        case locationId
        case dateTime // Ensures dateTime is saved as a timestamp
        // Exclude 'store' from Firestore encoding to prevent nested encoding
    }
}

/**
 Represents a simplified version of a deal received from search results.

 This struct is tailored to handle search hits from Algolia, containing only the necessary fields required to display search results efficiently.
 */
struct DealHit: Codable {
    /**
     The unique identifier of the deal as returned by Algolia.

     This ID corresponds to the `id` field in the Firestore `Deals` collection.
     */
    let objectID: String

    /**
     A brief description or title of the product in the deal.

     This optional field provides a summary of the product for display purposes.
     */
    let productText: String?

    /**
     An array of comment IDs associated with the deal.

     These IDs reference comments made by users on the deal.
     */
    let commentIDs: [String]?

    /**
     The date when the deal was posted.

     This optional field represents the posting date of the deal.
     */
    let date: String?

    /**
     The number of downvotes the deal has received.

     This optional field indicates the level of disapproval from users.
     */
    let downvote: Int?

    /**
     The URL of the photo associated with the deal.

     This optional field provides a visual representation of the deal item.
     */
    let photoURL: String?

    /**
     The detailed post text describing the deal.

     This optional field provides comprehensive information about the deal.
     */
    let postText: String?

    /**
     The price of the deal.

     This optional field represents the cost associated with the deal.
     */
    let price: Double?

    /**
     The number of upvotes the deal has received.

     This optional field indicates the level of approval from users.
     */
    let upvote: Int?

    /**
     The unique identifier of the user who posted the deal.

     This optional field links the deal to the user who created it.
     */
    let userID: String?

    /**
     The server-generated timestamp indicating when the deal was created or last updated.

     This optional field is used for sorting and displaying the deal's activity timeline.
     */
    let dateTime: Int?

    /**
     The location where the deal is available.

     This optional field can be a physical address or a general area where the deal is applicable.
     */
    let location: String?

    /**
     The unique identifier of the store where the deal is available.

     This optional field links the deal to its corresponding store in the Firestore `Stores` collection.
     */
    let locationId: String?
}
