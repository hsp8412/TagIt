//
//  ReviewService.swift
//  TagIt
//
//  Created by Peter Tran on 2024-10-23.
//

import Foundation
import FirebaseFirestore


class ReviewService {
    static let shared = ReviewService()

    /**
     Handles adding, updating, or removing a review for a specific barcode item by a user.

     - Parameters:
        - userId: The ID of the user who is submitting the review.
        - barcodeNumber: The barcode number of the item being reviewed.
        - reviewStars: The number of stars (rating) the user is giving the item.
        - productName: The name of the product being reviewed.
        - reviewTitle: The title of the review.
        - reviewText: The text content of the review.
        - photoURL: The URL of the photo associated with the review.
        - completion: A closure that returns a `Result<Void, Error>` indicating success or failure.
     */
    func handleReview(
        userId: String,
        barcodeNumber: String,
        reviewStars: Double,
        productName: String,
        reviewTitle: String,
        reviewText: String,
        photoURL: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let reviewId = "\(userId)_\(barcodeNumber)" // Unique identifier for each review (userId + barcodeNumber)

        // Create or update the review
        let review = BarcodeItemReview(
            id: reviewId,
            userID: userId,
            photoURL: photoURL,
            reviewStars: reviewStars,
            productName: productName,
            barcodeNumber: barcodeNumber,
            dateTime: nil,
            reviewTitle: reviewTitle,
            reviewText: reviewText
        )

        do {
            try Firestore.firestore().collection(FirestoreCollections.revItem)
                .document(reviewId)
                .setData(from: review) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        // Optionally, update overall review stars
                        self.updateReviewStars(for: barcodeNumber, completion: completion)
                    }
                }
        } catch {
            completion(.failure(error))
        }
    }

    // Rest of the methods remain the same...

    // Ensure to update other methods if they call `handleReview` to include the new parameters.
}
