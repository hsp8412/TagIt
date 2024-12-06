//
//  BarcodeItemReviewModel.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-16.
//

import FirebaseFirestore
import Foundation

/**
 Represents a review submitted by a user for a specific product identified by a barcode.

 This struct captures all relevant details of a review, including the user who submitted it, the product being reviewed,
 the rating given, and the content of the review itself. It conforms to `Identifiable` and `Codable` protocols
 to facilitate easy integration with SwiftUI views and Firestore database operations.
 */
struct BarcodeItemReview: Identifiable, Codable {
    /// The unique identifier for the review.
    @DocumentID var id: String?

    /// The unique identifier of the user who submitted the review.
    var userID: String

    /// The URL of the photo associated with the review.
    var photoURL: String

    /// The star rating given in the review.
    var reviewStars: Double

    /// The name of the product being reviewed.
    var productName: String

    /// The barcode number associated with the product being reviewed.
    var barcodeNumber: String

    /// The server-generated timestamp indicating when the review was created or last updated.
    @ServerTimestamp var dateTime: Timestamp?

    /// The title of the review.
    var reviewTitle: String

    /// The detailed text of the review.
    var reviewText: String

    /**
     Enumeration to map the struct's properties to Firestore document fields.

     This ensures accurate encoding and decoding between the `BarcodeItemReview` struct and Firestore documents.
     */
    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case photoURL
        case reviewStars
        case productName
        case barcodeNumber
        case dateTime
        case reviewTitle
        case reviewText
    }
}
