//
//  FirestoreCollections.swift
//  TagIt
//
//  Created by Peter Tran on 2024-10-16.
//

/**
 A centralized struct containing static constants for Firestore collection names.

 This struct is used to avoid errors related to typing collection names manually throughout the backend operations.
 By using predefined constants, it ensures consistency and reduces the risk of typos when referencing Firestore collections.
 */
enum FirestoreCollections {
    /**
     The Firestore collection name for user profiles.
     */
    static let user = "UserProfile"

    /**
     The Firestore collection name for deals.
     */
    static let deals = "Deals"

    /**
     The Firestore collection name for votes.
     */
    static let votes = "Votes"

    /**
     The Firestore collection name for barcode item reviews.
     */
    static let revItem = "BarcodeItemReview"

    /**
     The Firestore collection name for review stars.
     */
    static let revStars = "ReviewStars"

    /**
     The Firestore collection name for user comments.
     */
    static let userComm = "UserComments"

    /**
     The Firestore collection name for stores.
     */
    static let stores = "Stores"
}
